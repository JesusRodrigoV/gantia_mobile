import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SmartHomeService extends ChangeNotifier {
  final http.Client _client;

  SmartHomeService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> lightOn(String url, {Map<String, String>? headers}) async {
    try {
      await _client.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode({'command': 'on'}),
      );
    } catch (e) {
      debugPrint('[SmartHome] lightOn error: $e');
    }
  }

  Future<void> lightOff(String url, {Map<String, String>? headers}) async {
    try {
      await _client.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode({'command': 'off'}),
      );
    } catch (e) {
      debugPrint('[SmartHome] lightOff error: $e');
    }
  }

  Future<void> setBrightness(String url, int brightness, {Map<String, String>? headers}) async {
    try {
      await _client.post(
        Uri.parse(url),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode({'command': 'brightness', 'value': brightness.clamp(0, 100)}),
      );
    } catch (e) {
      debugPrint('[SmartHome] setBrightness error: $e');
    }
  }
}
