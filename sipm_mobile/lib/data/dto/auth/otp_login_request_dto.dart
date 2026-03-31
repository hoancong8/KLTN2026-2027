class OtpLoginRequestDto {
  final String username;
  final String password;
  final String code;
  final bool rememberClient;

  OtpLoginRequestDto({
    required this.username,
    required this.password,
    required this.code,
    this.rememberClient = true,
  });

  Map<String, dynamic> toJson() => {
    'userNameOrEmailAddress': username,
    'password': password,
    'twoFactorVerificationCode': code,
    'rememberClient': rememberClient,
  };
}
