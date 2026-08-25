import '../../repositories/role_repository.dart';

class ManageRoleUseCase {
  final RoleRepository repository;

  ManageRoleUseCase(this.repository);

  Future<void> createRole(String name, String description) {
    return repository.createRole(name, description);
  }

  Future<void> updateRole(String id, String name, String description) {
    return repository.updateRole(id, name, description);
  }

  Future<void> deleteRole(String id) {
    return repository.deleteRole(id);
  }

  Future<void> assignRolePermissions(String id, List<String> permissions) {
    return repository.assignRolePermissions(id, permissions);
  }
}
