import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/calibration_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('getAll', () {
    test('loads calibration entries', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/config/calibration');
          return http.Response(
            jsonEncode([
              {'sensor_name': 'thumb', 'min_value': 10, 'max_value': 90},
              {'sensor_name': 'index', 'min_value': 5, 'max_value': 95},
            ]),
            200,
          );
        }),
      );
      final service = CalibrationService(api);

      final entries = await service.getAll();

      expect(entries, hasLength(2));
      expect(service.entries, hasLength(2));
      expect(entries.first.sensorName, 'thumb');
      expect(entries.first.minValue, 10);
      expect(service.error, isNull);
    });

    test('returns empty and sets error on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = CalibrationService(api);

      final entries = await service.getAll();

      expect(entries, isEmpty);
      expect(service.error, isNotNull);
    });
  });

  group('update', () {
    test('updates an existing entry', () async {
      final api = ApiService(
        client: MockClient((req) async {
          if (req.method == 'GET') {
            return http.Response(
              jsonEncode([
                {'sensor_name': 'thumb', 'min_value': 10, 'max_value': 90},
              ]),
              200,
            );
          }
          expect(req.method, 'PUT');
          expect(req.url.path, '/config/calibration/thumb');
          expect(jsonDecode(req.body), {'min_value': 20.0});
          return http.Response(
            jsonEncode({'sensor_name': 'thumb', 'min_value': 20, 'max_value': 90}),
            200,
          );
        }),
      );
      final service = CalibrationService(api);
      await service.getAll();

      final entry = await service.update('thumb', minValue: 20);

      expect(entry?.minValue, 20);
      expect(service.entries.single.minValue, 20);
    });

    test('adds a new entry when the sensor is unknown', () async {
      final api = ApiService(
        client: MockClient((req) async {
          if (req.method == 'GET') {
            return http.Response(jsonEncode([]), 200);
          }
          return http.Response(
            jsonEncode({'sensor_name': 'pinky', 'min_value': 1, 'max_value': 99}),
            200,
          );
        }),
      );
      final service = CalibrationService(api);
      await service.getAll();

      final entry = await service.update('pinky', maxValue: 99);

      expect(entry?.sensorName, 'pinky');
      expect(service.entries.single.sensorName, 'pinky');
    });

    test('omits null values from the body', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(jsonDecode(req.body), isEmpty);
          return http.Response('{}', 200);
        }),
      );
      final service = CalibrationService(api);

      await service.update('thumb');

      expect(service.error, isNull);
    });
  });

  group('hasCalibration / saveCalibration', () {
    test('hasCalibration returns true when the endpoint responds', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/config/absolute-pointer/calibration');
          return http.Response('{}', 200);
        }),
      );
      final service = CalibrationService(api);

      expect(await service.hasCalibration(), isTrue);
    });

    test('hasCalibration returns false on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('nope', 404)),
      );
      final service = CalibrationService(api);

      expect(await service.hasCalibration(), isFalse);
    });

    test('saveCalibration puts corners and screen size', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'PUT');
          expect(req.url.path, '/config/absolute-pointer/calibration');
          expect(jsonDecode(req.body), {
            'corners': {'tl': [0, 0]},
            'screen_width': 1920,
            'screen_height': 1080,
          });
          return http.Response('{}', 200);
        }),
      );
      final service = CalibrationService(api);

      await service.saveCalibration({'tl': [0, 0]}, 1920, 1080);
    });
  });
}
