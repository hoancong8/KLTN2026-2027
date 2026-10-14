// lib/data/dto/club/my_club_response_dto.dart

class MyClubResponseDto {
  final String clubId;
  final String clubName;
  final String clubCode;
  final String? description;
  final String? avatarUrl;
  final dynamic role;
  final dynamic status;
  final String? joinedAt;

  const MyClubResponseDto({
    required this.clubId,
    required this.clubName,
    required this.clubCode,
    this.description,
    this.avatarUrl,
    required this.role,
    required this.status,
    this.joinedAt,
  });

  factory MyClubResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return const MyClubResponseDto(
        clubId: '',
        clubName: '',
        clubCode: '',
        description: null,
        avatarUrl: null,
        role: 1,
        status: 1,
        joinedAt: null,
      );
    }

    return MyClubResponseDto(
      clubId: rawJson['clubId']?.toString() ?? '',
      clubName: rawJson['clubName']?.toString() ?? '',
      clubCode: rawJson['clubCode']?.toString() ?? '',
      description: rawJson['description']?.toString(),
      avatarUrl: rawJson['avatarUrl']?.toString(),
      role: rawJson['role'],
      status: rawJson['status'],
      joinedAt: rawJson['joinedAt']?.toString(),
    );
  }
}
