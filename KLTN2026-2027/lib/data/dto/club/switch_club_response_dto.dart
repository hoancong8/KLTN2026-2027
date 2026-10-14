// lib/data/dto/club/switch_club_response_dto.dart

class SwitchClubResponseDto {
  final String accessToken;
  final String clubId;
  final String clubName;
  final dynamic role;
  final List<String> permissions;

  const SwitchClubResponseDto({
    required this.accessToken,
    required this.clubId,
    required this.clubName,
    required this.role,
    required this.permissions,
  });

  factory SwitchClubResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return const SwitchClubResponseDto(
        accessToken: '',
        clubId: '',
        clubName: '',
        role: 1,
        permissions: [],
      );
    }

    final rawPerms = rawJson['permissions'];
    final perms = (rawPerms is List)
        ? rawPerms.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return SwitchClubResponseDto(
      accessToken: rawJson['accessToken']?.toString() ?? '',
      clubId: rawJson['clubId']?.toString() ?? '',
      clubName: rawJson['clubName']?.toString() ?? '',
      role: rawJson['role'],
      permissions: perms,
    );
  }
}
