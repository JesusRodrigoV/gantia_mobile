import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/api_service.dart';
import 'package:gantia_mobile/utils/error_message_mapper.dart';

void main() {
  group('mapErrorToMessage', () {
    test('NetworkException uses its own message', () {
      expect(mapErrorToMessage(NetworkException('sin red')), 'sin red');
    });

    test('UnauthorizedException with default message', () {
      expect(
        mapErrorToMessage(UnauthorizedException()),
        'No autorizado',
      );
    });

    test('UnauthorizedException with custom message', () {
      expect(
        mapErrorToMessage(UnauthorizedException('Sesión inválida')),
        'Sesión inválida',
      );
    });

    test('ServerException extracts detail from a JSON body', () {
      expect(
        mapErrorToMessage(ServerException(
          statusCode: 422,
          message: jsonEncode({'detail': 'Email ya registrado'}),
        )),
        'Email ya registrado',
      );
    });

    test('ServerException 404 maps to resource missing', () {
      expect(
        mapErrorToMessage(ServerException(statusCode: 404, message: 'x')),
        'El recurso solicitado no existe',
      );
    });

    test('ServerException 409 maps to conflict', () {
      expect(
        mapErrorToMessage(ServerException(statusCode: 409, message: 'x')),
        'El recurso ya existe o hay un conflicto',
      );
    });

    test('ServerException 5xx maps to internal error', () {
      expect(
        mapErrorToMessage(ServerException(statusCode: 500, message: 'x')),
        'Error interno del servidor. Intentá de nuevo más tarde.',
      );
    });

    test('SocketException maps to connection failure', () {
      expect(
        mapErrorToMessage(const SocketException('refused')),
        'No se pudo conectar al servidor',
      );
    });

    test('TimeoutException maps to timeout message', () {
      expect(
        mapErrorToMessage(TimeoutException('slow')),
        'La conexión tardó demasiado. Verificá el servidor e intentá de nuevo.',
      );
    });

    test('FormatException maps to response processing error', () {
      expect(
        mapErrorToMessage(const FormatException('bad json')),
        'Error al procesar la respuesta del servidor',
      );
    });

    test('unknown errors fall back to a generic message', () {
      expect(mapErrorToMessage(Exception('whatever')), 'Ocurrió un error inesperado');
    });
  });

  group('mapErrorToLog', () {
    test('wraps the error in a bracket prefix', () {
      expect(mapErrorToLog('boom'), '[ERROR] boom');
      expect(mapErrorToLog(42), '[ERROR] 42');
    });
  });
}