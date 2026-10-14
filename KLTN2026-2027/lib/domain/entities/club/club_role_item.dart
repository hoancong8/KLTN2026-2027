// lib/domain/entities/club/club_role_item.dart

class ClubRolePermission {
  final String id;
  final String code;
  final String name;
  final String moduleGroup;

  const ClubRolePermission({
    required this.id,
    required this.code,
    required this.name,
    required this.moduleGroup,
  });
}

class ClubRoleItem {
  final String id;
  final String clubId;
  final String roleName;
  final String? description;
  final bool isDefault;
  final bool isHostRole;
  final DateTime createdAt;
  final List<ClubRolePermission> permissions;

  const ClubRoleItem({
    required this.id,
    required this.clubId,
    required this.roleName,
    this.description,
    required this.isDefault,
    required this.isHostRole,
    required this.createdAt,
    required this.permissions,
  });
}
