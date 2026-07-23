import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/product.dart';

/// Provider for the API client instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(() => client.dispose());
  return client;
});

/// Provider that fetches and caches the list of products from the API.
///
/// Uses [FutureProvider] to automatically handle loading, error, and data states.
/// The product list is cached and only re-fetched when explicitly invalidated.
final productProvider = FutureProvider<List<Product>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final data = await apiClient.get(ApiConstants.productsUrl);

  final List<dynamic> jsonList = data as List<dynamic>;
  return jsonList
      .map((json) => Product.fromJson(json as Map<String, dynamic>))
      .toList();
});
