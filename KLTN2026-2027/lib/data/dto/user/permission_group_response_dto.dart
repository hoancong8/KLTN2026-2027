class PermissionItemResponseDto {
  final String name;
  final String displayName;

  PermissionItemResponseDto({
    required this.name,
    required this.displayName,
  });

  factory PermissionItemResponseDto.fromJson(Map<String, dynamic> json) {
    return PermissionItemResponseDto(
      name: (json['name'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? '',
    );
  }
}

class PermissionGroupResponseDto {
  final String name;
  final String displayName;
  final List<PermissionItemResponseDto> permissions;

  PermissionGroupResponseDto({
    required this.name,
    required this.displayName,
    required this.permissions,
  });

  factory PermissionGroupResponseDto.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];
    final permissionsList = (rawPermissions is List)
        ? rawPermissions.map((e) => PermissionItemResponseDto.fromJson(e as Map<String, dynamic>)).toList()
        : <PermissionItemResponseDto>[];

    return PermissionGroupResponseDto(
      name: (json['name'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? '',
      permissions: permissionsList,
    );
  }
}
