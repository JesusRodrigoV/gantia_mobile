import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/models/gesture_config_model.dart';
import 'package:gantia_mobile/services/recording_service.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeWsClient fakeWs;
  late RecordingService service;

  setUp(() {
    fakeWs = FakeWsClient();
    service = RecordingService(fakeWs);
  });

  tearDown(() {
    service.dispose();
    fakeWs.dispose();
  });

  Future<void> emitAction({
    required String actionKey,
    String? value,
  }) async {
    fakeWs.emit({
      'action': 'action_triggered',
      'action_key': actionKey,
      'action_value': value ?? '',
    });
    await pumpEventQueue();
  }

  group('initial state', () {
    test('recording is false initially', () {
      expect(service.recording, isFalse);
    });

    test('capturedSteps is empty initially', () {
      expect(service.capturedSteps, isEmpty);
    });
  });

  group('start / stop / clear', () {
    test('start sets recording to true and clears previous steps', () async {
      service.start();
      await emitAction(actionKey: 'left_click');
      expect(service.capturedSteps, hasLength(1));

      service.start();

      expect(service.recording, isTrue);
      expect(service.capturedSteps, isEmpty);
    });

    test('stop sets recording to false', () {
      service.start();
      expect(service.recording, isTrue);

      service.stop();
      expect(service.recording, isFalse);
    });

    test('clear removes all captured steps', () async {
      service.start();
      await emitAction(actionKey: 'left_click');
      await emitAction(actionKey: 'right_click');
      expect(service.capturedSteps, hasLength(2));

      service.clear();

      expect(service.capturedSteps, isEmpty);
      expect(service.recording, isTrue);
    });

    test('start clears while recording stays true', () async {
      service.start();
      await emitAction(actionKey: 'left_click');
      expect(service.capturedSteps, hasLength(1));

      service.start(); // re-start

      expect(service.recording, isTrue);
      expect(service.capturedSteps, isEmpty);
    });

    test('capturedSteps returns an unmodifiable snapshot', () async {
      service.start();
      await emitAction(actionKey: 'left_click');
      expect(() => service.capturedSteps.add(const MacroStep(action: 'x')),
          throwsUnsupportedError);
    });
  });

  group('WebSocket capture', () {
    test('captures action_triggered messages when recording', () async {
      service.start();

      await emitAction(actionKey: 'left_click');

      expect(service.capturedSteps.length, 1);
      expect(service.capturedSteps[0].action, 'left_click');
    });

    test('captures action_triggered with value when recording', () async {
      service.start();

      await emitAction(actionKey: 'hotkey', value: 'ctrl,c');

      expect(service.capturedSteps.length, 1);
      expect(service.capturedSteps[0].action, 'hotkey');
      expect(service.capturedSteps[0].value, 'ctrl,c');
    });

    test('ignores empty action values', () async {
      service.start();

      await emitAction(actionKey: 'delay', value: '');

      expect(service.capturedSteps[0].value, isNull);
    });

    test('does not capture when not recording', () async {
      await emitAction(actionKey: 'left_click');

      expect(service.capturedSteps, isEmpty);
    });

    test('captures multiple actions in order', () async {
      service.start();

      await emitAction(actionKey: 'hotkey', value: 'win,d');
      await emitAction(actionKey: 'delay', value: '1');
      await emitAction(actionKey: 'left_click');

      expect(service.capturedSteps.length, 3);
      expect(service.capturedSteps[0].action, 'hotkey');
      expect(service.capturedSteps[0].value, 'win,d');
      expect(service.capturedSteps[1].action, 'delay');
      expect(service.capturedSteps[1].value, '1');
      expect(service.capturedSteps[2].action, 'left_click');
      expect(service.capturedSteps[2].value, isNull);
    });

    test('ignores non-action_triggered messages even when recording', () async {
      service.start();

      fakeWs.emit({
        'type': 'gesture_detected',
        'gesture': 'SWIPE_UP',
      });
      fakeWs.emit({
        'type': 'pong',
      });
      fakeWs.emit({'accel_x': 0.1, 'accel_y': 0.2});
      await pumpEventQueue();

      expect(service.capturedSteps, isEmpty);
    });

    test('ignores internal \$type lifecycle messages', () async {
      service.start();

      fakeWs.emit({'\$type': 'connected'});
      await pumpEventQueue();

      expect(service.capturedSteps, isEmpty);
    });

    test('captures plain action messages (no action_triggered)', () async {
      service.start();

      fakeWs.emit({'action': 'volume_up', 'action_value': ''});
      await pumpEventQueue();

      expect(service.capturedSteps, hasLength(1));
      expect(service.capturedSteps.single.action, 'volume_up');
    });

    test('ignores messages without an action key', () async {
      service.start();

      fakeWs.emit({'foo': 'bar'});
      await pumpEventQueue();

      expect(service.capturedSteps, isEmpty);
    });
  });

  group('stop returns captured steps', () {
    test('stop returns the captured list', () async {
      service.start();

      await emitAction(actionKey: 'left_click');

      final steps = service.stop();

      expect(steps.length, 1);
      expect(steps[0].action, 'left_click');
    });

    test('stop snapshot is immutable', () async {
      service.start();
      await emitAction(actionKey: 'left_click');

      final steps = service.stop();

      expect(() => steps.add(const MacroStep(action: 'x')),
          throwsUnsupportedError);
    });
  });
}