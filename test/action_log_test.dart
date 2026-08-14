import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/action_log.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeWsClient ws;
  late ActionLog log;

  setUp(() {
    ws = FakeWsClient();
    log = ActionLog(ws);
  });

  tearDown(() {
    log.dispose();
    ws.dispose();
  });

  Future<void> emitAction({
    required String actionKey,
    String? value,
  }) async {
    ws.emit({
      'action': 'action_triggered',
      'action_key': actionKey,
      'action_value': value ?? '',
    });
    await pumpEventQueue();
  }

  group('initial state', () {
    test('starts with no action and empty recent list', () {
      expect(log.actionEvent, isNull);
      expect(log.recentActions, isEmpty);
    });
  });

  group('action capture', () {
    test('captures an action_triggered event', () async {
      await emitAction(actionKey: 'volume_up');

      expect(log.actionEvent!.action, 'volume_up');
      expect(log.recentActions, hasLength(1));
    });

    test('captures the action value', () async {
      await emitAction(actionKey: 'hotkey', value: 'ctrl,c');

      expect(log.actionEvent!.actionValue, 'ctrl,c');
    });

    test('recentActions returns unmodifiable snapshot', () async {
      await emitAction(actionKey: 'volume_up');

      expect(() => log.recentActions.clear(), throwsUnsupportedError);
    });

    test('pushes new events to the front', () async {
      await emitAction(actionKey: 'volume_up');
      await emitAction(actionKey: 'volume_down');

      expect(log.recentActions.first.action, 'volume_down');
      expect(log.recentActions.last.action, 'volume_up');
    });

    test('caps the recent list at 30 events', () async {
      for (var i = 0; i < 35; i++) {
        await emitAction(actionKey: 'volume_up');
      }

      expect(log.recentActions.length, 30);
    });

    test('actionEventStream emits the latest event', () async {
      final streamed = <String>[];
      final sub = log.actionEventStream.listen((e) {
        if (e != null) streamed.add(e.action);
      });

      await emitAction(actionKey: 'next');
      await emitAction(actionKey: 'prev');

      expect(streamed, ['next', 'prev']);
      sub.cancel();
    });
  });

  group('filtering', () {
    test('ignores lifecycle messages with \$type', () async {
      ws.emit({'\$type': 'connected'});
      ws.emit({'\$type': 'reconnecting', 'attempt': 1});
      await pumpEventQueue();

      expect(log.actionEvent, isNull);
      expect(log.recentActions, isEmpty);
    });

    test('ignores telemetry messages', () async {
      ws.emit({
        'accel_x': 0.1,
        'accel_y': 0.2,
        'accel_z': 1.0,
      });
      await pumpEventQueue();

      expect(log.recentActions, isEmpty);
    });

    test('ignores gesture_detected messages', () async {
      ws.emit({'type': 'gesture_detected', 'gesture': 'Swipe', 'action': 'x'});
      await pumpEventQueue();

      expect(log.recentActions, isEmpty);
    });

    test('ignores messages without an action key', () async {
      ws.emit({'type': 'absolute_pointer_status', 'enabled': true});
      await pumpEventQueue();

      expect(log.recentActions, isEmpty);
    });
  });
}