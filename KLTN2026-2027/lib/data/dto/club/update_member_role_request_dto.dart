// lib/data/dto/club/update_member_role_request_dto.dart

class UpdateMemberRoleRequestDto {
  final int role;
  final String? roleId;
  final String? roleName;

  const UpdateMemberRoleRequestDto({
    required this.role,
    this.roleId,
    this.roleName,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      if (roleId != null && roleId!.isNotEmpty) 'roleId': roleId,
      if (roleName != null && roleName!.isNotEmpty) 'roleName': roleName,
    };
  }
}
