import '../entities/user_profile.dart';
import '../entities/paged_response.dart';

import '../entities/permission_group.dart';
import '../entities/user_permissions.dart';

abstract class UserRepository {
  Future<UserProfile> getUserMe();
  Future<UserPermissions> getUserPermissions();
  Future<List<PermissionGroup>> getAllPermissions();
  Future<PagedResponse<UserProfile>> getUsers({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  });
  Future<UserProfile> getUserById(String id);
  Future<void> createUser(String email, String password, List<String> roles);
  Future<void> updateUser(String id, String email, String userName, {String? phoneNumber});
  Future<void> deleteUser(String id);
  Future<void> lockUser(String id, bool isLocked, {DateTime? lockoutEnd});
  Future<void> updateUserRoles(String id, List<String> roles);
  Future<void> resetPassword(String id, String newPassword);
}
