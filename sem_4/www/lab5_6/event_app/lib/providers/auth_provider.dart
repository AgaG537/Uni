import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:event_app/api/api_service.dart';
import 'package:event_app/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = true;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    _token = await _storage.read(key: 'jwt_token');
    final userJson = await _storage.read(key: 'user_data');

    if (_token != null && userJson != null) {
      _user = User.fromJson(json.decode(userJson));
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      final responseBody = json.decode(response.body);
      _token = responseBody['token'];
      _user = User.fromJson(responseBody['user']);

      await _storage.write(key: 'jwt_token', value: _token!);
      await _storage.write(key: 'user_data', value: json.encode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // New Google Login method
  Future<void> loginWithGoogle(String idToken) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.loginWithGoogle(idToken);
      _token = result['token'];
      _user = User.fromJson(result['user']);

      await _storage.write(key: 'jwt_token', value: _token!);
      await _storage.write(key: 'user_data', value: json.encode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String username, String password, {bool isAdminRegister = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final endpoint = isAdminRegister ? '/users/register-admin' : '/users/register';
      final response = await ApiService.post(endpoint, {
        'username': username,
        'password': password,
      }, requireAuth: isAdminRegister);

      final responseBody = json.decode(response.body);
      if (!isAdminRegister) {
        _token = responseBody['token'];
        _user = User.fromJson(responseBody['user']);

        await _storage.write(key: 'jwt_token', value: _token!);
        await _storage.write(key: 'user_data', value: json.encode(_user!.toJson()));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    notifyListeners();
  }
}