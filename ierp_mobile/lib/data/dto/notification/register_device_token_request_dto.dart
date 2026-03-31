class RegisterDeviceTokenRequestDto {
  final String deviceToken;
  final String? deviceType;

  RegisterDeviceTokenRequestDto({
    required this.deviceToken,
    this.deviceType = 'mobile',
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceToken': deviceToken,
      'deviceType': deviceType,
    };
  }
}