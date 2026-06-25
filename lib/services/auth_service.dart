import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import '../utils/jwt_utils.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api;

  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthService(this._api);

  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated =>
      _token != null &&
      _token!.isNotEmpty &&
      !isTokenExpired(_token!);

  static Future<AuthService> init(ApiService api) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final service = AuthService(api);
    if (token != null) {
      service._token = token;
    }
    return service;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      final response = AuthResponse.fromJson(data as Map<String, dynamic>);
      _token = response.accessToken;
      _user = response.user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post('/auth/register', body: {
        'email': email,
        'password': password,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
