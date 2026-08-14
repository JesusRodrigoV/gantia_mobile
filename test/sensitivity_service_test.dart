import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/sensitivity_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('getSettings', () {
    test('loads settings from the server', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/sensitivity');
          return http.Response(
            jsonEncode({'swipe_threshold': 300, 'mouse_speed': 120}),
            200,
          );
        }),
      );
      final service = SensitivityService(api);

      final settings = await service.getSettings();

      expect(settings?.swipeThreshold, 300);
      expect(settings?.mouseSpeed, 120);
      expect(service.settings, same(settings));
      expect(service.error, isNull);
    });

    test('returns null and sets error on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = SensitivityService(api);

      final settings = await service.getSettings();

      expect(settings, isNull);
      expect(service.error, isNotNull);
    });
  });

  group('updateSettings', () {
    test('puts the partial body and updates settings', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'PUT');
          expect(req.url.path, '/sensitivity');
          expect(jsonDecode(req.body), {'swipe_threshold': 350});
          return http.Response(
            jsonEncode({'swipe_threshold': 350, 'mouse_speed': 100}),
            200,
          );
        }),
      );
      final service = SensitivityService(api);

      final ok = await service.updateSettings({'swipe_threshold': 350});

      expect(ok, isTrue);
      expect(service.settings?.swipeThreshold, 350);
      expect(service.settings?.mouseSpeed, 100);
    });

    test('returns false on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = SensitivityService(api);

      expect(await service.updateSettings({'swipe_threshold': 350}), isFalse);
      expect(service.error, isNotNull);
    });
  });
}
