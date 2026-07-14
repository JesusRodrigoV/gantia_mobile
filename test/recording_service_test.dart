import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/models/gesture_config_model.dart';
import 'package:gantia_mobile/services/recording_service.dart';
import 'package:gantia_mobile/services/ws_client.dart';

/// A fake WsClient that lets us inject messages for testing.
class FakeWsClient implements WsClient {
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  void emit(Map<String, dynamic> message) {
    _controller.add(message);
  }

  @override
  void connect() {}

  @override
  void disconnect() {}

  @override
  void dispose() {
    _controller.close();
  }

  @override
  void send(Map<String, dynamic> data) {}

  @override
  void setWsUrl(String url) {}

  @override
  bool get isConnected => true;
}

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

  group('initial state', () {
    test('recording is false initially', () {
      expect(service.recording, isFalse);
    });

    test('capturedSteps is empty initially', () {
      expect(service.capturedSteps, isEmpty);
    });
  });

  group('start / stop / clear', () {
    test('start sets recording to true and clears steps', () {
      // Pre-populate some steps
      service.capturedSteps
          .add(const MacroStep(action: 'left_click'));

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

    test('clear removes all captured steps', () {
      service.capturedSteps
          .add(const MacroStep(action: 'left_click'));
      service.capturedSteps
          .add(const MacroStep(action: 'right_click'));

      service.clear();

      expect(service.capturedSteps, isEmpty);
    });

    test('start clears while recording stays true', () {
      service.start();
      service.capturedSteps
          .add(const MacroStep(action: 'left_click'));

      service.start(); // re-start

      expect(service.recording, isTrue);
      expect(service.capturedSteps, isEmpty);
    });
  });

  group('WebSocket capture', () {
    test('captures action_triggered messages when recording', () {
      service.start();

      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'left_click',
        'action_value': '',
      });

      expect(service.capturedSteps.length, 1);
      expect(service.capturedSteps[0].action, 'left_click');
    });

    test('captures action_triggered with value when recording', () {
      service.start();

      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'hotkey',
        'action_value': 'ctrl,c',
      });

      expect(service.capturedSteps.length, 1);
      expect(service.capturedSteps[0].action, 'hotkey');
      expect(service.capturedSteps[0].value, 'ctrl,c');
    });

    test('does not capture when not recording', () {
      // Not recording
      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'left_click',
        'action_value': '',
      });

      expect(service.capturedSteps, isEmpty);
    });

    test('captures multiple actions in order', () {
      service.start();

      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'hotkey',
        'action_value': 'win,d',
      });
      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'delay',
        'action_value': '1',
      });
      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'left_click',
        'action_value': '',
      });

      expect(service.capturedSteps.length, 3);
      expect(service.capturedSteps[0].action, 'hotkey');
      expect(service.capturedSteps[0].value, 'win,d');
      expect(service.capturedSteps[1].action, 'delay');
      expect(service.capturedSteps[1].value, '1');
      expect(service.capturedSteps[2].action, 'left_click');
      expect(service.capturedSteps[2].value, isNull);
    });

    test('ignores non-action_triggered messages even when recording', () {
      service.start();

      fakeWs.emit({
        'type': 'gesture_detected',
        'gesture': 'SWIPE_UP',
        'action': 'volume_up',
      });
      fakeWs.emit({
        'type': 'pong',
      });

      expect(service.capturedSteps, isEmpty);
    });
  });

  group('stop returns captured steps', () {
    test('stop returns the captured list', () {
      service.start();

      fakeWs.emit({
        'action': 'action_triggered',
        'action_key': 'left_click',
      });

      final steps = service.stop();

      expect(steps.length, 1);
      expect(steps[0].action, 'left_click');
    });
  });
}
