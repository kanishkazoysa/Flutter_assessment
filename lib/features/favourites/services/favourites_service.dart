import 'package:shared_preferences/shared_preferences.dart';

/// Service that handles persisting favourite product IDs using SharedPreferences.
class FavouritesService {
  static const String _key = 'favourite_product_ids';

  /// Loads the set of favourite product IDs from storage.
  Future<Set<int>> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? ids = prefs.getStringList(_key);
    if (ids == null) return {};
    return ids.map((id) => int.parse(id)).toSet();
  }

  /// Saves the set of favourite product IDs to storage.
  Future<void> saveFavourites(Set<int> favouriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = favouriteIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_key, ids);
  }
}
