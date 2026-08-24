import '../../repositories/user_repository.dart';

class LockUserUseCase {
  final UserRepository repository;
  LockUserUseCase(this.repository);

  Future<void> execute(String id, bool isLocked, {DateTime? lockoutEnd}) {
    return repository.lockUser(id, isLocked, lockoutEnd: lockoutEnd);
  }
}
