import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';

class WsClient {
  final AuthService _authService;
  final String _wsUrl;

  WsClient(this._authService, {required String wsUrl}) : _wsUrl = wsUrl;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _shouldBeConnected = false;
  bool _disposed = false;

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
    _closeChannel();
  }

  void send(Map<String, dynamic> data) {
    if (!isConnected) return;
    _channel!.sink.add(jsonEncode(data));
  }

  void _establishConnection() {
    final token = _authService.token;
    if (token == null || token.isEmpty || !_authService.isAuthenticated) {
      _authService.logout();
      return;
    }

    _clearReconnectTimer();
    _controller.add({'\$type': 'connecting'});

    try {
      _channel = WebSocketChannel.connect(Uri.parse('$_wsUrl/ws/dashboard'));

      _channel!.stream.listen(
        (data) {
          try {
            final parsed = jsonDecode(data as String) as Map<String, dynamic>;
            _controller.add(parsed);
          } catch (_) {}
        },
        onError: (_) {
          _controller.add({'\$type': 'error'});
          _scheduleReconnect();
        },
        onDone: () {
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
      _controller.add({'\$type': 'error'});
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _clearReconnectTimer();
    _reconnectTimer = Timer(
      const Duration(milliseconds: 5000),
      _establishConnection,
    );
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
    _closeChannel();
    _controller.close();
  }
}
