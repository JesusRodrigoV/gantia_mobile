import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/action_message.dart';
import 'ws_client.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting, error }

class GloveState extends ChangeNotifier {
  final WsClient _client;
  StreamSubscription<Map<String, dynamic>>? _sub;

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  bool _dataFlowing = false;
  bool get dataFlowing => _dataFlowing;

  bool _waitingForDevice = false;
  bool get waitingForDevice => _waitingForDevice;

  GloveTelemetry? _telemetry;
  GloveTelemetry? get telemetry => _telemetry;

  GestureDetectedEvent? _gestureDetected;
  GestureDetectedEvent? get gestureDetected => _gestureDetected;

  String _currentMode = 'GLOBAL';
  String get currentMode => _currentMode;

  bool _mouseModeActive = false;
  bool get mouseModeActive => _mouseModeActive;

  bool _absolutePointerEnabled = false;
  bool get absolutePointerEnabled => _absolutePointerEnabled;

  int _retryAttempt = 0;
  int _maxRetries = 10;
  int get retryAttempt => _retryAttempt;
  int get maxRetries => _maxRetries;

  int _lastTelemetryUpdate = 0;
  Timer? _dataTimer;
  Timer? _waitingTimer;

  static const int _dataTimeoutMs = 3000;
  static const int _waitingTimeoutMs = 7000;
  static const int _telemetryThrottleMs = 33;

  GloveState(this._client) {
    _sub = _client.messages.listen(_handleRawMessage);
  }

  void _handleRawMessage(Map<String, dynamic> data) {
    final type = data['\$type'];

    if (type != null) {
      switch (type) {
        case 'connecting':
          _connectionStatus = ConnectionStatus.connecting;
          notifyListeners();
          return;
        case 'connected':
          _connectionStatus = ConnectionStatus.connected;
          _retryAttempt = 0;
          _waitingForDevice = false;
          _cancelWaitingTimer();
          _waitingTimer = Timer(
            Duration(milliseconds: _waitingTimeoutMs),
            () {
              if (_telemetry == null) {
                _waitingForDevice = true;
                notifyListeners();
              }
            },
          );
          notifyListeners();
          return;
        case 'reconnecting':
          _connectionStatus = ConnectionStatus.reconnecting;
          _retryAttempt = data['attempt'] ?? 0;
          _maxRetries = data['maxRetries'] ?? 10;
          notifyListeners();
          return;
        case 'disconnected':
          _connectionStatus = ConnectionStatus.disconnected;
          _dataFlowing = false;
          _waitingForDevice = false;
          _cancelWaitingTimer();
          _dataTimer?.cancel();
          notifyListeners();
          return;
        case 'error':
          _connectionStatus = ConnectionStatus.error;
          _telemetry = null;
          _dataFlowing = false;
          notifyListeners();
          return;
      }
      return;
    }

    if (isGestureDetected(data)) {
      _gestureDetected = GestureDetectedEvent.fromJson(data);
      notifyListeners();
      return;
    }

    if (isActionMessage(data)) {
      final evt = ActionEvent.fromJson(data);

      if (evt.action == 'mouse_mode') {
        final newVal = data['action_value'];
        if (newVal != _mouseModeActive) {
          _mouseModeActive = newVal == true || newVal == 'ON';
        }
      }

      if (evt.action == 'mode_changed') {
        _currentMode = evt.actionValue.toString().toUpperCase();
      }

      notifyListeners();
      return;
    }

    // Absolute pointer status message
    if (data['type'] == 'absolute_pointer_status') {
      _absolutePointerEnabled = data['enabled'] == true;
      _cancelWaitingTimer();
      notifyListeners();
      return;
    }

    if (isTelemetryData(data)) {
      _scheduleTelemetryUpdate(GloveTelemetry.fromJson(data));
      _cancelWaitingTimer();
      _waitingForDevice = false;
      _resetDataTimeout();
    }
  }

  void sendToggleAbsolutePointer(bool enabled) {
    _client.send({'type': 'toggle_absolute_pointer', 'enabled': enabled});
  }

  void changeMode(String mode) {
    _currentMode = mode;
    _client.send({'action': 'set_mode', 'value': mode});
    notifyListeners();
  }

  void _resetDataTimeout() {
    _dataTimer?.cancel();
    _dataFlowing = true;
    _dataTimer = Timer(Duration(milliseconds: _dataTimeoutMs), () {
      _dataFlowing = false;
      notifyListeners();
    });
    notifyListeners();
  }

  void _scheduleTelemetryUpdate(GloveTelemetry data) {
    _telemetry = data;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTelemetryUpdate >= _telemetryThrottleMs) {
      _lastTelemetryUpdate = now;
      notifyListeners();
    }
  }

  void _cancelWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dataTimer?.cancel();
    _cancelWaitingTimer();
    super.dispose();
  }
}
