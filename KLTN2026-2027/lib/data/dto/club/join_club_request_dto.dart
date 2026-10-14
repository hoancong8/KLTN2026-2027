// lib/data/dto/club/join_club_request_dto.dart

class JoinClubRequestDto {
  final String clubCode;
  final int role;
  final String? nickname;

  const JoinClubRequestDto({
    required this.clubCode,
    this.role = 1,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'clubCode': clubCode,
      'role': role,
      if (nickname != null) 'nickname': nickname,
    };
  }
}
