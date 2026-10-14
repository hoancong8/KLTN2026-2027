// lib/data/dto/club/club_response_dto.dart

class ClubResponseDto {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? avatarUrl;
  final bool isActive;

  const ClubResponseDto({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.avatarUrl,
    required this.isActive,
  });

  factory ClubResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return const ClubResponseDto(
        id: '',
        name: '',
        code: '',
        description: null,
        avatarUrl: null,
        isActive: false,
      );
    }

    return ClubResponseDto(
      id: rawJson['id']?.toString() ?? '',
      name: rawJson['name']?.toString() ?? '',
      code: rawJson['code']?.toString() ?? '',
      description: rawJson['description']?.toString(),
      avatarUrl: rawJson['avatarUrl']?.toString(),
      isActive: _parseBool(rawJson['isActive']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
