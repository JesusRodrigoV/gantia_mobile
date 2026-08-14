import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/models/action_message.dart';

void main() {
  group('GloveTelemetry', () {
    final fullJson = {
      'button_pressed': 1,
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
      'rssi': -55,
      'temp_mpu': 31.5,
      'uptime_ms': 123456,
    };

    test('fromJson parses all fields', () {
      final t = GloveTelemetry.fromJson(fullJson);

      expect(t.buttonPressed, 1);
      expect(t.flexIndex, 50);
      expect(t.flexMiddle, 60);
      expect(t.indexState, 1);
      expect(t.middleState, 2);
      expect(t.accelX, 0.1);
      expect(t.accelY, -0.2);
      expect(t.accelZ, 1.0);
      expect(t.gyroX, 0.0);
      expect(t.gyroY, 0.1);
      expect(t.gyroZ, -0.1);
      expect(t.rssi, -55);
      expect(t.tempMpu, 31.5);
      expect(t.uptimeMs, 123456);
      expect(t.hasHealth, isTrue);
    });

    test('fromJson applies defaults for missing fields', () {
      final t = GloveTelemetry.fromJson({});

      expect(t.buttonPressed, 0);
      expect(t.flexIndex, 0);
      expect(t.accelX, 0.0);
      expect(t.rssi, isNull);
      expect(t.tempMpu, isNull);
      expect(t.uptimeMs, isNull);
      expect(t.hasHealth, isFalse);
    });

    test('toJson includes optional fields only when present', () {
      final t = GloveTelemetry.fromJson(fullJson);
      final json = t.toJson();

      expect(json['rssi'], -55);
      expect(json['temp_mpu'], 31.5);
      expect(json['uptime_ms'], 123456);

      final minimal = GloveTelemetry.fromJson({}).toJson();
      expect(minimal.containsKey('rssi'), isFalse);
      expect(minimal.containsKey('temp_mpu'), isFalse);
      expect(minimal.containsKey('uptime_ms'), isFalse);
    });
  });

  group('ActionEvent', () {
    test('fromJson parses a plain action message', () {
      final e = ActionEvent.fromJson({'action': 'volume_up', 'action_value': 1});

      expect(e.action, 'volume_up');
      expect(e.actionValue, 1);
    });

    test('fromJson unwraps action_triggered messages', () {
      final e = ActionEvent.fromJson({
        'action': 'action_triggered',
        'action_key': 'next',
        'action_value': '2',
      });

      expect(e.action, 'next');
      expect(e.actionValue, '2');
    });

    test('fromJson defaults action to empty', () {
      final e = ActionEvent.fromJson({});

      expect(e.action, '');
      expect(e.actionValue, isNull);
    });
  });

  group('GestureDetectedEvent', () {
    test('fromJson parses the gesture event', () {
      final e = GestureDetectedEvent.fromJson({
        'type': 'gesture_detected',
        'gesture': 'SWIPE_UP',
        'action': 'volume_up',
      });

      expect(e.type, 'gesture_detected');
      expect(e.gesture, 'SWIPE_UP');
      expect(e.action, 'volume_up');
    });

    test('fromJson defaults to empty strings', () {
      final e = GestureDetectedEvent.fromJson({});

      expect(e.type, '');
      expect(e.gesture, '');
      expect(e.action, '');
    });
  });
}
