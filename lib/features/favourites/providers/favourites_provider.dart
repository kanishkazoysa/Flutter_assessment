import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favourites_service.dart';

/// Provider for the [FavouritesService] instance.
final favouritesServiceProvider = Provider<FavouritesService>((ref) {
  return FavouritesService();
});

/// Provider that manages the set of favourite product IDs.
///
/// Loads initial favourites from SharedPreferences and persists
/// changes whenever a product is added or removed.
final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<int>>((ref) {
  final service = ref.watch(favouritesServiceProvider);
  return FavouritesNotifier(service);
});

/// Notifier that manages favourite product IDs with persistence.
class FavouritesNotifier extends StateNotifier<Set<int>> {
  final FavouritesService _service;

  FavouritesNotifier(this._service) : super({}) {
    _loadFavourites();
  }

  /// Loads favourites from persistent storage.
  Future<void> _loadFavourites() async {
    final favourites = await _service.loadFavourites();
    state = favourites;
  }

  /// Toggles the favourite status of a product.
  ///
  /// If the product is already a favourite, it is removed.
  /// If it is not a favourite, it is added.
  Future<void> toggleFavourite(int productId) async {
    final updated = Set<int>.from(state);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
    await _service.saveFavourites(updated);
  }

  /// Checks whether a product is in the favourites.
  bool isFavourite(int productId) => state.contains(productId);
}
