import '../../entities/player_profile.dart';
import '../../repositories/user_repository.dart';

class GetPlayerProfileUseCase {
  final UserRepository repository;
  GetPlayerProfileUseCase(this.repository);

  Future<PlayerProfile> execute() => repository.getMyProfile();
}
