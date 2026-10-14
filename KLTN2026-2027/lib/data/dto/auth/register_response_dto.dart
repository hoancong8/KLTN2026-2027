// lib/data/dto/auth/register_response_dto.dart

class RegisterResponseDto {
  final String userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final int gender;
  final String skillLevel;
  final double reputationScore;
  final String accessToken;
  final String refreshToken;
  final String refreshTokenExpiryTime;

  RegisterResponseDto({
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

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      userId: json['userId']?.toString() ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      gender: _parseInt(json['gender']),
      skillLevel: (json['skillLevel'] as String?) ?? 'NB',
      reputationScore: _parseDouble(json['reputationScore']),
      accessToken: (json['accessToken'] as String?) ?? '',
      refreshToken: (json['refreshToken'] as String?) ?? '',
      refreshTokenExpiryTime: (json['refreshTokenExpiryTime'] as String?) ?? '',
    );
  }
}
