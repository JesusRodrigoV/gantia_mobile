import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/gesture_config_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ApiService apiWith(dynamic Function(http.Request) handler) {
    return ApiService(
      client: MockClient((req) async {
        final body = handler(req);
        return http.Response(jsonEncode(body), 200);
      }),
    );
  }

  group('getAll', () {
    test('loads configs from the server', () async {
      final api = apiWith((req) {
        expect(req.url.path, '/config/gesture-configs');
        return [
          {
            'id': '1',
            'action_key': 'volume_up',
            'movement': 'SWIPE_UP',
            'enabled': true,
          },
          {
            'id': '2',
            'action_key': 'mute',
            'movement': 'PINCH',
            'enabled': false,
          },
        ];
      });
      final service = GestureConfigService(api);

      final configs = await service.getAll();

      expect(configs, hasLength(2));
      expect(service.configs, hasLength(2));
      expect(configs.first.id, '1');
      expect(service.isLoading, isFalse);
      expect(service.error, isNull);
    });

    test('returns empty on failure and sets error', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = GestureConfigService(api);

      final configs = await service.getAll();

      expect(configs, isEmpty);
      expect(service.error, isNotNull);
    });
  });

  group('create / update / delete', () {
    test('create posts and adds the config', () async {
      final api = apiWith((req) {
        expect(req.method, 'POST');
        expect(req.url.path, '/config/gesture-configs');
        return {'id': '9', 'action_key': 'next', 'movement': 'SWIPE_RIGHT'};
      });
      final service = GestureConfigService(api);

      final created = await service.create({'action': 'next'});

      expect(created?.id, '9');
      expect(service.configs, hasLength(1));
    });

    test('update puts and replaces the matching config', () async {
      final api = ApiService(
        client: MockClient((req) async {
          if (req.method == 'GET') {
            return http.Response(
              jsonEncode([
                {'id': '1', 'action_key': 'volume_up', 'movement': 'SWIPE_UP'},
              ]),
              200,
            );
          }
          expect(req.method, 'PUT');
          expect(req.url.path, '/config/gesture-configs/1');
          return http.Response(
            jsonEncode({'id': '1', 'action_key': 'prev', 'movement': 'SWIPE_LEFT'}),
            200,
          );
        }),
      );
      final service = GestureConfigService(api);
      await service.getAll();
      expect(
        service.configs.firstWhere((c) => c.id == '1').actionKey,
        'volume_up',
      );

      final updated = await service.update('1', {'action': 'prev'});

      expect(updated?.actionKey, 'prev');
      expect(
        service.configs.firstWhere((c) => c.id == '1').actionKey,
        'prev',
      );
    });

    test('update of an unknown id still returns the config', () async {
      final api = apiWith((req) => {'id': '99', 'action_key': 'back'});
      final service = GestureConfigService(api);

      final updated = await service.update('99', {'action_key': 'back'});

      expect(updated?.id, '99');
      expect(service.configs, isEmpty);
    });

    test('delete removes the config and returns true', () async {
      final api = ApiService(
        client: MockClient((req) async {
          if (req.method == 'GET') {
            return http.Response(
              jsonEncode([
                {'id': '1', 'action_key': 'volume_up', 'movement': 'SWIPE_UP'},
                {'id': '2', 'action_key': 'mute', 'movement': 'PINCH'},
              ]),
              200,
            );
          }
          expect(req.method, 'DELETE');
          expect(req.url.path, '/config/gesture-configs/1');
          return http.Response('{}', 200);
        }),
      );
      final service = GestureConfigService(api);
      await service.getAll();
      expect(service.configs, hasLength(2));

      final deleted = await service.delete('1');

      expect(deleted, isTrue);
      expect(service.configs, hasLength(1));
      expect(service.configs.any((c) => c.id == '1'), isFalse);
    });

    test('delete returns false on failure', () async {
      final api = ApiService(
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final service = GestureConfigService(api);

      final deleted = await service.delete('1');

      expect(deleted, isFalse);
    });
  });

  group('export / import / refresh / reset', () {
    test('exportConfigs returns the json string', () async {
      final api = apiWith((req) {
        expect(req.url.path, '/config/gesture-configs/export');
        return {'a': 1};
      });
      final service = GestureConfigService(api);

      final exported = await service.exportConfigs();

      expect(jsonDecode(exported!), {'a': 1});
    });

    test('importConfigs posts and reloads', () async {
      var calls = 0;
      final api = ApiService(
        client: MockClient((req) async {
          calls++;
          if (req.url.path == '/config/gesture-configs/import') {
            expect(req.method, 'POST');
            return http.Response('{}', 200);
          }
          return http.Response(
            jsonEncode([
              {'id': '5', 'action_key': 'mute', 'movement': 'PINCH'},
            ]),
            200,
          );
        }),
      );
      final service = GestureConfigService(api);

      final imported = await service.importConfigs([
        {'action': 'mute'},
      ]);

      expect(imported, isTrue);
      expect(calls, 2);
      expect(service.configs.single.id, '5');
    });

    test('refreshFromSupabase posts and reloads', () async {
      var calls = 0;
      final api = ApiService(
        client: MockClient((req) async {
          calls++;
          if (req.url.path == '/refresh-configs') {
            return http.Response('{}', 200);
          }
          return http.Response(
            jsonEncode([
              {'id': '7', 'action_key': 'next', 'movement': 'SWIPE_RIGHT'},
            ]),
            200,
          );
        }),
      );
      final service = GestureConfigService(api);

      final ok = await service.refreshFromSupabase();

      expect(ok, isTrue);
      expect(calls, 2);
      expect(service.configs.single.id, '7');
    });

    test('resetToDefaults posts and reloads', () async {
      var calls = 0;
      final api = ApiService(
        client: MockClient((req) async {
          calls++;
          if (req.url.path == '/config/reset') {
            return http.Response('{}', 200);
          }
          return http.Response(jsonEncode([]), 200);
        }),
      );
      final service = GestureConfigService(api);

      final ok = await service.resetToDefaults();

      expect(ok, isTrue);
      expect(calls, 2);
      expect(service.configs, isEmpty);
    });
  });
}
