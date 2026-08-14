import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/learning_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('start', () {
    test('starts a session and clears the analysis', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.path, '/learning/start');
          return http.Response(
            jsonEncode({'id': 's1', 'samples_collected': 0}),
            201,
          );
        }),
      );
      final service = LearningService(api);

      final session = await service.start();

      expect(session?.id, 's1');
      expect(service.session?.id, 's1');
      expect(service.isSessionActive, isTrue);
    });
  });

  group('sample', () {
    test('captures an analysis and increments the session counter', () async {
      var calls = 0;
      final api = ApiService(
        client: MockClient((req) async {
          calls++;
          if (req.url.path == '/learning/start') {
            return http.Response(jsonEncode({'id': 's1', 'samples_collected': 0}), 201);
          }
          expect(req.url.path, '/learning/sample');
          return http.Response(
            jsonEncode({
              'movement': 'SWIPE_UP',
              'orientation': 'ANY',
              'index_state': 1,
              'middle_state': 0,
            }),
            201,
          );
        }),
      );
      final service = LearningService(api);
      await service.start();

      final analysis = await service.sample();

      expect(analysis?.movement, 'SWIPE_UP');
      expect(service.analysis?.movement, 'SWIPE_UP');
      expect(service.session?.samplesCollected, 1);
      expect(calls, 2);
    });

    test('sets the analysis even without an active session', () async {
      final api = ApiService(
        client: MockClient((req) async {
          return http.Response(
            jsonEncode({'movement': 'TWIST', 'orientation': 'PALM_UP'}),
            201,
          );
        }),
      );
      final service = LearningService(api);

      final analysis = await service.sample();

      expect(analysis?.movement, 'TWIST');
      expect(service.analysis?.movement, 'TWIST');
      expect(service.session, isNull);
    });
  });

  group('save', () {
    test('saves the session and deactivates it', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.path, '/learning/save');
          expect(jsonDecode(req.body), {'action_key': 'volume_up'});
          return http.Response(
            jsonEncode({'id': 's1', 'samples_collected': 5}),
            201,
          );
        }),
      );
      final service = LearningService(api);

      final session = await service.save('volume_up');

      expect(session?.samplesCollected, 5);
      expect(service.isSessionActive, isFalse);
      expect(service.error, isNull);
    });
  });

  group('cancel', () {
    test('cancels and clears the session state', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/learning/cancel');
          return http.Response('{}', 200);
        }),
      );
      final service = LearningService(api);
      await service.start();

      final ok = await service.cancel();

      expect(ok, isTrue);
      expect(service.session, isNull);
      expect(service.analysis, isNull);
      expect(service.isSessionActive, isFalse);
    });

    test('returns false on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = LearningService(api);

      expect(await service.cancel(), isFalse);
      expect(service.error, isNotNull);
    });
  });
}
