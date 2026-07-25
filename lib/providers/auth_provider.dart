import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/database_service.dart';

/// Handles simple local user accounts: registration, login, logout,
/// and knowing whether the current user is an admin.
///
/// IMPORTANT (for project defense): this is a LOCAL, offline-only
/// authentication system — there is no backend server, matching the
/// "no Laravel/Node, keep it simple" project brief. Usernames and
/// passwords are stored directly via [DatabaseService] (SQLite on
/// mobile, SharedPreferences on web). See the security note in
/// DatabaseService about why passwords are stored as plain text here.
class AuthProvider extends ChangeNotifier {
  static const String _sessionKey = 'logged_in_username';

  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _username;
  String? _role;

  AuthProvider() {
    _init();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';

  Future<void> _init() async {
    // Make sure a default admin account always exists, so the app
    // can be demoed immediately without registering an admin first.
    await _dbService.seedDefaultAdmin();

    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString(_sessionKey);

    if (savedUsername != null) {
      final user = await _dbService.getUser(savedUsername);
      if (user != null) {
        _isLoggedIn = true;
        _username = savedUsername;
        _role = user['role'] as String;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Attempts to log in with [username]/[password].
  /// Returns null on success, or a user-facing error message.
  Future<String?> login(String username, String password) async {
    final user = await _dbService.getUser(username);
    if (user == null) return 'No account found for "$username".';
    if (user['password'] != password) return 'Incorrect password.';

    _isLoggedIn = true;
    _username = username;
    _role = user['role'] as String;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, username);

    return null;
  }

  /// Registers a new regular ("user") account and logs them in.
  /// Admin accounts cannot be self-registered — only the seeded
  /// default admin account exists, to keep permissions simple.
  /// Returns null on success, or a user-facing error message.
  Future<String?> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return 'Username and password cannot be empty.';
    }

    final existing = await _dbService.getUser(username);
    if (existing != null) return 'That username is already taken.';

    await _dbService.createUser(username, password, 'user');
    return login(username, password);
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _username = null;
    _role = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}