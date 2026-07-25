import 'package:flutter/foundation.dart';

import '../models/commodity.dart';
import '../services/database_service.dart';

/// Holds the user's favourite commodities and lets any screen
/// toggle a commodity's favourite status. Backed by [DatabaseService]
/// (SQLite on mobile, SharedPreferences on web) so favourites persist
/// even after the app is closed.
class FavouriteProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Set<String> _favouriteIds = {};
  List<Commodity> _favourites = [];
  bool _isLoading = true;

  FavouriteProvider() {
    loadFavourites();
  }

  bool get isLoading => _isLoading;
  List<Commodity> get favourites => _favourites;

  bool isFavourite(String commodityId) => _favouriteIds.contains(commodityId);

  Future<void> loadFavourites() async {
    _isLoading = true;
    notifyListeners();

    _favouriteIds = await _dbService.getFavouriteIds();
    _favourites = await _dbService.getFavourites();

    _isLoading = false;
    notifyListeners();
  }

  /// Adds [commodity] to favourites if it isn't already one,
  /// otherwise removes it. Called from the heart icon on
  /// CommodityCard and CommodityDetailsScreen.
  Future<void> toggleFavourite(Commodity commodity) async {
    if (_favouriteIds.contains(commodity.id)) {
      await _dbService.removeFavourite(commodity.id);
    } else {
      await _dbService.addFavourite(commodity.id);
    }
    await loadFavourites();
  }

  /// Called after CommodityProvider refreshes the offline cache,
  /// so the favourites list picks up any updated prices/details.
  Future<void> refreshFromCache() => loadFavourites();
}