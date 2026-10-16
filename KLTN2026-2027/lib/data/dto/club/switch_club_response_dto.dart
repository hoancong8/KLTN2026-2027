// lib/data/dto/club/switch_club_response_dto.dart

class SwitchClubResponseDto {
  final String accessToken;
  final String clubId;
  final String clubName;
  final dynamic role;
  final String? roleName;
  final String? roleId;
  final List<String> permissions;

  const SwitchClubResponseDto({
    required this.accessToken,
    required this.clubId,
    required this.clubName,
    required this.role,
    this.roleName,
    this.roleId,
    required this.permissions,
  });

  factory SwitchClubResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return const SwitchClubResponseDto(
        accessToken: '',
        clubId: '',
        clubName: '',
        role: 1,
        roleName: null,
        roleId: null,
        permissions: [],
      );
    }

    final rawPerms = rawJson['permissions'];
    final perms = (rawPerms is List)
        ? rawPerms.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final roleName = rawJson['roleName']?.toString();
    final roleId = rawJson['roleId']?.toString();
    final role = rawJson['role'] ?? roleName ?? roleId;

    return SwitchClubResponseDto(
      accessToken: rawJson['accessToken']?.toString() ?? '',
      clubId: rawJson['clubId']?.toString() ?? '',
      clubName: rawJson['clubName']?.toString() ?? '',
      role: role,
      roleName: roleName,
      roleId: roleId,
      permissions: perms,
    );
  }
}
