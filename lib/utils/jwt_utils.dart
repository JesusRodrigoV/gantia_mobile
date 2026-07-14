import 'dart:convert';
import 'package:flutter/foundation.dart';

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      debugPrint('[JWT] invalid parts: ${parts.length}');
      return true;
    }
    final normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    final decoded = utf8.decode(base64Decode(normalized));
    debugPrint('[JWT] payload: $decoded');
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    final exp = map['exp'] as int?;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[JWT] exp=$exp nowMs=$nowMs expMs=${exp != null ? exp * 1000 : "null"}');
    if (exp == null) {
      debugPrint('[JWT] exp is NULL');
      return true;
    }
    final expired = exp * 1000 < nowMs;
    debugPrint('[JWT] expired=$expired');
    return expired;
  } catch (e) {
    debugPrint('[JWT] error: $e');
    return true;
  }
}

String? getJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    return utf8.decode(base64Decode(normalized));
  } catch (_) {
    return null;
  }
}
