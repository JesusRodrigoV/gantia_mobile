import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/action_message.dart';
import '../utils/jwt_utils.dart';
import 'auth_service.dart';

class WsService extends ChangeNotifier {
  final AuthService _authService;
  final String _wsUrl;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _dataTimer;
  Timer? _waitingTimer;
  int _refCount = 0;
  bool _shouldBeConnected = false;
  bool _disposed = false;

  static const int _reconnectDelayMs = 5000;
  static const int _dataTimeoutMs = 3000;
  static const int _waitingTimeoutMs = 7000;
  static const int _telemetryThrottleMs = 33;
  static const int _maxRecentActions = 30;

  // Signals
  GloveTelemetry? _telemetry;
  GloveTelemetry? get telemetry => _telemetry;

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  ConnectionStatus get connectionStatus => _connectionStatus;

  ActionEvent? _actionEvent;
  ActionEvent? get actionEvent => _actionEvent;

  List<ActionEvent> _recentActions = [];
  List<ActionEvent> get recentActions => List.unmodifiable(_recentActions);

  GestureDetectedEvent? _gestureDetected;
  GestureDetectedEvent? get gestureDetected => _gestureDetected;

  bool _mouseModeActive = false;
  bool get mouseModeActive => _mouseModeActive;

  String _currentMode = 'GLOBAL';
  String get currentMode => _currentMode;

  bool _dataFlowing = false;
  bool get dataFlowing => _dataFlowing;

  bool _waitingForDevice = false;
  bool get waitingForDevice => _waitingForDevice;

  dynamic _lastMouseModeValue;
  int _lastTelemetryUpdate = 0;

  WsService(this._authService, {String wsUrl = 'ws://localhost:8000'})
      : _wsUrl = wsUrl;

  String get _fullWsUrl {
    final token = _authService.token ?? '';
    return '$_wsUrl/ws/dashboard?token=$token';
  }

  void connect() {
    if (_disposed) return;
    final firstConnection = _refCount == 0;
    _refCount++;

    if (!firstConnection) return;

    _shouldBeConnected = true;
    _establishConnection();
  }

  void disconnect() {
    if (_disposed) return;
    if (_refCount > 0) _refCount--;

    if (_refCount > 0) return;

    _shouldBeConnected = false;
    _clearReconnectTimer();
    _cancelWaitingTimer();
    _dataTimer?.cancel();
    _closeChannel();
    _connectionStatus = ConnectionStatus.disconnected;
    notifyListeners();
  }

  void _establishConnection() {
    final token = _authService.token;
    if (token == null || token.isEmpty) {
      _connectionStatus = ConnectionStatus.error;
      notifyListeners();
      return;
    }

    if (!_authService.isAuthenticated || isTokenExpired(token)) {
      _authService.logout();
      return;
    }

    _clearReconnectTimer();
    _connectionStatus = ConnectionStatus.connecting;
    notifyListeners();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_fullWsUrl));

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // WebSocket channel doesn't have onOpen directly,
      // but the first message acts as confirmation
      _connectionStatus = ConnectionStatus.connected;
      _waitingForDevice = false;
      _waitingTimer = Timer(Duration(milliseconds: _waitingTimeoutMs), () {
        if (_telemetry == null) {
          _waitingForDevice = true;
          notifyListeners();
        }
      });
      notifyListeners();
    } catch (e) {
      _connectionStatus = ConnectionStatus.error;
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      if (isGestureDetected(data)) {
        _gestureDetected = GestureDetectedEvent.fromJson(data);
        notifyListeners();
        return;
      }

      if (isActionMessage(data)) {
        final evt = ActionEvent.fromJson(data);
        _actionEvent = evt;
        _recentActions = [evt, ..._recentActions].take(_maxRecentActions).toList();

        if (evt.action == 'mouse_mode') {
          final newVal = data['action_value'];
          if (newVal != _lastMouseModeValue) {
            _lastMouseModeValue = newVal;
            _mouseModeActive = newVal == true || newVal == 'ON';
          }
        }

        if (evt.action == 'mode_changed') {
          _currentMode = evt.actionValue.toString().toUpperCase();
        }

        notifyListeners();
        return;
      }

      if (isTelemetryData(data)) {
        _scheduleTelemetryUpdate(GloveTelemetry.fromJson(data));
        _cancelWaitingTimer();
        _waitingForDevice = false;
        _resetDataTimeout();
      }
    } catch (e) {
      debugPrint('[WsService] Failed to parse message: $message');
    }
  }

  void _onError(dynamic error) {
    _connectionStatus = ConnectionStatus.error;
    _telemetry = null;
    _dataFlowing = false;
    notifyListeners();
  }

  void _onDone() {
    _connectionStatus = ConnectionStatus.disconnected;
    _dataFlowing = false;
    _waitingForDevice = false;
    _cancelWaitingTimer();
    _dataTimer?.cancel();

    if (_shouldBeConnected && _authService.isAuthenticated) {
      final token = _authService.token;
      if (token != null && isTokenExpired(token)) {
        _authService.logout();
        return;
      }
      _scheduleReconnect();
    }
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
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTelemetryUpdate >= _telemetryThrottleMs) {
      _telemetry = data;
      _lastTelemetryUpdate = now;
      notifyListeners();
    }
  }

  void _scheduleReconnect() {
    _clearReconnectTimer();
    _reconnectTimer = Timer(
      Duration(milliseconds: _reconnectDelayMs),
      _establishConnection,
    );
  }

  void _clearReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cancelWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
  }

  void _closeChannel() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _shouldBeConnected = false;
    _refCount = 0;
    _clearReconnectTimer();
    _cancelWaitingTimer();
    _dataTimer?.cancel();
    _closeChannel();
    super.dispose();
  }
}

enum ConnectionStatus { disconnected, connecting, connected, error }
