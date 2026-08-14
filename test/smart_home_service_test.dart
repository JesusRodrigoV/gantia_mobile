import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/smart_home_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('commands', () {
    test('lightOn posts to the device url', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.toString(), 'http://192.168.1.50/light');
          expect(jsonDecode(req.body), {'command': 'on'});
          return http.Response('{}', 200);
        }),
      );
      final service = SmartHomeService(api);

      final ok = await service.lightOn('http://192.168.1.50/light');

      expect(ok, isTrue);
      expect(service.lastError, isNull);
      expect(service.lastDeviceUrl, 'http://192.168.1.50/light');
      expect(service.commandInProgress, isFalse);
    });

    test('lightOff posts the off command', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(jsonDecode(req.body), {'command': 'off'});
          return http.Response('{}', 200);
        }),
      );
      final service = SmartHomeService(api);

      expect(await service.lightOff('http://host/light'), isTrue);
    });

    test('setBrightness clamps the value to 0-100', () async {
      final values = <int>[];
      final api = ApiService(
        client: MockClient((req) async {
          values.add((jsonDecode(req.body) as Map)['value'] as int);
          return http.Response('{}', 200);
        }),
      );
      final service = SmartHomeService(api);

      await service.setBrightness('http://host/light', 150);
      await service.setBrightness('http://host/light', -10);

      expect(values, [100, 0]);
    });

    test('passes custom headers to rawPost', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.headers['X-Key'], 'secret');
          return http.Response('{}', 200);
        }),
      );
      final service = SmartHomeService(api);

      final ok = await service.lightOn(
        'http://host/light',
        headers: {'X-Key': 'secret'},
      );

      expect(ok, isTrue);
    });

    test('sets lastError when the command fails', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = SmartHomeService(api);

      final ok = await service.lightOn('http://host/light');

      expect(ok, isFalse);
      expect(service.lastError, isNotNull);
      expect(service.lastDeviceUrl, 'http://host/light');
      expect(service.commandInProgress, isFalse);
    });
  });

  group('clearError', () {
    test('clears the error and device url', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = SmartHomeService(api);
      await service.lightOn('http://host/light');
      expect(service.lastError, isNotNull);

      service.clearError();

      expect(service.lastError, isNull);
      expect(service.lastDeviceUrl, isNull);
    });
  });
}
