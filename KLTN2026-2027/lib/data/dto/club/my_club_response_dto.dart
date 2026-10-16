// lib/data/dto/club/my_club_response_dto.dart

class MyClubResponseDto {
  final String clubId;
  final String clubName;
  final String clubCode;
  final String? description;
  final String? avatarUrl;
  final dynamic role;
  final String? roleName;
  final String? roleId;
  final dynamic status;
  final String? joinedAt;

  const MyClubResponseDto({
    required this.clubId,
    required this.clubName,
    required this.clubCode,
    this.description,
    this.avatarUrl,
    required this.role,
    this.roleName,
    this.roleId,
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
        roleName: null,
        roleId: null,
        status: 1,
        joinedAt: null,
      );
    }

    final roleName = rawJson['roleName']?.toString();
    final roleId = rawJson['roleId']?.toString();
    final role = rawJson['role'] ?? roleName ?? roleId;

    return MyClubResponseDto(
      clubId: (rawJson['clubId'] ?? rawJson['groupId'])?.toString() ?? '',
      clubName: (rawJson['clubName'] ?? rawJson['groupName'])?.toString() ?? '',
      clubCode: (rawJson['clubCode'] ?? rawJson['code'])?.toString() ?? '',
      description: rawJson['description']?.toString(),
      avatarUrl: rawJson['avatarUrl']?.toString(),
      role: role,
      roleName: roleName,
      roleId: roleId,
      status: rawJson['status'],
      joinedAt: rawJson['joinedAt']?.toString(),
    );
  }
}
