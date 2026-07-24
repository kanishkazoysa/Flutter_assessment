import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'product_provider.dart';

/// Provider that holds the current search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider that holds the currently selected category filter.
/// Null or empty means "All" categories.
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Provider that extracts unique categories from the product list.
final categoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final productsAsync = ref.watch(productProvider);
  return productsAsync.whenData((products) {
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  });
});

/// Provider that returns a filtered list of products based on
/// both the search query and the selected category.
///
/// Performs case-insensitive substring matching on product titles.
/// Returns all products when the search query is empty and no category is selected.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return productsAsync.whenData((products) {
    var filtered = products;

    // Filter by category
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((product) => product.category == selectedCategory)
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered
          .where((product) => product.title.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  });
});
