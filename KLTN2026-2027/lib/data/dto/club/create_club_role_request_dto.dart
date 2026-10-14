// lib/data/dto/club/create_club_role_request_dto.dart

class CreateClubRoleRequestDto {
  final String roleName;
  final String? description;
  final List<String> permissionIds;
  final bool isDefault;

  CreateClubRoleRequestDto({
    required this.roleName,
    this.description,
    this.permissionIds = const [],
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'roleName': roleName,
    if (description != null) 'description': description,
    'permissionIds': permissionIds,
    'isDefault': isDefault,
  };
}
