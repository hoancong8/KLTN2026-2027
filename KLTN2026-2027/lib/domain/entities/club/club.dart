// lib/domain/entities/club/club.dart

class Club {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? avatarUrl;
  final bool isActive;

  const Club({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.avatarUrl,
    required this.isActive,
  });
}
