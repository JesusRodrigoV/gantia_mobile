import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';

enum _ConnectionAttemptState { idle, connecting }

class WsClient {
  final AuthService _authService;
  String _wsUrl;

  WsClient(this._authService, {required String wsUrl}) : _wsUrl = wsUrl;

  void setWsUrl(String url) {
    if (_wsUrl == url) return;
    _wsUrl = url;
    if (_shouldBeConnected) {
      disconnect();
      connect();
    }
  }

  static const int maxRetries = 10;
  static const Duration baseReconnectDelay = Duration(seconds: 1);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const Duration pingInterval = Duration(seconds: 25);
  static const Duration pongTimeoutDuration = Duration(seconds: 20);
  static const Duration connectionTimeout = Duration(seconds: 10);

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _shouldBeConnected = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  Timer? _pingTimer;
  Timer? _pongTimer;
  Timer? _connectionTimer;
  _ConnectionAttemptState _connectionAttemptState = _ConnectionAttemptState.idle;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _controller.stream;
  bool get isConnected => _channel != null && _channel!.closeCode == null;

  void connect() {
    if (_disposed) return;
    _shouldBeConnected = true;
    _establishConnection();
  }

  void disconnect() {
    _shouldBeConnected = false;
    _clearReconnectTimer();
    _clearPingTimer();
    _closeChannel();
  }

  void send(Map<String, dynamic> data) {
    if (!isConnected) return;
    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      debugPrint('[WsClient] send error: $e');
    }
  }

  bool get _canAddToController => !_disposed && !_controller.isClosed;

  void _safeAdd(Map<String, dynamic> data) {
    if (_canAddToController) {
      _controller.add(data);
    }
  }

  void _establishConnection() {
    if (_disposed) return;
    if (_connectionAttemptState == _ConnectionAttemptState.connecting) return;
    if (!_validateToken()) return;

    _connectionAttemptState = _ConnectionAttemptState.connecting;
    _clearReconnectTimer();
    _startConnectionTimeout();
    _safeAdd({'\$type': 'connecting'});

    try {
      _channel = WebSocketChannel.connect(_buildUri());
      _channel!.ready.then((_) {
        if (_disposed) return;
        _resetRetryState();
      }).catchError((Object error) {
        if (_disposed) return;
        debugPrint('[WsClient] ready error: $error');
        _onConnectionFailed();
      });

      _channel!.stream.listen(
        _onStreamData,
        onError: (Object error) {
          if (_disposed) return;
          debugPrint('[WsClient] stream error: $error');
          _onConnectionFailed();
        },
        onDone: _onStreamDone,
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('[WsClient] connect exception: $e');
      _onConnectionFailed();
    }
  }

  bool _validateToken() {
    final token = _authService.token;
    if (token == null || token.isEmpty || !_authService.isAuthenticated) {
      _authService.logout();
      _finishAttempt();
      return false;
    }
    return true;
  }

  Uri _buildUri() {
    final token = _authService.token!;
    return Uri.parse('$_wsUrl/ws/dashboard?token=${Uri.encodeQueryComponent(token)}');
  }

  void _startConnectionTimeout() {
    _connectionTimer = Timer(connectionTimeout, () {
      if (_disposed) return;
      _safeAdd({'\$type': 'error'});
      _closeChannel();
      _finishAttempt();
      if (_shouldBeConnected) _scheduleReconnect();
    });
  }

  void _onConnectionFailed() {
    _finishAttempt();
    _closeChannel();
    _safeAdd({'\$type': 'error'});
    if (_shouldBeConnected) _scheduleReconnect();
  }

  void _onStreamData(dynamic data) {
    if (_disposed) return;
    if (data is! String) {
      debugPrint('[WsClient] ignoring non-text frame: ${data.runtimeType}');
      return;
    }
    try {
      final parsed = jsonDecode(data) as Map<String, dynamic>;

      if (parsed['type'] == 'pong') {
        _clearPongTimer();
        return;
      }

      if (parsed['type'] == 'ping') {
        send({'type': 'pong'});
        return;
      }

      _safeAdd(parsed);
    } catch (_) {}
  }

  void _onStreamDone() {
    if (_disposed) return;
    final closeCode = _channel?.closeCode;
    if (closeCode == 1008) {
      debugPrint('[WsClient] Token rechazado por el servidor — cerrando sesión');
      _shouldBeConnected = false;
      _authService.logout();
    }
    _finishAttempt();
    _clearPingTimer();
    _safeAdd({'\$type': 'disconnected'});
    if (_shouldBeConnected && _authService.isAuthenticated) {
      _scheduleReconnect();
    }
  }

  void _finishAttempt() {
    _connectionAttemptState = _ConnectionAttemptState.idle;
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _clearReconnectTimer();
    _reconnectAttempts++;
    _safeAdd({
      '\$type': 'reconnecting',
      'attempt': _reconnectAttempts,
      'maxRetries': maxRetries,
    });

    if (_reconnectAttempts > maxRetries) {
      _safeAdd({
        '\$type': 'disconnected',
        'reason': 'max_retries_exceeded',
      });
      return;
    }

    final delayMs = (baseReconnectDelay.inMilliseconds *
            pow(2, _reconnectAttempts - 1))
        .toInt();
    final cappedMs = min(delayMs, maxReconnectDelay.inMilliseconds);
    _reconnectTimer = Timer(Duration(milliseconds: cappedMs), () {
      _establishConnection();
    });
  }

  void _resetRetryState() {
    _reconnectAttempts = 0;
    _finishAttempt();
    _safeAdd({'\$type': 'connected'});
    _startPingTimer();
  }

  void _startPingTimer() {
    _clearPingTimer();
    _pingTimer = Timer.periodic(pingInterval, (_) {
      send({'type': 'ping'});
      _pongTimer = Timer(pongTimeoutDuration, () {
        debugPrint('[WsClient] Pong timeout fired — closing channel');
        _clearPingTimer();
        _closeChannel();
      });
    });
  }

  void _clearPongTimer() {
    _pongTimer?.cancel();
    _pongTimer = null;
  }

  void _clearPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _clearPongTimer();
  }

  void _clearReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _closeChannel() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _shouldBeConnected = false;
    _clearReconnectTimer();
    _clearPingTimer();
    _finishAttempt();
    _closeChannel();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
