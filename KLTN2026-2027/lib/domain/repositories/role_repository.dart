import '../entities/app_role.dart';

abstract class RoleRepository {
  Future<List<AppRole>> getRoles();
  Future<void> createRole(String name, String description);
  Future<void> updateRole(String id, String name, String description);
  Future<void> deleteRole(String id);
  Future<void> assignRolePermissions(String id, List<String> permissions);
}
