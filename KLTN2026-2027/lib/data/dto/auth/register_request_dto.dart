// lib/data/dto/auth/register_request_dto.dart

class RegisterRequestDto {
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String password;
  final int gender;
  final String skillLevel;

  RegisterRequestDto({
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.password,
    this.gender = 0,
    this.skillLevel = 'NB',
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (phoneNumber != null && phoneNumber!.isNotEmpty) 'phoneNumber': phoneNumber,
    'password': password,
    'gender': gender,
    'skillLevel': skillLevel,
  };
}
