class LoginResponseDto {
  final String accessToken;
  final String refreshToken;
  final String? userId;

  LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: (json['accessToken'] as String?) ?? '',
      refreshToken: (json['refreshToken'] as String?) ?? '',
      userId: json['userId']?.toString(),
    );
  }
}
