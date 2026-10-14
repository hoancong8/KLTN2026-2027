// lib/data/dto/club/update_member_role_request_dto.dart

class UpdateMemberRoleRequestDto {
  final int role;

  const UpdateMemberRoleRequestDto({required this.role});

  Map<String, dynamic> toJson() {
    return {
      'role': role,
    };
  }
}
