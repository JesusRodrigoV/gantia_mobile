import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/utils/jwt_utils.dart';

import 'helpers/fakes.dart';

void main() {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  group('isTokenExpired', () {
    test('returns false for a token expiring in the future', () {
      expect(isTokenExpired(fakeJwt(exp: now + 3600)), isFalse);
    });

    test('returns true for an expired token', () {
      expect(isTokenExpired(fakeJwt(exp: now - 60)), isTrue);
    });

    test('returns true when exp has passed by less than a second', () {
      expect(isTokenExpired(fakeJwt(exp: now - 1)), isTrue);
    });

    test('returns true when exp is missing', () {
      final payload =
          'eyJhbGciOiJub25lIn0.eyJzdWIiOiIxIn0.signature';
      expect(isTokenExpired(payload), isTrue);
    });

    test('returns true for a malformed token (two parts)', () {
      expect(isTokenExpired('header.payload'), isTrue);
    });

    test('returns true for an empty token', () {
      expect(isTokenExpired(''), isTrue);
    });

    test('returns true for invalid base64 payload', () {
      expect(isTokenExpired('a.!!!.c'), isTrue);
    });

    test('returns true for non-numeric exp', () {
      final payload = 'eyJhbGciOiJub25lIn0.'
          'eyJzdWIiOiIxIiwiZXhwIjoiZm9vIn0.signature';
      expect(isTokenExpired(payload), isTrue);
    });
  });

  group('getJwtPayload', () {
    test('decodes the payload of a well-formed token', () {
      final payload = getJwtPayload(fakeJwt(exp: now + 100));
      expect(payload, contains('test@example.com'));
    });

    test('returns null for a malformed token', () {
      expect(getJwtPayload('garbage'), isNull);
    });

    test('returns null for an invalid base64 payload', () {
      expect(getJwtPayload('a.!!!.c'), isNull);
    });
  });
}