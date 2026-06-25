class AuthResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing access_token in auth response');
    }
    final userJson = json['user'];
    if (userJson == null || userJson is! Map<String, dynamic>) {
      throw const FormatException('Missing user in auth response');
    }
    return AuthResponse(
      accessToken: token,
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: User.fromJson(userJson),
    );
  }
}

class User {
  final String id;
  final String email;

  const User({required this.id, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const FormatException('Missing id in user response');
    }
    return User(
      id: id,
      email: json['email'] as String? ?? '',
    );
  }
}
