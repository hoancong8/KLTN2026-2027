class LoginRequestDto {
  final String userNameOrEmailAddress;
  final String password;
  final String? twoFactorVerificationCode;
  final String? twoFactorRememberClientToken;
  final bool? rememberClient;

  LoginRequestDto({
    required this.userNameOrEmailAddress,
    required this.password,
    this.twoFactorVerificationCode,
    this.twoFactorRememberClientToken,
    this.rememberClient,
  });

  Map<String, dynamic> toJson() => {
    'userNameOrEmailAddress': userNameOrEmailAddress,
    'password': password,
    if (twoFactorVerificationCode != null)
      'twoFactorVerificationCode': twoFactorVerificationCode,
    if (twoFactorRememberClientToken != null)
      'twoFactorRememberClientToken': twoFactorRememberClientToken,
    if (rememberClient != null)
      'rememberClient': rememberClient,
  };
}