class UserPermissionsResponseDto {
  final String userId;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  UserPermissionsResponseDto({
    required this.userId,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  factory UserPermissionsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = (rawRoles is List)
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];

    final rawPermissions = json['permissions'];
    final permissions = (rawPermissions is List)
        ? rawPermissions.map((e) => e.toString()).toList()
        : <String>[];

    return UserPermissionsResponseDto(
      userId: (json['userId'] as String?) ?? (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      roles: roles,
      permissions: permissions,
    );
  }
}
