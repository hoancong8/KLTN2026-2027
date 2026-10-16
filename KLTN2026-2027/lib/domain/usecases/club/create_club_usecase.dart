// lib/domain/usecases/club/create_club_usecase.dart

import '../../repositories/club_repository.dart';

class CreateClubParams {
  final String name;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? lat;
  final double? lng;
  final int? minSkillLevel;
  final int? maxSkillLevel;
  final List<dynamic>? schedules;

  const CreateClubParams({
    required this.name,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.lat,
    this.lng,
    this.minSkillLevel,
    this.maxSkillLevel,
    this.schedules,
  });
}

class CreateClubUseCase {
  final ClubRepository repository;

  CreateClubUseCase(this.repository);

  Future<String> execute(CreateClubParams params) {
    return repository.createClub(
      name: params.name,
      description: params.description,
      avatarUrl: params.avatarUrl,
      fixedVenueName: params.fixedVenueName,
      fixedAddress: params.fixedAddress,
      lat: params.lat,
      lng: params.lng,
      minSkillLevel: params.minSkillLevel,
      maxSkillLevel: params.maxSkillLevel,
      schedules: params.schedules,
    );
  }
}
