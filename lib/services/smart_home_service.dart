import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SmartHomeService extends ChangeNotifier {
  final http.Client _client;

  SmartHomeService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> _sendCommand(String url, Map<String, Object?> body, {Map<String, String>? headers}) async {
    try {
      await _client.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint('[SmartHome] error: $e');
    }
  }

  Future<void> lightOn(String url, {Map<String, String>? headers}) async {
    await _sendCommand(url, {'command': 'on'}, headers: headers);
  }

  Future<void> lightOff(String url, {Map<String, String>? headers}) async {
    await _sendCommand(url, {'command': 'off'}, headers: headers);
  }

  Future<void> setBrightness(String url, int brightness, {Map<String, String>? headers}) async {
    await _sendCommand(url, {
      'command': 'brightness',
      'value': brightness.clamp(0, 100),
    }, headers: headers);
  }

  void dispose() {
    _client.close();
  }
}
