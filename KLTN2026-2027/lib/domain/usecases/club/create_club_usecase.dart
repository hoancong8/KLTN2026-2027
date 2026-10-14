// lib/domain/usecases/club/create_club_usecase.dart

import '../../repositories/club_repository.dart';

class CreateClubParams {
  final String name;
  final String? description;
  final String? avatarUrl;

  const CreateClubParams({
    required this.name,
    this.description,
    this.avatarUrl,
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
    );
  }
}
