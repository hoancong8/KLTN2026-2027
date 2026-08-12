class ChangePasswordRequestDto {
  final String currentPassword;
  final String newPassword;


  ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
