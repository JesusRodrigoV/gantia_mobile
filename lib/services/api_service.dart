import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  String _baseUrl;
  final http.Client _client;

  ApiService({String baseUrl = 'http://localhost:8000', http.Client? client})
      : _baseUrl = baseUrl,
        _client = client ?? http.Client();

  String get baseUrl => _baseUrl;

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    _checkAuth(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    _checkAuth(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    _checkAuth(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    _checkAuth(response);
    return jsonDecode(response.body);
  }

  void _checkAuth(http.Response response) {
    if (response.statusCode == 401) {
      // Token expired or invalid — trigger logout
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('token');
      });
      throw UnauthorizedException();
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'No autorizado']);
}
