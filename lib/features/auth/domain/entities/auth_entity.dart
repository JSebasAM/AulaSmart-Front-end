class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> userInfo;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.userInfo,
  });
}
