class PermissionItemResponseDto {
  final String name;
  final String displayName;

  PermissionItemResponseDto({
    required this.name,
    required this.displayName,
  });

  factory PermissionItemResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) return PermissionItemResponseDto(name: '', displayName: '');
    return PermissionItemResponseDto(
      name: rawJson['name']?.toString() ?? '',
      displayName: rawJson['displayName']?.toString() ?? '',
    );
  }
}

class PermissionGroupResponseDto {
  final String name;
  final String displayName;
  final List<PermissionGroupResponseDto> children;
  final List<PermissionItemResponseDto> permissions;

  PermissionGroupResponseDto({
    required this.name,
    required this.displayName,
    this.children = const [],
    this.permissions = const [],
  });

  factory PermissionGroupResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return PermissionGroupResponseDto(name: '', displayName: '');
    }
    final rawChildren = rawJson['children'];
    final children = (rawChildren is List)
        ? rawChildren.map((e) => PermissionGroupResponseDto.fromJson(e)).toList()
        : <PermissionGroupResponseDto>[];

    final rawPermissions = rawJson['permissions'];
    final permissions = (rawPermissions is List)
        ? rawPermissions.map((e) => PermissionItemResponseDto.fromJson(e)).toList()
        : <PermissionItemResponseDto>[];

    return PermissionGroupResponseDto(
      name: rawJson['name']?.toString() ?? '',
      displayName: rawJson['displayName']?.toString() ?? '',
      children: children,
      permissions: permissions,
    );
  }
}
