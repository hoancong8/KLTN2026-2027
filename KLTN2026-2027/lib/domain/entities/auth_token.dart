class AuthToken {
  final String accessToken;
  final String refreshToken;
  final String? userId;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
  });

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'AuthToken(accessToken: $accessToken, refreshToken: $refreshToken, userId: $userId)';
  }
}
