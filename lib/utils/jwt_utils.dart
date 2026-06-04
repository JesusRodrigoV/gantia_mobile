import 'dart:convert';

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = parts[1];
    final normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
    final decoded = String.fromCharCodes(
      base64Decode(normalized),
    );
    final map = Map<String, dynamic>.from(
      (const JsonDecoder().convert(decoded) as Map),
    );
    final exp = map['exp'] as int?;
    if (exp == null) return true;
    return exp * 1000 < DateTime.now().millisecondsSinceEpoch;
  } catch (_) {
    return true;
  }
}

String? getJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    return String.fromCharCodes(base64Decode(normalized));
  } catch (_) {
    return null;
  }
}
