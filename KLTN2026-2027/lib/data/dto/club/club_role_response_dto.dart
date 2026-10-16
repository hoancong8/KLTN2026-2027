// lib/data/dto/club/club_role_response_dto.dart

class ClubRolePermissionItemDto {
  final String id;
  final String code;
  final String name;
  final String moduleGroup;
  final String? description;

  ClubRolePermissionItemDto({
    required this.id,
    required this.code,
    required this.name,
    required this.moduleGroup,
    this.description,
  });

  factory ClubRolePermissionItemDto.fromJson(Map<String, dynamic> json) {
    return ClubRolePermissionItemDto(
      id: json['id']?.toString() ?? '',
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      moduleGroup: (json['moduleGroup'] as String?) ?? '',
      description: json['description']?.toString(),
    );
  }
}

class ClubRoleResponseDto {
  final String id;
  final String clubId;
  final String roleName;
  final String? description;
  final bool isDefault;
  final bool isHostRole;
  final String createdAt;
  final List<ClubRolePermissionItemDto> permissions;

  ClubRoleResponseDto({
    required this.id,
    required this.clubId,
    required this.roleName,
    this.description,
    required this.isDefault,
    required this.isHostRole,
    required this.createdAt,
    required this.permissions,
  });

  factory ClubRoleResponseDto.fromJson(Map<String, dynamic> json) {
    final permsList = (json['permissions'] as List<dynamic>?)
            ?.map((p) => ClubRolePermissionItemDto.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return ClubRoleResponseDto(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      roleName: (json['roleName'] as String?) ?? '',
      description: json['description']?.toString(),
      isDefault: json['isDefault'] == true,
      isHostRole: json['isHostRole'] == true,
      createdAt: (json['createdAt'] as String?) ?? '',
      permissions: permsList,
    );
  }
}
