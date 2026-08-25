class CreateUserRequestDto {
  final String email;
  final String password;
  final List<String> roles;

  CreateUserRequestDto({
    required this.email,
    required this.password,
    required this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'roles': roles,
    };
  }
}

class UpdateUserRequestDto {
  final String email;
  final String userName;
  final String? phoneNumber;

  UpdateUserRequestDto({
    required this.email,
    required this.userName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userName': userName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

class ResetPasswordRequestDto {
  final String newPassword;

  ResetPasswordRequestDto({
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
    };
  }
}
