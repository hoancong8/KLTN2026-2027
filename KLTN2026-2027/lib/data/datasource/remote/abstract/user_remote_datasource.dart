import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/user/user_lock_request_dto.dart';
import '../../../dto/user/user_response_dto.dart';
import '../../../dto/user/user_roles_request_dto.dart';

import '../../../dto/user/permission_group_response_dto.dart';
import '../../../dto/user/user_permissions_response_dto.dart';

import '../../../dto/user/user_management_request_dto.dart';

abstract class UserRemoteDatasource {
  Future<UserResponseDto> getUserMe();
  Future<UserPermissionsResponseDto> getUserPermissions();
  Future<List<PermissionGroupResponseDto>> getAllPermissions();
  Future<PagedResultDto<UserResponseDto>> getUsers({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  });
  Future<UserResponseDto> getUserById(String id);
  Future<void> createUser(CreateUserRequestDto request);
  Future<void> updateUser(String id, UpdateUserRequestDto request);
  Future<void> deleteUser(String id);
  Future<void> lockUser(String id, UserLockRequestDto request);
  Future<void> updateUserRoles(String id, UserRolesRequestDto request);
  Future<void> resetPassword(String id, ResetPasswordRequestDto request);
}
