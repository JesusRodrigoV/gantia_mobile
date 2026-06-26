import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';
import '../utils/jwt_utils.dart';

enum _ConnectionAttemptState { idle, connecting }

class WsClient {
  final AuthService _authService;
  final String _wsUrl;

  WsClient(this._authService, {required String wsUrl}) : _wsUrl = wsUrl;

  static const int maxRetries = 10;
  static const Duration baseReconnectDelay = Duration(seconds: 1);
  static const Duration maxReconnectDelay = Duration(seconds: 30);
  static const Duration pingInterval = Duration(seconds: 30);
  static const Duration pongTimeoutDuration = Duration(seconds: 10);
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
    _channel!.sink.add(jsonEncode(data));
  }

  void _establishConnection() {
    if (_connectionAttemptState == _ConnectionAttemptState.connecting) return;
    _connectionAttemptState = _ConnectionAttemptState.connecting;

    final token = _authService.token;
    if (token == null || token.isEmpty || !_authService.isAuthenticated) {
      _authService.logout();
      _finishAttempt();
      return;
    }

    _clearReconnectTimer();
    _connectionTimer = Timer(connectionTimeout, () {
      _controller.add({'\$type': 'error'});
      _closeChannel();
      _finishAttempt();
      if (_shouldBeConnected) _scheduleReconnect();
    });

    _controller.add({'\$type': 'connecting'});

    try {
      _channel = WebSocketChannel.connect(Uri.parse('$_wsUrl/ws/dashboard'));

      _channel!.stream.listen(
        (data) {
          try {
            final parsed = jsonDecode(data as String) as Map<String, dynamic>;

            if (parsed['\$type'] == 'pong') {
              _clearPongTimer();
              return;
            }

            if (parsed['type'] == 'ping') {
              send({'type': 'pong'});
              return;
            }

            if (parsed['\$type'] == 'auth_ok') {
              _connectionTimer?.cancel();
              _resetRetryState();
            }

            _controller.add(parsed);
          } catch (_) {}
        },
        onError: (_) {
          _finishAttempt();
          _controller.add({'\$type': 'error'});
          if (_shouldBeConnected) _scheduleReconnect();
        },
        onDone: () {
          _finishAttempt();
          _clearPingTimer();
          _controller.add({'\$type': 'disconnected'});
          if (_shouldBeConnected && _authService.isAuthenticated) {
            _scheduleReconnect();
          }
        },
        cancelOnError: false,
      );

      _channel!.sink.add(jsonEncode({
        '\$type': 'auth',
        'token': token,
      }));
    } catch (_) {
      _finishAttempt();
      _controller.add({'\$type': 'error'});
      if (_shouldBeConnected) _scheduleReconnect();
    }
  }

  void _finishAttempt() {
    _connectionAttemptState = _ConnectionAttemptState.idle;
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  void _scheduleReconnect() {
    _clearReconnectTimer();
    _reconnectAttempts++;
    _controller.add({
      '\$type': 'reconnecting',
      'attempt': _reconnectAttempts,
      'maxRetries': maxRetries,
    });

    if (_reconnectAttempts > maxRetries) {
      _controller.add({
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
    _controller.add({'\$type': 'connected'});
    _startPingTimer();
  }

  void _startPingTimer() {
    _clearPingTimer();
    _pingTimer = Timer.periodic(pingInterval, (_) {
      send({'type': 'ping'});
      _pongTimer = Timer(pongTimeoutDuration, () {
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
    _controller.close();
  }
}
