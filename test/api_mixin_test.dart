import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_mixin.dart';
import 'package:gantia_mobile/services/api_service.dart';

class _TestService extends ChangeNotifier with ApiServiceMixin {}

class _FakeException implements Exception {
  final String message;
  _FakeException(this.message);
  @override
  String toString() => message;
}

void main() {
  late _TestService service;

  setUp(() {
    service = _TestService();
  });

  tearDown(() {
    service.dispose();
  });

  group('execute success', () {
    test('returns the result and ends with isLoading false', () async {
      final result = await service.execute<int>(() async => 42);

      expect(result, 42);
      expect(service.isLoading, isFalse);
      expect(service.error, isNull);
    });

    test('returns null result without error', () async {
      final result = await service.execute<int>(() async => null);

      expect(result, isNull);
      expect(service.error, isNull);
    });

    test('sets isLoading true while the call is in flight', () async {
      final gate = Completer<int>();
      final future = service.execute<int>(() => gate.future);
      expect(service.isLoading, isTrue);

      gate.complete(7);
      await future;
      expect(service.isLoading, isFalse);
    });
  });

  group('execute errors', () {
    test('maps UnauthorizedException to the default message', () async {
      final result = await service
          .execute<int>(() async => throw UnauthorizedException());

      expect(result, isNull);
      expect(service.error, 'No autorizado');
    });

    test('maps UnauthorizedException to a custom message', () async {
      final result = await service.execute<int>(
        () async => throw UnauthorizedException(),
        unauthorizedMessage: 'Sesión vencida',
      );

      expect(result, isNull);
      expect(service.error, 'Sesión vencida');
    });

    test('maps NetworkException to the network message', () async {
      final result = await service.execute<int>(
        () async => throw NetworkException('no reachable'),
        networkMessage: 'Sin red',
      );

      expect(result, isNull);
      expect(service.error, 'Sin red');
    });

    test('maps a ServerException to a non-empty message', () async {
      final result = await service.execute<int>(
        () async => throw ServerException(statusCode: 500, message: 'x'),
      );

      expect(result, isNull);
      expect(service.error, isNotNull);
      expect(service.error, isNotEmpty);
    });

    test('maps an arbitrary exception to a message', () async {
      final result =
          await service.execute<int>(() async => throw _FakeException('oops'));

      expect(result, isNull);
      expect(service.error, isNotNull);
    });
  });

  group('dispose', () {
    test('execute is a no-op after dispose', () async {
      final disposed = _TestService();
      disposed.dispose();
      final result = await disposed.execute<int>(() async => 42);

      expect(result, isNull);
    });
  });
}