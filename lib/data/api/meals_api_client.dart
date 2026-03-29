import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MealsApiClient {
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final http.Client _client;

  MealsApiClient(this._client);

  Future<T> get<T>(
    String endpoint, {
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw Exception('No internet connection');
    }
  }

  Exception _handleError(http.Response response) {
    final errors = {
      400: 'Bad request(400)',
      401: 'Unauthorized(401)',
      404: 'Not Found(404)',
      500: 'Server error(500)',
    };
    final message =
        errors[response.statusCode] ?? 'Error: ${response.statusCode}';
    return Exception(message);
  }
}
