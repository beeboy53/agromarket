import 'package:flutter/foundation.dart';

import '../models/commodity.dart';
import '../models/price_comparison.dart';
import '../services/commodity_service.dart';
import '../services/database_service.dart';

/// Holds all commodity data for the app and the current
/// search/filter state. Screens read from this provider using
/// `context.watch<CommodityProvider>()` and never talk to
/// CommodityService, DatabaseService, or JSON directly.
class CommodityProvider extends ChangeNotifier {
  final CommodityService _service = CommodityService();
  final DatabaseService _dbService = DatabaseService();

  List<Commodity> _all = [];
  bool _isLoading = true;
  String? _error;
  bool _isOffline = false;

  String _searchQuery = '';
  String? _categoryFilter;
  String? _stateFilter;
  String? _marketFilter;

  /// [autoLoad] is only false in tests, where data is injected with
  /// [debugSetCommodities] instead of being read from storage.
  CommodityProvider({bool autoLoad = true}) {
    if (autoLoad) loadCommodities();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  String? get stateFilter => _stateFilter;
  String? get marketFilter => _marketFilter;

  bool get hasActiveFilters =>
      _categoryFilter != null || _stateFilter != null || _marketFilter != null;

  List<Commodity> get all => _all;

  /// All distinct state names present in the data, sorted A-Z.
  List<String> get allStates =>
      _all.map((c) => c.state).toSet().toList()..sort();

  /// All distinct market names present in the data, sorted A-Z.
  List<String> get allMarkets =>
      _all.map((c) => c.market).toSet().toList()..sort();

  /// All distinct commodity names present in the data, sorted A-Z.
  /// Used by the Compare Prices screen to list what can be compared.
  List<String> get allCommodityNames =>
      _all.map((c) => c.name).toSet().toList()..sort();

  /// Prices for [commodityName] across every state that has a record
  /// for it, best price first, together with the money available by
  /// choosing that state. Defaults to the sell view (highest price
  /// wins), since the app serves farmers selling produce.
  PriceComparison comparePricesFor(
    String commodityName, {
    PricePerspective perspective = PricePerspective.sell,
  }) =>
      PriceComparison.from(_all, commodityName, perspective: perspective);

  /// Test/preview hook: fills the provider directly, bypassing the
  /// JSON asset and offline storage.
  @visibleForTesting
  void debugSetCommodities(List<Commodity> commodities) {
    _all = commodities;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// The commodity list after applying search text and all active
  /// filters (category, state, market). This is what every list
  /// screen should display.
  List<Commodity> get filtered {
    return _all.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _categoryFilter == null || c.category == _categoryFilter;
      final matchesState = _stateFilter == null || c.state == _stateFilter;
      final matchesMarket = _marketFilter == null || c.market == _marketFilter;
      return matchesSearch && matchesCategory && matchesState && matchesMarket;
    }).toList();
  }

  /// Loads commodities from the live source (currently local JSON,
  /// later a real API), refreshes the offline cache, then reads the
  /// merged result back from the cache — which safely preserves any
  /// admin additions/edits/deletions (see DatabaseService for how).
  /// On failure, falls back entirely to whatever was last cached —
  /// this is the app's "Offline Storage" behaviour in action.
  Future<void> loadCommodities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jsonData = await _service.fetchCommodities();
      await _dbService.cacheCommodities(jsonData);
      _all = await _dbService.getCachedCommodities();
      _isOffline = false;
    } catch (e) {
      final cached = await _dbService.getCachedCommodities();
      if (cached.isNotEmpty) {
        _all = cached;
        _isOffline = true;
      } else {
        _error = 'Failed to load commodity data.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Admin: adds a brand-new market-price record (Create).
  Future<void> addAdminCommodity(Commodity commodity) async {
    await _dbService.addCommodity(commodity);
    _all = await _dbService.getCachedCommodities();
    notifyListeners();
  }

  /// Admin: edits an existing commodity's price/description (Update).
  /// Works whether the record originally came from JSON or was
  /// already admin-added.
  Future<void> updateCommodity(Commodity commodity) async {
    await _dbService.updateCommodity(commodity);
    _all = await _dbService.getCachedCommodities();
    notifyListeners();
  }

  /// Admin: removes a commodity entirely (Delete). The deletion is
  /// remembered so the record doesn't reappear on the next JSON
  /// refresh, even if it's still present in the bundled JSON file.
  Future<void> deleteCommodity(String commodityId) async {
    await _dbService.deleteCommodity(commodityId);
    _all = await _dbService.getCachedCommodities();
    notifyListeners();
  }

  /// Other market-price records that share the same commodity name
  /// as [commodity] — used to build the "Available Markets" section
  /// on the Commodity Details screen. Highest price first, since a
  /// farmer selling produce wants to see where produce fetches the
  /// most money.
  List<Commodity> availableMarketsFor(Commodity commodity) {
    return _all
        .where((c) => c.name == commodity.name && c.id != commodity.id)
        .toList()
      ..sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setStateFilter(String? state) {
    _stateFilter = state;
    notifyListeners();
  }

  void setMarketFilter(String? market) {
    _marketFilter = market;
    notifyListeners();
  }

  void clearFilters() {
    _categoryFilter = null;
    _stateFilter = null;
    _marketFilter = null;
    notifyListeners();
  }
}