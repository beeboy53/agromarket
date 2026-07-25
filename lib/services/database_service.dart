import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/commodity.dart';

/// Handles ALL offline storage for the app:
///  - a local cache of every commodity (so the app still shows data
///    with no internet / if the JSON asset ever fails to load),
///  - admin-added and admin-edited market price records (Create/Update),
///  - admin-deleted commodity ids (Delete),
///  - the user's favourite commodity ids, and
///  - local user accounts (register/login).
///
/// IMPORTANT (for project defense): `sqflite` (SQLite) only works on
/// Android/iOS/Desktop — a browser has no file system to store a `.db`
/// file in. So on Flutter Web this class transparently falls back to
/// SharedPreferences (browser storage) instead, using the EXACT same
/// public methods. Every other file in the app only ever calls these
/// methods and never needs to know which storage engine is in use.
///
/// HOW ADMIN EDITS SURVIVE A REFRESH (for project defense): every
/// cached commodity row is tagged with a `source`:
///   - 'json'         → came from the bundled JSON dataset
///   - 'admin_added'   → created by an admin (didn't exist in JSON)
///   - 'admin_edited'  → originally from JSON, but an admin has since
///                       changed its price/description
/// Whenever the app re-loads the JSON dataset, [cacheCommodities]
/// skips any id that is currently 'admin_added' or 'admin_edited', so
/// admin changes are never silently overwritten by the original data.
/// Deleted ids are tracked separately so a deleted JSON record doesn't
/// reappear next time the JSON is reloaded.
///
/// SECURITY NOTE: user passwords are stored as plain text here to keep
/// this academic project simple and dependency-free. A production app
/// must hash passwords (e.g. with the `crypto` package) first.
class DatabaseService {
  static const String _cacheKey = 'cached_commodities';
  static const String _deletedKey = 'deleted_commodity_ids';
  static const String _favouritesKey = 'favourite_ids';
  static const String _usersKey = 'users_map';

  Database? _database;

