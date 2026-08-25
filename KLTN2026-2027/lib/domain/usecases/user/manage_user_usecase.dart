import '../../repositories/user_repository.dart';

class ManageUserUseCase {
  final UserRepository repository;

  ManageUserUseCase(this.repository);

  Future<void> createUser(String email, String password, List<String> roles) {
    return repository.createUser(email, password, roles);
  }

  Future<void> updateUser(String id, String email, String userName, {String? phoneNumber}) {
    return repository.updateUser(id, email, userName, phoneNumber: phoneNumber);
  }

  Future<void> deleteUser(String id) {
    return repository.deleteUser(id);
  }

  Future<void> resetPassword(String id, String newPassword) {
    return repository.resetPassword(id, newPassword);
  }
}
