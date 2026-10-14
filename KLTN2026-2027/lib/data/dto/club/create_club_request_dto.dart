// lib/data/dto/club/create_club_request_dto.dart

class CreateClubRequestDto {
  final String name;
  final String? description;
  final String? avatarUrl;

  const CreateClubRequestDto({
    required this.name,
    this.description,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}
