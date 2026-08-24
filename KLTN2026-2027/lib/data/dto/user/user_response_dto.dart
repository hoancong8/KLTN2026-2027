class UserResponseDto {
  final String id;
  final String email;
  final String userName;
  final String? phoneNumber;
  final bool isLocked;
  final String? lockoutEnd;
  final List<String> roles;
  final List<String> permissions;

  UserResponseDto({
    required this.id,
    required this.email,
    required this.userName,
    this.phoneNumber,
    required this.isLocked,
    this.lockoutEnd,
    required this.roles,
    required this.permissions,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = (rawRoles is List)
        ? rawRoles.map((e) => e.toString()).toList()
        : <String>[];

    final rawPermissions = json['permissions'];
    final permissions = (rawPermissions is List)
        ? rawPermissions.map((e) => e.toString()).toList()
        : <String>[];

    return UserResponseDto(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      userName: (json['userName'] as String?) ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      isLocked: _parseBool(json['isLocked']),
      lockoutEnd: json['lockoutEnd'] as String?,
      roles: roles,
      permissions: permissions,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
