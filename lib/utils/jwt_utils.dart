import 'dart:convert';

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    final decoded = utf8.decode(base64Decode(normalized));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
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
    return utf8.decode(base64Decode(normalized));
  } catch (_) {
    return null;
  }
}
