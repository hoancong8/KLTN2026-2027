import '../entities/user_profile.dart';
import '../entities/paged_response.dart';

abstract class UserRepository {
  Future<UserProfile> getUserMe();
  Future<PagedResponse<UserProfile>> getUsers({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  });
  Future<UserProfile> getUserById(String id);
  Future<void> lockUser(String id, bool isLocked, {DateTime? lockoutEnd});
  Future<void> updateUserRoles(String id, List<String> roles);
}
