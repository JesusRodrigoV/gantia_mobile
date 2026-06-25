import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  String _baseUrl;
  final http.Client _client;
  String? _cachedToken;

  ApiService({String baseUrl = 'http://localhost:8000', http.Client? client})
      : _baseUrl = baseUrl,
        _client = client ?? http.Client();

  String get baseUrl => _baseUrl;

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
  }

  void setToken(String? token) {
    _cachedToken = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_cachedToken != null) {
      headers['Authorization'] = 'Bearer $_cachedToken';
    }
    return headers;
  }

  Future<dynamic> _execute(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } on SocketException {
      throw NetworkException('No se pudo conectar al servidor');
    } on http.ClientException {
      throw NetworkException('Error de conexión');
    }
  }

  Future<dynamic> get(String path) async {
    return _execute(() => _client.get(
          Uri.parse('$_baseUrl$path'),
          headers: _headers(),
        ));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _execute(() => _client.post(
          Uri.parse('$_baseUrl$path'),
          headers: _headers(),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    return _execute(() => _client.put(
          Uri.parse('$_baseUrl$path'),
          headers: _headers(),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String path) async {
    return _execute(() => _client.delete(
          Uri.parse('$_baseUrl$path'),
          headers: _headers(),
        ));
  }

  void dispose() {
    _client.close();
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'No autorizado']);
}

class ServerException implements Exception {
  final int statusCode;
  final String message;
  ServerException({required this.statusCode, required this.message});
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
