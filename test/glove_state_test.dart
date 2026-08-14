import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/glove_state.dart';

import 'helpers/fakes.dart';

Map<String, dynamic> telemetry({int button = 0}) => {
      'type': 'telemetry',
      'button_pressed': button,
      'flex_index': 50,
      'flex_middle': 60,
      'index_state': 1,
      'middle_state': 2,
      'accel_x': 0.1,
      'accel_y': -0.2,
      'accel_z': 1.0,
      'gyro_x': 0.0,
      'gyro_y': 0.1,
      'gyro_z': -0.1,
    };

void main() {
  late FakeWsClient ws;
  late GloveState state;

  setUp(() {
    ws = FakeWsClient();
    state = GloveState(ws);
  });

  tearDown(() {
    state.dispose();
    ws.dispose();
  });

  group('connection status', () {
    test('starts disconnected', () {
      expect(state.connectionStatus, ConnectionStatus.disconnected);
      expect(state.dataFlowing, isFalse);
    });

    test('connecting event sets connecting status', () {
      fakeAsync((async) {
        ws.emit({'\$type': 'connecting'});
        async.flushMicrotasks();
        expect(state.connectionStatus, ConnectionStatus.connecting);
      });
    });

    test('connected event sets connected status', () {
      fakeAsync((async) {
        ws.emit({'\$type': 'connected'});
        async.flushMicrotasks();
        expect(state.connectionStatus, ConnectionStatus.connected);
        expect(state.dataFlowing, isFalse);
      });
    });

    test('error event sets error status and clears telemetry', () {
      fakeAsync((async) {
        ws.emit(telemetry());
        async.flushMicrotasks();
        ws.emit({'\$type': 'error'});
        async.flushMicrotasks();
        expect(state.connectionStatus, ConnectionStatus.error);
        expect(state.telemetry, isNull);
      });
    });

    test('disconnected event sets disconnected and stops data flow', () {
      fakeAsync((async) {
        ws.emit({'\$type': 'connected'});
        async.flushMicrotasks();
        ws.emit({'\$type': 'disconnected'});
        async.flushMicrotasks();
        expect(state.connectionStatus, ConnectionStatus.disconnected);
        expect(state.dataFlowing, isFalse);
      });
    });

    test('reconnecting event sets reconnecting status with attempt', () {
      fakeAsync((async) {
        ws.emit({'\$type': 'reconnecting', 'attempt': 3, 'maxRetries': 10});
        async.flushMicrotasks();
        expect(state.connectionStatus, ConnectionStatus.reconnecting);
        expect(state.retryAttempt, 3);
        expect(state.maxRetries, 10);
      });
    });
  });

  group('telemetry & data flow', () {
    test('telemetry sets dataFlowing true and exposes values', () {
      fakeAsync((async) {
        ws.emit({'\$type': 'connected'});
        async.flushMicrotasks();
        ws.emit(telemetry());
        async.flushMicrotasks();
        expect(state.dataFlowing, isTrue);
        expect(state.telemetry!.flexIndex, 50);
        expect(state.telemetry!.accelY, -0.2);
        expect(state.waitingForDevice, isFalse);
      });
    });

    test('dataFlowing turns false after 3000ms without telemetry', () {
      fakeAsync((async) {
        final ws = FakeWsClient();
        final state = GloveState(ws);
        ws.emit({'\$type': 'connected'});
        async.flushMicrotasks();
        ws.emit(telemetry());
        async.flushMicrotasks();
        expect(state.dataFlowing, isTrue);

        async.elapse(const Duration(milliseconds: 3100));
        expect(state.dataFlowing, isFalse);

        state.dispose();
        ws.dispose();
      });
    });

    test('waitingForDevice becomes true after connected + 7000ms idle', () {
      fakeAsync((async) {
        final ws = FakeWsClient();
        final state = GloveState(ws);
        ws.emit({'\$type': 'connected'});
        async.flushMicrotasks();
        expect(state.waitingForDevice, isFalse);

        async.elapse(const Duration(milliseconds: 7100));
        expect(state.waitingForDevice, isTrue);

        state.dispose();
        ws.dispose();
      });
    });

    test('telemetry arrival clears waitingForDevice and its timer', () {
      fakeAsync((async) {
        ws.emit({'\$type': 'connected'});
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 3000));

        ws.emit(telemetry());
        async.flushMicrotasks();

        async.elapse(const Duration(milliseconds: 5000));
        expect(state.waitingForDevice, isFalse);
      });
    });

    test('telemetry buffer is capped at 150 entries', () {
      fakeAsync((async) {
        for (var i = 0; i < 160; i++) {
          ws.emit(telemetry(button: i));
        }
        async.flushMicrotasks();
        expect(state.telemetryBuffer.length, 150);
        expect(state.telemetryBuffer.first.buttonPressed, 10);
        expect(state.telemetryBuffer.last.buttonPressed, 159);
      });
    });

    test('telemetryBuffer returns an unmodifiable snapshot', () {
      fakeAsync((async) {
        ws.emit(telemetry());
        async.flushMicrotasks();
        expect(() => state.telemetryBuffer.add(state.telemetryBuffer.first),
            throwsUnsupportedError);
      });
    });
  });

  group('actions & modes', () {
    test('gesture_detected sets gestureDetected', () {
      fakeAsync((async) {
        ws.emit({
          'type': 'gesture_detected',
          'gesture': 'SWIPE_UP',
          'action': 'volume_up',
        });
        async.flushMicrotasks();
        expect(state.gestureDetected!.gesture, 'SWIPE_UP');
        expect(state.gestureDetected!.action, 'volume_up');
      });
    });

    test('mouse_mode action_value true enables mouse mode', () {
      fakeAsync((async) {
        ws.emit({'action': 'mouse_mode', 'action_value': true});
        async.flushMicrotasks();
        expect(state.mouseModeActive, isTrue);
      });
    });

    test('mouse_mode action_value ON enables mouse mode', () {
      fakeAsync((async) {
        ws.emit({'action': 'mouse_mode', 'action_value': 'ON'});
        async.flushMicrotasks();
        expect(state.mouseModeActive, isTrue);
      });
    });

    test('mouse_mode action_value false disables mouse mode', () {
      fakeAsync((async) {
        ws.emit({'action': 'mouse_mode', 'action_value': true});
        async.flushMicrotasks();
        ws.emit({'action': 'mouse_mode', 'action_value': false});
        async.flushMicrotasks();
        expect(state.mouseModeActive, isFalse);
      });
    });

    test('mode_changed updates currentMode to uppercase', () {
      fakeAsync((async) {
        ws.emit({'action': 'mode_changed', 'action_value': 'audio'});
        async.flushMicrotasks();
        expect(state.currentMode, 'AUDIO');
      });
    });

    test('absolute_pointer_status updates absolutePointerEnabled', () {
      fakeAsync((async) {
        ws.emit({'type': 'absolute_pointer_status', 'enabled': true});
        async.flushMicrotasks();
        expect(state.absolutePointerEnabled, isTrue);
      });
    });

    test('absolute_pointer_status disables when enabled is false', () {
      fakeAsync((async) {
        ws.emit({'type': 'absolute_pointer_status', 'enabled': false});
        async.flushMicrotasks();
        expect(state.absolutePointerEnabled, isFalse);
      });
    });
  });

  group('outgoing commands', () {
    test('changeMode sends set_mode and updates currentMode', () {
      fakeAsync((async) {
        state.changeMode('PRESENTATION');
        async.flushMicrotasks();
        expect(
          ws.sent,
          [{'action': 'set_mode', 'value': 'PRESENTATION'}],
        );
        expect(state.currentMode, 'PRESENTATION');
      });
    });

    test('sendToggleAbsolutePointer sends the toggle', () {
      fakeAsync((async) {
        state.sendToggleAbsolutePointer(true);
        async.flushMicrotasks();
        expect(
          ws.sent,
          [{'type': 'toggle_absolute_pointer', 'enabled': true}],
        );
      });
    });
  });
}