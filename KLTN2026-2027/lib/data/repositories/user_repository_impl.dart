import '../../domain/entities/paged_response.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasource/remote/abstract/user_remote_datasource.dart';
import '../dto/user/user_lock_request_dto.dart';
import '../dto/user/user_roles_request_dto.dart';
import '../mapper/user_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserProfile> getUserMe() async {
    final dto = await remoteDatasource.getUserMe();
    return UserMapper.toEntity(dto);
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
}
