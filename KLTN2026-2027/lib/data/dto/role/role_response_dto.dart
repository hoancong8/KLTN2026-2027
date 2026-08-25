import '../user/permission_group_response_dto.dart';

class RoleResponseDto {
  final String id;
  final String name;
  final String description;
  final List<PermissionGroupResponseDto> permissions;

  RoleResponseDto({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  factory RoleResponseDto.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];
    final permissionsList = (rawPermissions is List)
        ? rawPermissions
            .map((e) => PermissionGroupResponseDto.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PermissionGroupResponseDto>[];

    return RoleResponseDto(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      permissions: permissionsList,
    );
  }
}
