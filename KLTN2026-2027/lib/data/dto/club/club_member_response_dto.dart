// lib/data/dto/club/club_member_response_dto.dart

class ClubMemberResponseDto {
  final String id;
  final String clubId;
  final String userId;
  final String? userName;
  final String? email;
  final dynamic role;
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
        status: 1,
        nickname: null,
        joinedAt: null,
      );
    }

    return ClubMemberResponseDto(
      id: rawJson['id']?.toString() ?? '',
      clubId: rawJson['clubId']?.toString() ?? '',
      userId: rawJson['userId']?.toString() ?? '',
      userName: rawJson['userName']?.toString(),
      email: rawJson['email']?.toString(),
      role: rawJson['role'],
      status: rawJson['status'],
      nickname: rawJson['nickname']?.toString(),
      joinedAt: rawJson['joinedAt']?.toString(),
    );
  }
}
