import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {

  static String get _baseUrl {
    if (kIsWeb) {
      final url = dotenv.env['LOCAL_API_URL_WEB'] ?? 'http://localhost:3000/api';
      return url;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final url = dotenv.env['LOCAL_API_URL_ANDROID'] ?? 'http://10.0.2.2:3000/api';
      return url;
    }
    final url = dotenv.env['WEB_BASE_URL'] ?? 'http://localhost:3000/api';
    return url;
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Generic GET request
  static Future<http.Response> get(String endpoint, {bool requireAuth = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await http.get(uri, headers: headers);
    _handleResponseError(response);
    return response;
  }

  // Generic POST request
  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {bool requireAuth = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await http.post(uri, headers: headers, body: json.encode(data));
    _handleResponseError(response);
    return response;
  }

  // Generic DELETE request
  static Future<http.Response> delete(String endpoint, {bool requireAuth = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await http.delete(uri, headers: headers);
    _handleResponseError(response);
    return response;
  }

  // Error handling utility
  static void _handleResponseError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = 'An error occurred';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (e) {
        // Not a JSON response, or parsing failed. Use default message.
      }
      throw HttpException(response.statusCode, errorMessage);
    }
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String message;

  HttpException(this.statusCode, this.message);

  @override
  String toString() {
    return 'HttpException: Status $statusCode, Message: $message';
  }
}