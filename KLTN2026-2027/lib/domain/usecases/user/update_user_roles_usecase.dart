import '../../repositories/user_repository.dart';

class UpdateUserRolesUseCase {
  final UserRepository repository;
  UpdateUserRolesUseCase(this.repository);

  Future<void> execute(String id, List<String> roles) {
    return repository.updateUserRoles(id, roles);
  }
}
