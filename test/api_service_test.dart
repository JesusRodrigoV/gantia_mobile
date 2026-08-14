import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('request execution', () {
    test('get returns decoded json body', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'GET');
          expect(req.url.toString(), 'http://localhost:8000/ping');
          return http.Response('{"ok":true}', 200);
        }),
      );

      final data = await api.get('/ping');

      expect(data, {'ok': true});
    });

    test('includes Authorization header when token is set', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.headers['Authorization'], 'Bearer token123');
          return http.Response('{}', 200);
        }),
      );
      api.setToken('token123');

      await api.get('/ping');
    });

    test('omits Authorization header when no token', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.headers.containsKey('Authorization'), isFalse);
          return http.Response('{}', 200);
        }),
      );

      await api.get('/ping');
    });

    test('post sends json body and hits the right path', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.toString(), 'http://localhost:8000/things');
          expect(jsonDecode(req.body), {'name': 'x'});
          expect(req.headers['Content-Type'], 'application/json');
          return http.Response('{"id":1}', 201);
        }),
      );

      final data = await api.post('/things', body: {'name': 'x'});

      expect(data, {'id': 1});
    });

    test('put and delete hit the right paths', () async {
      final calls = <String>[];
      final api = ApiService(
        client: MockClient((req) async {
          calls.add('${req.method} ${req.url.path}');
          return http.Response('{}', 200);
        }),
      );

      await api.put('/things/1', body: {'name': 'y'});
      await api.delete('/things/1');

      expect(calls, ['PUT /things/1', 'DELETE /things/1']);
    });

    test('rawPost uses the given absolute url and headers', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.toString(), 'http://other:9000/hook');
          expect(req.headers['X-Custom'], 'abc');
          expect(jsonDecode(req.body), {'a': 1});
          return http.Response('{}', 200);
        }),
      );

      await api.rawPost(
        'http://other:9000/hook',
        body: {'a': 1},
        headers: {'X-Custom': 'abc'},
      );
    });

    test('returns null for an empty body', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('', 204)),
      );

      expect(await api.get('/nothing'), isNull);
    });
  });

  group('error handling', () {
    test('401 throws UnauthorizedException', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('', 401)),
      );

      expect(() => api.get('/private'), throwsA(isA<UnauthorizedException>()));
    });

    test('5xx throws ServerException with status code', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('boom', 500)),
      );

      expect(
        () => api.get('/broken'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', 'boom'),
        ),
      );
    });

    test('SocketException maps to NetworkException', () async {
      final api = ApiService(
        client: MockClient((_) async => throw const SocketException('refused')),
      );

      expect(
        () => api.get('/x'),
        throwsA(isA<NetworkException>().having(
            (e) => e.message, 'message', 'No se pudo conectar al servidor')),
      );
    });

    test('ClientException maps to NetworkException', () async {
      final api = ApiService(
        client: MockClient((_) async => throw http.ClientException('boom')),
      );

      expect(() => api.get('/x'),
          throwsA(isA<NetworkException>().having((e) => e.message, 'message', 'Error de conexión')));
    });

    test('invalid json body propagates FormatException', () async {
      final api = ApiService(
        client: MockClient((_) async => http.Response('not-json', 200)),
      );

      expect(() => api.get('/x'), throwsA(isA<FormatException>()));
    });
  });

  group('configuration', () {
    test('defaults to localhost:8000 and setBaseUrl updates it', () async {
      final api = ApiService(
        client: MockClient((req) async {
          expect(req.url.toString(), startsWith('http://10.0.0.5:9999'));
          return http.Response('{}', 200);
        }),
      );

      await api.setBaseUrl('http://10.0.0.5:9999');
      await api.get('/ping');
    });
  });
}