class UserRolesRequestDto {
  final List<String> roles;

  UserRolesRequestDto({required this.roles});

  Map<String, dynamic> toJson() {
    return {
      'roles': roles,
    };
  }
}
