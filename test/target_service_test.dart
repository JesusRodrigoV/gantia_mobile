import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/target_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('getTarget', () {
    test('loads the active target', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/active-target');
          return http.Response(jsonEncode({'target': 'workshop'}), 200);
        }),
      );
      final service = TargetService(api);

      final target = await service.getTarget();

      expect(target, 'workshop');
      expect(service.target, 'workshop');
      expect(service.error, isNull);
    });

    test('returns null and sets error on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = TargetService(api);

      expect(await service.getTarget(), isNull);
      expect(service.error, isNotNull);
    });
  });

  group('setTarget', () {
    test('posts the target and updates state', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.path, '/active-target');
          expect(jsonDecode(req.body), {'target': 'audio'});
          return http.Response(jsonEncode({'target': 'audio'}), 200);
        }),
      );
      final service = TargetService(api);

      final ok = await service.setTarget('audio');

      expect(ok, isTrue);
      expect(service.target, 'audio');
    });

    test('falls back to the requested target when response has none', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('{}', 200)),
      );
      final service = TargetService(api);

      final ok = await service.setTarget('work');

      expect(ok, isTrue);
      expect(service.target, 'work');
    });

    test('returns false on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = TargetService(api);

      expect(await service.setTarget('audio'), isFalse);
      expect(service.error, isNotNull);
    });
  });
}