  /// Lazily opens (and creates/upgrades, on first run) the SQLite
  /// database. Only ever called on non-web platforms.
  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'agromarket.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE commodities (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            market TEXT NOT NULL,
            state TEXT NOT NULL,
            currentPrice REAL NOT NULL,
            previousPrice REAL NOT NULL,
            dateUpdated TEXT NOT NULL,
            description TEXT NOT NULL,
            priceHistory TEXT NOT NULL,
            source TEXT NOT NULL DEFAULT 'json'
          )
        ''');

        await db.execute('''
          CREATE TABLE deleted_commodities (
            id TEXT PRIMARY KEY
          )
        ''');

        await db.execute('''
          CREATE TABLE favourites (
            commodityId TEXT PRIMARY KEY,
            addedAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE users (
            username TEXT PRIMARY KEY,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Upgrading from the Phase 4 schema (no `source` column, no
        // deleted_commodities table) to the current one.
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE commodities ADD COLUMN source TEXT NOT NULL DEFAULT 'json'",
          );
          await db.execute('''
            CREATE TABLE IF NOT EXISTS deleted_commodities (
              id TEXT PRIMARY KEY
            )
          ''');
        }
      },
    );

    return _database!;
  }

  // ---------------------------------------------------------------
  // Row <-> Commodity conversion
  // ---------------------------------------------------------------

  Map<String, dynamic> _commodityToRow(Commodity c, {required String source}) => {
        'id': c.id,
        'name': c.name,
        'category': c.category,
        'market': c.market,
        'state': c.state,
        'currentPrice': c.currentPrice,
        'previousPrice': c.previousPrice,
        'dateUpdated': c.dateUpdated.toIso8601String(),
        'description': c.description,
        'priceHistory': json.encode(c.priceHistory.map((p) => p.toJson()).toList()),
        'source': source,
      };

  Commodity _commodityFromRow(Map<String, dynamic> row) => Commodity(
        id: row['id'] as String,
        name: row['name'] as String,
        category: row['category'] as String,
        market: row['market'] as String,
        state: row['state'] as String,
        currentPrice: (row['currentPrice'] as num).toDouble(),
        previousPrice: (row['previousPrice'] as num).toDouble(),
        dateUpdated: DateTime.parse(row['dateUpdated'] as String),
        description: row['description'] as String,
        priceHistory: (json.decode(row['priceHistory'] as String) as List<dynamic>)
            .map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String _sourceOf(Map<String, dynamic> row) => (row['source'] as String?) ?? 'json';

  // ---------------------------------------------------------------
  // Web-only raw row storage helpers
  // ---------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _readWebRows() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }

  Future<void> _writeWebRows(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(rows));
  }

  // ---------------------------------------------------------------
  // CREATE / UPDATE — commodities
  // ---------------------------------------------------------------

  /// Refreshes the offline cache with freshly-loaded JSON/API data.
  /// Any id that an admin has added or edited (source != 'json') is
  /// left untouched, so admin changes always survive a data refresh.
  /// Deleted ids are also skipped, so they don't silently reappear.
  Future<void> cacheCommodities(List<Commodity> commodities) async {
    final deletedIds = await getDeletedIds();

    if (kIsWeb) {
      final existingRows = await _readWebRows();
      final locallyManagedIds = existingRows
          .where((r) => _sourceOf(r) != 'json')
          .map((r) => r['id'] as String)
          .toSet();

      final keptRows = existingRows.where((r) => locallyManagedIds.contains(r['id'])).toList();
      final freshRows = commodities
          .where((c) => !locallyManagedIds.contains(c.id) && !deletedIds.contains(c.id))
          .map((c) => _commodityToRow(c, source: 'json'))
          .toList();

      await _writeWebRows([...keptRows, ...freshRows]);
      return;
    }

    final db = await _getDatabase();
    final existingRows = await db.query('commodities', columns: ['id', 'source']);
    final locallyManagedIds = existingRows
        .where((r) => _sourceOf(r) != 'json')
        .map((r) => r['id'] as String)
        .toSet();

    final batch = db.batch();
    for (final c in commodities) {
      if (locallyManagedIds.contains(c.id) || deletedIds.contains(c.id)) continue;
      batch.insert(
        'commodities',
        _commodityToRow(c, source: 'json'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Creates a brand-new commodity added by an admin.
  Future<void> addCommodity(Commodity commodity) async {
    await _upsertCommodity(commodity, source: 'admin_added');
  }

  /// Updates an existing commodity's data after an admin edits it
  /// (works whether the original record came from JSON or was
  /// already admin-added).
  Future<void> updateCommodity(Commodity commodity) async {
    await _upsertCommodity(commodity, source: 'admin_edited');
  }

  Future<void> _upsertCommodity(Commodity commodity, {required String source}) async {
    final row = _commodityToRow(commodity, source: source);

    if (kIsWeb) {
      final rows = await _readWebRows();
      rows.removeWhere((r) => r['id'] == commodity.id);
      rows.add(row);
      await _writeWebRows(rows);
      return;
    }

    final db = await _getDatabase();
    await db.insert('commodities', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------------------------------------------------------------
  // DELETE — commodities
  // ---------------------------------------------------------------

  /// Removes a commodity and remembers its id so it doesn't reappear
  /// next time the JSON dataset is reloaded.
  Future<void> deleteCommodity(String commodityId) async {
    if (kIsWeb) {
      final rows = await _readWebRows();
      rows.removeWhere((r) => r['id'] == commodityId);
      await _writeWebRows(rows);

      final prefs = await SharedPreferences.getInstance();
      final deleted = (prefs.getStringList(_deletedKey) ?? []).toSet();
      deleted.add(commodityId);
      await prefs.setStringList(_deletedKey, deleted.toList());
      return;
    }

    final db = await _getDatabase();
    await db.delete('commodities', where: 'id = ?', whereArgs: [commodityId]);
    await db.insert(
      'deleted_commodities',
      {'id': commodityId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> getDeletedIds() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_deletedKey) ?? []).toSet();
    }

    final db = await _getDatabase();
    final rows = await db.query('deleted_commodities');
    return rows.map((r) => r['id'] as String).toSet();
  }

  // ---------------------------------------------------------------
  // READ — commodities
  // ---------------------------------------------------------------

  /// Returns everything currently stored offline: the last JSON
  /// refresh, plus any admin additions/edits, minus deletions.
  Future<List<Commodity>> getCachedCommodities() async {
    final deletedIds = await getDeletedIds();

    if (kIsWeb) {
      final rows = await _readWebRows();
      return rows
          .where((r) => !deletedIds.contains(r['id']))
          .map(_commodityFromRow)
          .toList();
    }

    final db = await _getDatabase();
    final rows = await db.query('commodities');
    return rows
        .where((r) => !deletedIds.contains(r['id']))
        .map(_commodityFromRow)
        .toList();
  }

  // ---------------------------------------------------------------
  // CREATE / DELETE — favourites
  // ---------------------------------------------------------------

  Future<void> addFavourite(String commodityId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final ids = (prefs.getStringList(_favouritesKey) ?? []).toSet();
      ids.add(commodityId);
      await prefs.setStringList(_favouritesKey, ids.toList());
      return;
    }

    final db = await _getDatabase();
    await db.insert(
      'favourites',
      {
        'commodityId': commodityId,
        'addedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavourite(String commodityId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final ids = (prefs.getStringList(_favouritesKey) ?? []).toSet();
      ids.remove(commodityId);
      await prefs.setStringList(_favouritesKey, ids.toList());
      return;
    }

    final db = await _getDatabase();
    await db.delete('favourites', where: 'commodityId = ?', whereArgs: [commodityId]);
  }

  // ---------------------------------------------------------------
  // READ — favourites
  // ---------------------------------------------------------------

  Future<Set<String>> getFavouriteIds() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_favouritesKey) ?? []).toSet();
    }

    final db = await _getDatabase();
    final rows = await db.query('favourites');
    return rows.map((r) => r['commodityId'] as String).toSet();
  }

  /// Returns the full Commodity objects the user has favourited, by
  /// combining the favourite ids with the offline commodity cache.
  Future<List<Commodity>> getFavourites() async {
    final ids = await getFavouriteIds();
    final cached = await getCachedCommodities();
    return cached.where((c) => ids.contains(c.id)).toList();
  }

  // ---------------------------------------------------------------
  // Users — local login/register accounts
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> _readWebUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    return json.decode(raw) as Map<String, dynamic>;
  }

  Future<void> _writeWebUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }

  Future<void> createUser(String username, String password, String role) async {
    if (kIsWeb) {
      final users = await _readWebUsers();
      users[username] = {'password': password, 'role': role};
      await _writeWebUsers(users);
      return;
    }

    final db = await _getDatabase();
    await db.insert(
      'users',
      {'username': username, 'password': password, 'role': role},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    if (kIsWeb) {
      final users = await _readWebUsers();
      final user = users[username];
      return user == null ? null : Map<String, dynamic>.from(user as Map);
    }

    final db = await _getDatabase();
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (rows.isEmpty) return null;
    return {'password': rows.first['password'], 'role': rows.first['role']};
  }

  Future<void> seedDefaultAdmin() async {
    final existing = await getUser('admin');
    if (existing == null) {
      await createUser('admin', 'admin123', 'admin');
    }
  }
}