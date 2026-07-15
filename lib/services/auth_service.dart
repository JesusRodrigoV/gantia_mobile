import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_model.dart';
import '../utils/jwt_utils.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class AuthService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  String? _token;
  User? _user;

  AuthService(this._api);

  String? get token => _token;
  User? get user => _user;

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
      service._api.setToken(token);
    }
    return service;
  }

  Future<bool> login(String email, String password) async {
    final result = await execute<Map<String, dynamic>>(
      () async {
        final data = await _api.post('/auth/login', body: {
          'email': email,
          'password': password,
        });
        final response = AuthResponse.fromJson(data as Map<String, dynamic>);
        _token = response.accessToken;
        _user = response.user;
        _api.setToken(_token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        return data;
      },
      unauthorizedMessage: 'Credenciales inválidas',
    );
    notifyListeners();
    return result != null;
  }

  Future<bool> register(String email, String password) async {
    final result = await execute<Map<String, dynamic>>(
      () async {
        final data = await _api.post('/auth/register', body: {
          'email': email,
          'password': password,
        });
        final response = AuthResponse.fromJson(data as Map<String, dynamic>);
        _token = response.accessToken;
        _user = response.user;
        _api.setToken(_token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        return data;
      },
      unauthorizedMessage: 'Credenciales inválidas',
    );
    notifyListeners();
    return result != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    _token = null;
    _user = null;
    _api.setToken(null);
    notifyListeners();
  }
}
