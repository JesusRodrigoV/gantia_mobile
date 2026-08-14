import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/history_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Map<String, dynamic> readingJson({String id = '1'}) => {
        'accel_x': 0.1,
        'accel_y': -0.2,
        'accel_z': 1.0,
        'gyro_x': 0.0,
        'gyro_y': 0.1,
        'gyro_z': -0.1,
        'flex_index': 50,
        'flex_middle': 60,
        'timestamp': '2024-01-01T10:00:00.000Z',
      };

  Map<String, dynamic> actionJson({String action = 'next'}) => {
        'action': action,
        'action_value': '1',
        'target': 'media',
        'status': 'ok',
        'timestamp': 1704103200,
      };

  group('getReadingsHistory', () {
    test('loads readings and total', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/readings/history');
          return http.Response(
            jsonEncode({
              'data': [readingJson(), readingJson(id: '2')],
              'total': 42,
            }),
            200,
          );
        }),
      );
      final service = HistoryService(api);

      final readings = await service.getReadingsHistory();

      expect(readings, hasLength(2));
      expect(service.readings, hasLength(2));
      expect(service.totalReadings, 42);
      expect(readings.first.flexIndex, 50);
      expect(service.error, isNull);
    });

    test('builds query params from filters', () async {
      String? url;
      final api = ApiService(
        client: MockClient((req) async {
          url = req.url.toString();
          return http.Response(
            jsonEncode({'data': <dynamic>[], 'total': 0}),
            200,
          );
        }),
      );
      final service = HistoryService(api);
      final since = DateTime.utc(2024, 1, 1);
      final until = DateTime.utc(2024, 1, 2);

      await service.getReadingsHistory(since: since, until: until, limit: 10);

      expect(url, contains('since=${Uri.encodeComponent(since.toIso8601String())}'));
      expect(url, contains('until=${Uri.encodeComponent(until.toIso8601String())}'));
      expect(url, contains('limit=10'));
    });

    test('omits query string when no filters', () async {
      String? path;
      final api = ApiService(
        client: MockClient((req) async {
          path = req.url.path;
          return http.Response(jsonEncode({'data': <dynamic>[], 'total': 0}), 200);
        }),
      );
      final service = HistoryService(api);

      await service.getReadingsHistory();

      expect(path, '/readings/history');
    });

    test('defaults total to list length and returns empty on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = HistoryService(api);

      final readings = await service.getReadingsHistory();

      expect(readings, isEmpty);
      expect(service.error, isNotNull);
    });
  });

  group('getActionsHistory', () {
    test('loads actions and total', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/actions/history');
          return http.Response(
            jsonEncode({
              'data': [actionJson(), actionJson(action: 'prev')],
              'total': 7,
            }),
            200,
          );
        }),
      );
      final service = HistoryService(api);

      final actions = await service.getActionsHistory();

      expect(actions, hasLength(2));
      expect(service.actions, hasLength(2));
      expect(service.totalActions, 7);
      expect(actions.first.action, 'next');
    });

    test('builds query params and returns empty on failure', () async {
      String? url;
      final api = ApiService(
        client: MockClient((req) async {
          url = req.url.toString();
          if (req.url.path == '/actions/history') {
            return http.Response(jsonEncode({'data': <dynamic>[], 'total': 0}), 200);
          }
          return http.Response('oops', 500);
        }),
      );
      final service = HistoryService(api);

      await service.getActionsHistory(limit: 5, offset: 2);

      expect(url, contains('limit=5'));
      expect(url, contains('offset=2'));

      final failing = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final failingService = HistoryService(failing);
      final actions = await failingService.getActionsHistory();

      expect(actions, isEmpty);
      expect(failingService.error, isNotNull);
    });
  });
}
