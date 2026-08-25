import '../../domain/entities/paged_response.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasource/remote/abstract/user_remote_datasource.dart';
import '../dto/user/user_lock_request_dto.dart';
import '../dto/user/user_roles_request_dto.dart';
import '../mapper/user_mapper.dart';

import '../../domain/entities/permission_group.dart';
import '../../domain/entities/user_permissions.dart';
import '../mapper/permission_group_mapper.dart';
import '../mapper/user_permissions_mapper.dart';
import '../dto/user/user_management_request_dto.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserProfile> getUserMe() async {
    final dto = await remoteDatasource.getUserMe();
    return UserMapper.toEntity(dto);
  }

  @override
  Future<UserPermissions> getUserPermissions() async {
    final dto = await remoteDatasource.getUserPermissions();
    return UserPermissionsMapper.toEntity(dto);
  }

  @override
  Future<List<PermissionGroup>> getAllPermissions() async {
    final dtos = await remoteDatasource.getAllPermissions();
    return dtos.map((e) => PermissionGroupMapper.toGroupEntity(e)).toList();
  }

  @override
  Future<PagedResponse<UserProfile>> getUsers({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  }) async {
    final dto = await remoteDatasource.getUsers(
      pageNumber: pageNumber,
      pageSize: pageSize,
      searchTerm: searchTerm,
    );
    return UserMapper.toPagedEntity(dto);
  }

  @override
  Future<UserProfile> getUserById(String id) async {
    final dto = await remoteDatasource.getUserById(id);
    return UserMapper.toEntity(dto);
  }

  @override
  Future<void> createUser(String email, String password, List<String> roles) async {
    final request = CreateUserRequestDto(email: email, password: password, roles: roles);
    await remoteDatasource.createUser(request);
  }

  @override
  Future<void> updateUser(String id, String email, String userName, {String? phoneNumber}) async {
    final request = UpdateUserRequestDto(email: email, userName: userName, phoneNumber: phoneNumber);
    await remoteDatasource.updateUser(id, request);
  }

  @override
  Future<void> deleteUser(String id) async {
    await remoteDatasource.deleteUser(id);
  }

  @override
  Future<void> lockUser(String id, bool isLocked, {DateTime? lockoutEnd}) async {
    final request = UserLockRequestDto(
      isLocked: isLocked,
      lockoutEnd: lockoutEnd?.toIso8601String(),
    );
    await remoteDatasource.lockUser(id, request);
  }

  @override
  Future<void> updateUserRoles(String id, List<String> roles) async {
    final request = UserRolesRequestDto(roles: roles);
    await remoteDatasource.updateUserRoles(id, request);
  }

  @override
  Future<void> resetPassword(String id, String newPassword) async {
    final request = ResetPasswordRequestDto(newPassword: newPassword);
    await remoteDatasource.resetPassword(id, request);
  }
}
