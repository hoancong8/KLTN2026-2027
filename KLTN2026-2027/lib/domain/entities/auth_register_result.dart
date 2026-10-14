// lib/domain/entities/auth_register_result.dart

class AuthRegisterResult {
  final String userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final int gender;
  final String skillLevel;
  final double reputationScore;
  final String accessToken;
  final String refreshToken;
  final DateTime refreshTokenExpiryTime;

  const AuthRegisterResult({
    required this.userId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.gender,
    required this.skillLevel,
    required this.reputationScore,
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpiryTime,
  });
}
