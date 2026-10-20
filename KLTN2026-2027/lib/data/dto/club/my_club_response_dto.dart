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
  final List<String> permissions;

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
    this.permissions = const [],
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
        permissions: [],
      );
    }

    final roleName = rawJson['roleName']?.toString();
    final roleId = rawJson['roleId']?.toString();
    final role = rawJson['role'] ?? roleName ?? roleId;

    final rawPerms = rawJson['permissions'];
    final permissions = (rawPerms is List)
        ? rawPerms
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList()
        : const <String>[];

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
      permissions: permissions,
    );
  }
}
