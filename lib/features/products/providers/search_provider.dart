import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'product_provider.dart';

/// Provider that holds the current search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider that returns a filtered list of products based on the search query.
///
/// Performs case-insensitive substring matching on product titles.
/// Returns all products when the search query is empty.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return productsAsync.whenData((products) {
    if (query.isEmpty) return products;
    return products
        .where((product) => product.title.toLowerCase().contains(query))
        .toList();
  });
});
