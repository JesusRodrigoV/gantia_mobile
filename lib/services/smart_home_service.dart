import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SmartHomeService extends ChangeNotifier {
  final http.Client _client;

  String? _lastError;
  String? _lastDeviceUrl;
  bool _commandInProgress = false;

  String? get lastError => _lastError;
  String? get lastDeviceUrl => _lastDeviceUrl;
  bool get commandInProgress => _commandInProgress;

  SmartHomeService({http.Client? client}) : _client = client ?? http.Client();

  void clearError() {
    if (_lastError != null) {
      _lastError = null;
      _lastDeviceUrl = null;
      notifyListeners();
    }
  }

  Future<bool> _sendCommand(String url, Map<String, Object?> body, {Map<String, String>? headers}) async {
    _lastError = null;
    _lastDeviceUrl = url;
    _commandInProgress = true;
    notifyListeners();

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _commandInProgress = false;
        notifyListeners();
        return true;
      }
      _lastError = 'Error HTTP ${response.statusCode}';
      _commandInProgress = false;
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = 'No se pudo conectar al dispositivo';
      _commandInProgress = false;
      debugPrint('[SmartHome] error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> lightOn(String url, {Map<String, String>? headers}) async {
    return _sendCommand(url, {'command': 'on'}, headers: headers);
  }

  Future<bool> lightOff(String url, {Map<String, String>? headers}) async {
    return _sendCommand(url, {'command': 'off'}, headers: headers);
  }

  Future<bool> setBrightness(String url, int brightness, {Map<String, String>? headers}) async {
    return _sendCommand(url, {
      'command': 'brightness',
      'value': brightness.clamp(0, 100),
    }, headers: headers);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
