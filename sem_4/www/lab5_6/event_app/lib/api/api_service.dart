import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String get _baseUrl {
    if (kIsWeb) {
      return dotenv.env['LOCAL_API_URL_WEB'] ?? 'http://localhost:3000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['LOCAL_API_URL_ANDROID'] ?? 'http://10.0.2.2:3000/api';
    } else {
      return dotenv.env['LOCAL_API_URL_IOS'] ?? 'http://localhost:3000/api';
    }
  }

  static Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth) {
      final token = await _storage.read(key: 'jwt_token');
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

  // Method for Google login
  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final uri = Uri.parse('$_baseUrl/auth/google');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'];
      final role = body['user']['role'];
      final id = body['user']['id'];
      final username = body['user']['username'];

      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: 'user_data', value: jsonEncode({'id': id, 'username': username, 'role': role}));

      return {'token': token, 'user': {'id': id, 'username': username, 'role': role}};
    } else {
      _handleResponseError(response); // Use common error handler
      throw Exception('Google login failed with status ${response.statusCode}');
    }
  }


  // Error handling utility
  static void _handleResponseError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = 'An error occurred';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
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
