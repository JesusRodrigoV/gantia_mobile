import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/auth_service.dart';
import 'package:gantia_mobile/services/ws_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

void main() {
  late AuthService auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': fakeJwtValid()});
    auth = await AuthService.init(ApiService());
  });

  List<Map<String, dynamic>> listen(WsClient ws) {
    final events = <Map<String, dynamic>>[];
    ws.messages.listen(events.add);
    return events;
  }

  WsClient buildWs(
    FakeWebSocketChannel channel, {
    List<FakeWebSocketChannel>? channels,
    AuthService? authService,
  }) {
    var index = 0;
    return WsClient(
      authService ?? auth,
      wsUrl: 'ws://test-host',
      channelFactory: (_) => channels != null ? channels[index++] : channel,
    );
  }

  List<String> types(List<Map<String, dynamic>> events) =>
      [for (final e in events) e['\$type'] as String?]
          .whereType<String>()
          .toList();

  group('connect / handshake', () {
    test('emits connecting when connect() is called', () {
      fakeAsync((async) {
        final ws = buildWs(FakeWebSocketChannel());
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        expect(types(events), ['connecting']);
      });
    });

    test('sends the auth token after handshake succeeds', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        expect(
          channel.sent,
          contains('{"type":"auth","token":"${auth.token}"}'),
        );
      });
    });

    test('emits connected and resets retry state after handshake', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        expect(types(events), ['connecting', 'connected']);
        expect(ws.isConnected, isTrue);
      });
    });

    test('connect() is a no-op when already connected', () {
      fakeAsync((async) {
        final channels = [FakeWebSocketChannel(), FakeWebSocketChannel()];
        final ws = buildWs(channels.first, channels: channels);
        listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channels.first.succeedHandshake();
        async.flushMicrotasks();

        ws.connect();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));

        expect(ws.isConnected, isTrue);
        // No second channel was ever created.
        expect(channels[1].isIncomingClosed, isFalse);
      });
    });

    test('invalid token logs the user out and never opens a channel',
        () async {
      SharedPreferences.setMockInitialValues({'token': fakeJwtExpired()});
      final expiredAuth = await AuthService.init(ApiService());
      var opened = 0;
      final ws = WsClient(
        expiredAuth,
        wsUrl: 'ws://test-host',
        channelFactory: (uri) {
          opened++;
          return FakeWebSocketChannel();
        },
      );
      listen(ws);
      ws.connect();
      await Future<void>.delayed(Duration.zero);

      expect(opened, 0);
      expect(expiredAuth.isAuthenticated, isFalse);
    });
  });

  group('message handling', () {
    test('replies pong to a server ping', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        channel.serverSend('{"type":"ping"}');
        async.flushMicrotasks();

        expect(channel.sent, contains('{"type":"pong"}'));
      });
    });

    test('clears the pong timer when a pong arrives (no reconnect)', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 25));
        channel.serverSend('{"type":"pong"}');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 20));

        expect(ws.isConnected, isTrue);
        expect(events.where((e) => e['\$type'] == 'reconnecting'), isEmpty);
      });
    });

    test('keeps the connection alive across two ping/pong cycles', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 25));
        channel.serverSend('{"type":"pong"}');
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 25));
        channel.serverSend('{"type":"pong"}');
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 20));

        expect(ws.isConnected, isTrue);
        expect(events.where((e) => e['\$type'] == 'reconnecting'), isEmpty);
        expect(channel.sent.where((m) => m == '{"type":"ping"}').length, 2);
      });
    });

    test('pong timeout closes the channel and schedules a reconnect', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 25));
        async.elapse(const Duration(seconds: 20));

        expect(types(events), containsAll(['disconnected', 'reconnecting']));
        expect(events.last['attempt'], 1);
        expect(ws.isConnected, isFalse);
      });
    });

    test('forwards server messages to the stream', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        channel.serverSend('{"hello":"world"}');
        async.flushMicrotasks();

        expect(
          events.where((e) => !e.containsKey('\$type')).single,
          equals({'hello': 'world'}),
        );
      });
    });
  });

  group('reconnect logic', () {
    test('handshake error schedules a reconnect', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.failHandshake(const FormatException('boom'));
        async.flushMicrotasks();

        expect(types(events), containsAll(['error', 'reconnecting']));
        expect(events.last['attempt'], 1);
      });
    });

    test('stream error schedules a reconnect', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();
        channel.serverError(const FormatException('boom'));
        async.flushMicrotasks();

        expect(types(events), containsAll(['error', 'reconnecting']));
        expect(events.last['attempt'], 1);
      });
    });

    test('connection timeout schedules exactly one reconnect per attempt', () {
      fakeAsync((async) {
        final channels = [FakeWebSocketChannel(), FakeWebSocketChannel()];
        final ws = buildWs(channels.first, channels: channels);
        final events = listen(ws);

        ws.connect();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        expect(events.last['attempt'], 1);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(channels[1].isIncomingClosed, isFalse);

        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        expect(events.last['attempt'], 2);

        final reconnecting =
            events.where((e) => e['\$type'] == 'reconnecting').toList();
        expect(reconnecting, hasLength(2));
        expect(reconnecting.map((e) => e['attempt']), [1, 2]);
      });
    });

    test('a stale onDone from an old channel never double-schedules', () {
      fakeAsync((async) {
        final oldChannel = FakeWebSocketChannel();
        final newChannel = FakeWebSocketChannel();
        final channels = [oldChannel, newChannel];
        final ws = buildWs(oldChannel, channels: channels);
        final events = listen(ws);

        ws.connect();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));
        newChannel.succeedHandshake();
        async.flushMicrotasks();
        async.flushMicrotasks();

        final reconnecting =
            events.where((e) => e['\$type'] == 'reconnecting').toList();
        expect(reconnecting, hasLength(1));
        expect(reconnecting.first['attempt'], 1);
        expect(types(events), [
          'connecting',
          'error',
          'reconnecting',
          'connecting',
          'connected',
        ]);
      });
    });

    test('reconnect backoff doubles and caps at 30s', () {
      fakeAsync((async) {
        final channels = List.generate(8, (_) => FakeWebSocketChannel());
        var index = 0;
        final ws = WsClient(
          auth,
          wsUrl: 'ws://test-host',
          channelFactory: (_) => channels[index++],
        );
        final events = listen(ws);

        ws.connect();
        channels[0].failHandshake(const FormatException('x'));
        async.flushMicrotasks();
        expect(events.last['attempt'], 1);

        void failNext([Duration? delay]) {
          if (delay != null) async.elapse(delay);
          final channel = channels[index - 1];
          channel.failHandshake(const FormatException('x'));
          async.flushMicrotasks();
        }

        failNext(const Duration(seconds: 1));
        expect(events.last['attempt'], 2);

        failNext(const Duration(seconds: 2));
        expect(events.last['attempt'], 3);

        failNext(const Duration(seconds: 4));
        expect(events.last['attempt'], 4);

        failNext(const Duration(seconds: 8));
        expect(events.last['attempt'], 5);

        failNext(const Duration(seconds: 16));
        expect(events.last['attempt'], 6);

        failNext(const Duration(seconds: 30));
        expect(events.last['attempt'], 7);
      });
    });

    test('remote close while connected schedules a reconnect for attempt 1', () {
      fakeAsync((async) {
        final channels = [FakeWebSocketChannel(), FakeWebSocketChannel()];
        final ws = buildWs(channels.first, channels: channels);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channels.first.succeedHandshake();
        async.flushMicrotasks();

        channels.first.closeRemote();
        async.flushMicrotasks();

        expect(types(events), containsAll(['disconnected', 'reconnecting']));
        expect(events.last['attempt'], 1);

        async.elapse(const Duration(seconds: 1));
        expect(channels[1].isIncomingClosed, isFalse);
      });
    });

    test('close code 1008 logs the user out and disables reconnecting', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        channel.closeRemote(1008);
        async.flushMicrotasks();

        expect(auth.token, isNull);
        expect(auth.isAuthenticated, isFalse);
        expect(events.where((e) => e['\$type'] == 'reconnecting'), isEmpty);
        expect(ws.isConnected, isFalse);
      });
    });

    test('stops reconnecting after maxRetries', () {
      fakeAsync((async) {
        final channels = List.generate(11, (_) => FakeWebSocketChannel());
        var index = 0;
        final ws = WsClient(
          auth,
          wsUrl: 'ws://test-host',
          channelFactory: (_) => channels[index++],
        );
        final events = listen(ws);

        ws.connect();
        async.flushMicrotasks();

        // First attempt times out after the connection timeout.
        async.elapse(const Duration(seconds: 10));

        const delays = [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
          Duration(seconds: 8),
          Duration(seconds: 16),
          Duration(seconds: 30),
          Duration(seconds: 30),
          Duration(seconds: 30),
          Duration(seconds: 30),
          Duration(seconds: 30),
        ];
        for (final delay in delays) {
          async.elapse(delay); // reconnect timer -> new attempt
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 10)); // that attempt times out
          async.flushMicrotasks();
        }
        async.flushMicrotasks();

        final reconnecting =
            events.where((e) => e['\$type'] == 'reconnecting').toList();
        expect(reconnecting, hasLength(WsClient.maxRetries));
        expect(events.last, containsPair('reason', 'max_retries_exceeded'));
      });
    });
  });

  group('lifecycle', () {
    test('disconnect() closes the channel and stops reconnecting', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        final events = listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        ws.disconnect();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 60));

        expect(ws.isConnected, isFalse);
        expect(events.where((e) => e['\$type'] == 'reconnecting'), isEmpty);
        expect(channel.isIncomingClosed, isTrue);
      });
    });

    test('dispose() closes the message controller', () {
      fakeAsync((async) {
        final channel = FakeWebSocketChannel();
        final ws = buildWs(channel);
        listen(ws);
        ws.connect();
        async.flushMicrotasks();
        channel.succeedHandshake();
        async.flushMicrotasks();

        ws.dispose();

        expect(ws.isConnected, isFalse);
      });
    });
  });
}