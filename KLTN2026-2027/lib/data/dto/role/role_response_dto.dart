import '../user/permission_group_response_dto.dart';

class RoleResponseDto {
  final String id;
  final String name;
  final String description;
  final bool isDefault;
  final bool isStatic;
  final List<PermissionGroupResponseDto> permissions;

  RoleResponseDto({
    required this.id,
    required this.name,
    required this.description,
    this.isDefault = false,
    this.isStatic = false,
    required this.permissions,
  });

  factory RoleResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return RoleResponseDto(id: '', name: '', description: '', permissions: const []);
    }
    final rawPermissions = rawJson['permissions'];
    final permissionsList = (rawPermissions is List)
        ? rawPermissions.map((e) => PermissionGroupResponseDto.fromJson(e)).toList()
        : <PermissionGroupResponseDto>[];

    return RoleResponseDto(
      id: rawJson['id']?.toString() ?? '',
      name: rawJson['name']?.toString() ?? '',
      description: rawJson['description']?.toString() ?? '',
      isDefault: _parseBool(rawJson['isDefault']),
      isStatic: _parseBool(rawJson['isStatic']),
      permissions: permissionsList,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
