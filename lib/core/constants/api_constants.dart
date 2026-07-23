/// API constants for the FakeStore API.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the FakeStore API.
  static const String baseUrl = 'https://fakestoreapi.com';

  /// Endpoint to fetch all products.
  static const String productsEndpoint = '/products';

  /// Returns the full URL for fetching all products.
  static String get productsUrl => '$baseUrl$productsEndpoint';
}
