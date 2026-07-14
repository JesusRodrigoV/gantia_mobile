import 'dart:convert';
import 'package:flutter/foundation.dart';

String _padBase64(String input) {
  switch (input.length % 4) {
    case 2:
      return '$input==';
    case 3:
      return '$input=';
    default:
      return input;
  }
}

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      debugPrint('[JWT] invalid parts: ${parts.length}');
      return true;
    }
    final normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    final padded = _padBase64(normalized);
    final decoded = utf8.decode(base64Decode(padded));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    final exp = map['exp'] as int?;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[JWT] exp=$exp nowMs=$nowMs expired=${exp != null ? exp * 1000 < nowMs : "no exp"}');
    if (exp == null) return true;
    return exp * 1000 < nowMs;
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
    return utf8.decode(base64Decode(_padBase64(normalized)));
  } catch (_) {
    return null;
  }
}
