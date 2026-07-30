import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../services/api_service.dart';

String mapErrorToMessage(Object error) {
  if (error is NetworkException) {
    return error.message;
  }
  if (error is UnauthorizedException) {
    return error.message.isNotEmpty ? error.message : 'No autorizado';
  }
  if (error is ServerException) {
    // Try to extract a user-friendly detail from the server response body
    try {
      final body = jsonDecode(error.message) as Map<String, dynamic>;
      if (body['detail'] != null && (body['detail'] as String).isNotEmpty) {
        return body['detail'] as String;
      }
    } catch (_) {}
    if (error.statusCode == 404) return 'El recurso solicitado no existe';
    if (error.statusCode == 409) return 'El recurso ya existe o hay un conflicto';
    if (error.statusCode >= 500) return 'Error interno del servidor. Intentá de nuevo más tarde.';
    return 'Error del servidor (${error.statusCode})';
  }
  if (error is SocketException) {
    return 'No se pudo conectar al servidor';
  }
  if (error is TimeoutException) {
    return 'La conexión tardó demasiado. Verificá el servidor e intentá de nuevo.';
  }
  if (error is FormatException) {
    return 'Error al procesar la respuesta del servidor';
  }
  return 'Ocurrió un error inesperado';
}

String mapErrorToLog(Object error) {
  return '[ERROR] $error';
}
