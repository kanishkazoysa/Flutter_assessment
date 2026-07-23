import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// A simple HTTP client wrapper with error handling.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Performs a GET request to the given [url] and returns the decoded JSON.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<dynamic> get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to load data',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on FormatException {
      throw ApiException('Invalid response format from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  /// Disposes the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}

/// Custom exception class for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
