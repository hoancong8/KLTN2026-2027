// lib/data/dto/club/club_member_response_dto.dart

class ClubMemberResponseDto {
  final String id;
  final String clubId;
  final String userId;
  final String? userName;
  final String? email;
  final dynamic role;
  final String? roleName;
  final String? roleId;
  final dynamic status;
  final String? nickname;
  final String? joinedAt;

  const ClubMemberResponseDto({
    required this.id,
    required this.clubId,
    required this.userId,
    this.userName,
    this.email,
    required this.role,
    this.roleName,
    this.roleId,
    required this.status,
    this.nickname,
    this.joinedAt,
  });

  factory ClubMemberResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return const ClubMemberResponseDto(
        id: '',
        clubId: '',
        userId: '',
        userName: null,
        email: null,
        role: 1,
        roleName: null,
        roleId: null,
        status: 1,
        nickname: null,
        joinedAt: null,
      );
    }

    final roleName = rawJson['roleName']?.toString();
    final roleId = rawJson['roleId']?.toString();
    final role = rawJson['role'] ?? roleName ?? roleId;

    return ClubMemberResponseDto(
      id: rawJson['id']?.toString() ?? '',
      clubId: rawJson['clubId']?.toString() ?? '',
      userId: rawJson['userId']?.toString() ?? '',
      userName: rawJson['userName']?.toString(),
      email: rawJson['email']?.toString(),
      role: role,
      roleName: roleName,
      roleId: roleId,
      status: rawJson['status'],
      nickname: rawJson['nickname']?.toString(),
      joinedAt: rawJson['joinedAt']?.toString(),
    );
  }
}
