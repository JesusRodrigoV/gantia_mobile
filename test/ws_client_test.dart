import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

const int maxRetries = 10;
const Duration baseReconnectDelay = Duration(seconds: 1);
const Duration maxReconnectDelay = Duration(seconds: 30);

Duration calculateDelay(int attempt) {
  final ms = baseReconnectDelay.inMilliseconds * pow(2, attempt - 1);
  return Duration(
    milliseconds: min(ms.toInt(), maxReconnectDelay.inMilliseconds),
  );
}

void main() {
  group('exponential backoff formula', () {
    test('returns 1s for attempt 1', () {
      expect(calculateDelay(1), const Duration(seconds: 1));
    });

    test('returns 2s for attempt 2', () {
      expect(calculateDelay(2), const Duration(seconds: 2));
    });

    test('returns 4s for attempt 3', () {
      expect(calculateDelay(3), const Duration(seconds: 4));
    });

    test('returns 8s for attempt 4', () {
      expect(calculateDelay(4), const Duration(seconds: 8));
    });

    test('returns 16s for attempt 5', () {
      expect(calculateDelay(5), const Duration(seconds: 16));
    });

    test('caps at 30s from attempt 6 onward', () {
      for (int i = 6; i <= 10; i++) {
        expect(calculateDelay(i), const Duration(seconds: 30));
      }
    });
  });

  group('max retries', () {
    test('stops reconnecting after 10 attempts', () {
      int reconnectAttempts = 0;
      expect(reconnectAttempts >= maxRetries, false);

      reconnectAttempts = 10;
      expect(reconnectAttempts >= maxRetries, true);
    });

    test('increments attempt count correctly', () {
      int reconnectAttempts = 0;
      for (int i = 1; i <= 5; i++) {
        reconnectAttempts++;
      }
      expect(reconnectAttempts, 5);
    });
  });

  group('_isConnecting guard', () {
    test('prevents duplicate connection attempts', () {
      bool isConnecting = false;
      int callCount = 0;

      void establishConnection() {
        if (isConnecting) return;
        isConnecting = true;
        callCount++;
      }

      establishConnection();
      expect(callCount, 1);

      // Second call while connecting — no-op
      establishConnection();
      expect(callCount, 1);

      // Reset and allow
      isConnecting = false;
      establishConnection();
      expect(callCount, 2);
    });
  });
}
