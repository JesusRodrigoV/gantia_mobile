import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gantia_mobile/services/bt_service.dart';
import 'package:gantia_mobile/services/ws_client.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A controllable [WebSocketChannel] for driving [WsClient] in unit tests.
class FakeWebSocketChannel extends StreamChannelMixin<dynamic>
    implements WebSocketChannel {
  final StreamController<dynamic> _incoming = StreamController<dynamic>();
  final List<dynamic> sent = [];
  Completer<void>? _readyCompleter = Completer<void>();
  int? _closeCode;
  String? _closeReason;

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _FakeWebSocketSink(this);

  @override
  Future<void> get ready => _readyCompleter!.future;

  @override
  String? get protocol => null;

  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => _closeReason;

  void succeedHandshake() {
    _readyCompleter?.complete();
    _readyCompleter = null;
  }

  void failHandshake(Object error) {
    _readyCompleter?.completeError(error);
    _readyCompleter = null;
  }

  /// Injects a JSON text frame from the "server".
  void serverSend(String jsonText) => _incoming.add(jsonText);

  /// Emits an error on the incoming stream (simulates a stream error).
  void serverError(Object error) => _incoming.addError(error);

  /// Simulates the server closing the connection.
  void closeRemote([int? code, String? reason]) {
    _closeCode = code;
    _closeReason = reason;
    _incoming.close();
  }

  bool get isIncomingClosed => _incoming.isClosed;
}

class _FakeWebSocketSink implements WebSocketSink {
  final FakeWebSocketChannel channel;

  _FakeWebSocketSink(this.channel);

  @override
  void add(Object? event) => channel.sent.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<dynamic> stream) async {
    await for (final event in stream) {
      channel.sent.add(event);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    channel._closeCode = closeCode;
    channel._closeReason = closeReason;
    if (!channel._incoming.isClosed) {
      channel._incoming.close();
    }
  }

  @override
  Future<void> get done => channel._incoming.done;
}

/// A controllable [WsClient] fake that lets tests push messages through
/// [WsClient.messages] without touching a real socket.
class FakeWsClient implements WsClient {
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  final List<Map<String, dynamic>> sent = [];

  @override
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  int connectCalls = 0;
  int disconnectCalls = 0;

  void emit(Map<String, dynamic> message) {
    _controller.add(message);
  }

  @override
  void connect() {
    connectCalls++;
  }

  @override
  void disconnect() {
    disconnectCalls++;
  }

  @override
  void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  @override
  void send(Map<String, dynamic> data) {
    sent.add(data);
  }

  @override
  void setWsUrl(String url) {}

  @override
  bool get isConnected => true;
}

/// A [BtService] fake that records which media commands were invoked.
class FakeBtService extends ChangeNotifier implements BtService {
  final List<String> commands = [];

  @override
  String? get deviceName => 'fake';

  @override
  String? get deviceAddress => 'AA:BB:CC:DD:EE:FF';

  @override
  bool get isConnected => true;

  @override
  bool get canSendCommands => true;

  @override
  String? get connectedDevice => 'fake';

  void _record(String command) => commands.add(command);

  @override
  Future<void> playPause() async => _record('playPause');

  @override
  Future<void> next() async => _record('next');

  @override
  Future<void> prev() async => _record('prev');

  @override
  Future<void> volumeUp() async => _record('volumeUp');

  @override
  Future<void> volumeDown() async => _record('volumeDown');

  @override
  Future<void> mute() async => _record('mute');

  @override
  Future<void> refresh() async {}
}

/// Builds a well-formed JWT payload with the given [exp] (unix seconds).
String fakeJwt({required int exp}) {
  final header =
      base64UrlEncode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64UrlEncode(utf8.encode(jsonEncode({
    'sub': '1',
    'email': 'test@example.com',
    'exp': exp,
  })));
  return '$header.$payload.sig';
}

String fakeJwtExpired() =>
    fakeJwt(exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600);

String fakeJwtValid() =>
    fakeJwt(exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600);