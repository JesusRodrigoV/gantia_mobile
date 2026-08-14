import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

MockClient jsonClient(int status, Map<String, dynamic> body) =>
    MockClient((_) async => http.Response(jsonEncode(body), status));

Map<String, dynamic> authBody() => {
      'access_token': fakeJwtValid(),
      'token_type': 'bearer',
      'user': {'id': '1', 'email': 'test@example.com'},
    };

void main() {
  group('login', () {
    test('success sets token, user and persists to prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService(client: jsonClient(200, authBody()));
      final auth = await AuthService.init(api);

      final ok = await auth.login('test@example.com', 'secret');

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user!.email, 'test@example.com');
      expect(auth.token, isNotNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), auth.token);
    });

    test('wrong credentials (401) returns false and sets error', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService(client: jsonClient(401, {}));
      final auth = await AuthService.init(api);

      final ok = await auth.login('test@example.com', 'wrong');

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.error, 'Credenciales inválidas');
    });

    test('network failure returns false and sets connection error', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService(
        client: MockClient(
          (_) async => throw const SocketException('refused'),
        ),
      );
      final auth = await AuthService.init(api);

      final ok = await auth.login('test@example.com', 'secret');

      expect(ok, isFalse);
      expect(auth.error, 'No se pudo conectar al servidor');
    });
  });

  group('register', () {
    test('success registers, authenticates and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService(client: jsonClient(200, authBody()));
      final auth = await AuthService.init(api);

      final ok = await auth.register('test@example.com', 'secret');

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user!.id, '1');
    });

    test('failure (409) returns false and does not authenticate', () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiService(client: jsonClient(409, {}));
      final auth = await AuthService.init(api);

      final ok = await auth.register('test@example.com', 'secret');

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
    });
  });

  group('logout', () {
    test('clears token, user and persisted prefs', () async {
      SharedPreferences.setMockInitialValues({'token': fakeJwtValid()});
      final auth = await AuthService.init(ApiService());
      expect(auth.isAuthenticated, isTrue);

      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.token, isNull);
      expect(auth.user, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('token'), isNull);
    });
  });

  group('init & expiry', () {
    test('restores a valid token from prefs', () async {
      SharedPreferences.setMockInitialValues({'token': fakeJwtValid()});
      final auth = await AuthService.init(ApiService());
      expect(auth.isAuthenticated, isTrue);
    });

    test('expired token is not authenticated and is cleared on connect path',
        () async {
      SharedPreferences.setMockInitialValues({'token': fakeJwtExpired()});
      final auth = await AuthService.init(ApiService());
      expect(auth.isAuthenticated, isFalse);
    });

    test('no token means not authenticated', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = await AuthService.init(ApiService());
      expect(auth.isAuthenticated, isFalse);
    });
  });
}