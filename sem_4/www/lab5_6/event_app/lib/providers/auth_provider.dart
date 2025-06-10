import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/api/api_service.dart';
import 'package:event_app/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = true;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    final userJson = prefs.getString('user_data');
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _token!);
      await prefs.setString('user_data', json.encode(_user!.toJson()));

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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('user_data', json.encode(_user!.toJson()));
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    notifyListeners();
  }
}