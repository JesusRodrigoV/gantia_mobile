import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/mouse_config_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('getConfig', () {
    test('loads the config and defaults to an empty map', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.path, '/mouse-config');
          return http.Response(
            jsonEncode({'invert_roll': true}),
            200,
          );
        }),
      );
      final service = MouseConfigService(api);

      final config = await service.getConfig();

      expect(config, {'invert_roll': true});
      expect(service.config, {'invert_roll': true});
    });

    test('treats a null body as empty config', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('null', 200)),
      );
      final service = MouseConfigService(api);

      final config = await service.getConfig();

      expect(config, isEmpty);
      expect(service.error, isNull);
    });

    test('returns null and sets error on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = MouseConfigService(api);

      expect(await service.getConfig(), isNull);
      expect(service.error, isNotNull);
    });
  });

  group('updateConfig', () {
    test('sends only non-null flags and updates the config', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'PUT');
          expect(req.url.path, '/mouse-config');
          expect(jsonDecode(req.body), {'invert_roll': true});
          return http.Response(
            jsonEncode({'invert_roll': true, 'invert_pitch': false}),
            200,
          );
        }),
      );
      final service = MouseConfigService(api);

      final ok = await service.updateConfig(invertRoll: true);

      expect(ok, isTrue);
      expect(service.config, {'invert_roll': true, 'invert_pitch': false});
    });

    test('sends an empty body when no flags are provided', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(jsonDecode(req.body), isEmpty);
          return http.Response('{}', 200);
        }),
      );
      final service = MouseConfigService(api);

      expect(await service.updateConfig(), isTrue);
    });

    test('keeps the previous config when response body is null', () async {
      final api = ApiService(
        client: MockClient((req) async {
          if (req.method == 'GET') {
            return http.Response(jsonEncode({'invert_roll': true}), 200);
          }
          return http.Response('null', 200);
        }),
      );
      final service = MouseConfigService(api);
      await service.getConfig();

      final ok = await service.updateConfig(invertPitch: true);

      expect(ok, isTrue);
      expect(service.config, {'invert_roll': true});
    });

    test('returns false on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = MouseConfigService(api);

      expect(await service.updateConfig(invertRoll: true), isFalse);
      expect(service.error, isNotNull);
    });
  });
}
