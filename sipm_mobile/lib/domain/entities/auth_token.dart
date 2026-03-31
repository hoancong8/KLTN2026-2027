// domain/entities/auth_token.dart
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final String? twoFactorRememberClientToken;
  final int? userId;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    this.twoFactorRememberClientToken,
    this.userId,
  });

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? twoFactorRememberClientToken,
    int? userId,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      twoFactorRememberClientToken:
      twoFactorRememberClientToken ?? this.twoFactorRememberClientToken,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'AuthToken(accessToken: $accessToken, refreshToken: $refreshToken, twoFactorRememberClientToken: $twoFactorRememberClientToken, userId: $userId)';
  }
}
