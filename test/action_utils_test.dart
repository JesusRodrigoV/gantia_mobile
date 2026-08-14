import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/utils/action_utils.dart';

void main() {
  group('isGestureDetected', () {
    test('true for a gesture_detected message', () {
      expect(
        isGestureDetected({'type': 'gesture_detected', 'gesture': 'pinch'}),
        isTrue,
      );
    });

    test('false for other types', () {
      expect(isGestureDetected({'type': 'telemetry', 'accel_x': 1}), isFalse);
      expect(isGestureDetected({'action': 'next'}), isFalse);
    });

    test('false for non-map values', () {
      expect(isGestureDetected('gesture_detected'), isFalse);
      expect(isGestureDetected(null), isFalse);
      expect(isGestureDetected(42), isFalse);
    });
  });

  group('isActionMessage', () {
    test('true when the map has an action key', () {
      expect(isActionMessage({'action': 'mute'}), isTrue);
      expect(isActionMessage({'action': 'mute', 'action_value': 'ON'}), isTrue);
    });

    test('false for telemetry and status messages', () {
      expect(isActionMessage({'type': 'connected'}), isFalse);
      expect(isActionMessage({'accel_x': 0.1}), isFalse);
    });

    test('false for non-map values', () {
      expect(isActionMessage('next'), isFalse);
      expect(isActionMessage(null), isFalse);
    });
  });

  group('isTelemetryData', () {
    test('true when the map has accel_x', () {
      expect(
        isTelemetryData({'accel_x': 0.1, 'flex_index': 300}),
        isTrue,
      );
    });

    test('false for action and status messages', () {
      expect(isTelemetryData({'action': 'next'}), isFalse);
      expect(isTelemetryData({'type': 'connected'}), isFalse);
    });

    test('false for non-map values', () {
      expect(isTelemetryData(3.14), isFalse);
      expect(isTelemetryData(null), isFalse);
    });
  });

  group('getActionLabel', () {
    test('returns a friendly label for known actions', () {
      expect(getActionLabel('next'), 'Siguiente');
      expect(getActionLabel('volume_up'), 'Subir Volumen');
      expect(getActionLabel('left_click'), 'Click Izquierdo');
      expect(getActionLabel('mouse_mode'), 'Mouse Mode');
    });

    test('falls back to the raw action for unknown actions', () {
      expect(getActionLabel('nonsense_action'), 'nonsense_action');
      expect(getActionLabel(''), '');
    });
  });

  group('actionLabels', () {
    test('contains entries for every media action used by the handler', () {
      for (final key in [
        'next',
        'prev',
        'mute',
        'volume_up',
        'volume_down',
        'play_pause',
        'back',
        'forward',
      ]) {
        expect(actionLabels.containsKey(key), isTrue, reason: key);
      }
    });
  });
}