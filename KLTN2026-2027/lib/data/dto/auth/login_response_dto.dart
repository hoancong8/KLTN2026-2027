// data/dto/auth/login_response_dto.dart
class LoginResponseDto {
  final String accessToken;
  final String refreshToken;
  final int expireInSeconds;
  final bool requiresTwoFactorVerification;
  final String? twoFactorRememberClientToken;
  final String? encryptedAccessToken;
  final int? userId;
  final int? refreshTokenExpireInSeconds;

  LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expireInSeconds,
    required this.requiresTwoFactorVerification,
    this.twoFactorRememberClientToken,
    this.encryptedAccessToken,
    this.userId,
    this.refreshTokenExpireInSeconds,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    if (accessToken == null) {
      throw Exception('accessToken is null in response: $json');
    }

    return LoginResponseDto(
      accessToken: accessToken as String,
      refreshToken: (json['refreshToken'] as String?) ?? '',
      expireInSeconds: _parseInt(json['expireInSeconds']),
      requiresTwoFactorVerification:
      _parseBool(json['requiresTwoFactorVerification']),
      twoFactorRememberClientToken:
      json['twoFactorRememberClientToken'] as String?,
      encryptedAccessToken: json['encryptedAccessToken'] as String?,
      userId: _parseIntNullable(json['userId']),
      refreshTokenExpireInSeconds:
      _parseIntNullable(json['refreshTokenExpireInSeconds']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
