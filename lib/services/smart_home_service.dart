import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class SmartHomeService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  String? _lastError;
  String? _lastDeviceUrl;
  bool _commandInProgress = false;

  String? get lastError => _lastError;
  String? get lastDeviceUrl => _lastDeviceUrl;
  bool get commandInProgress => _commandInProgress;

  SmartHomeService(this._api);

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

    final result = await execute(() => _api.rawPost(url, body: body, headers: headers));
    _commandInProgress = false;

    if (result == null) {
      _lastError = 'No se pudo conectar al dispositivo';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
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
}
