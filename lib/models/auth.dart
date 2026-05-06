
class Auth {
  final String accessToken;
  final String refreshToken;

  const Auth({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      accessToken: (json['accessToken']) as String,
      refreshToken: (json['refreshToken']) as String,
    );
  }
}
