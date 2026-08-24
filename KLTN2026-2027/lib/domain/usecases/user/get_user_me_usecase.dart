import '../../entities/user_profile.dart';
import '../../repositories/user_repository.dart';

class GetUserMeUseCase {
  final UserRepository repository;
  GetUserMeUseCase(this.repository);

  Future<UserProfile> execute() => repository.getUserMe();
}
