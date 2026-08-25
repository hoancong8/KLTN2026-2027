import '../../domain/entities/app_role.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasource/remote/abstract/role_remote_datasource.dart';
import '../dto/role/role_request_dto.dart';
import '../mapper/role_mapper.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDatasource remoteDatasource;

  RoleRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<AppRole>> getRoles() async {
    final dtos = await remoteDatasource.getRoles();
    return dtos.map((e) => RoleMapper.toEntity(e)).toList();
  }

  @override
  Future<void> createRole(String name, String description) async {
    final request = RoleCreateUpdateRequestDto(name: name, description: description);
    await remoteDatasource.createRole(request);
  }

  @override
  Future<void> updateRole(String id, String name, String description) async {
    final request = RoleCreateUpdateRequestDto(name: name, description: description);
    await remoteDatasource.updateRole(id, request);
  }

  @override
  Future<void> deleteRole(String id) async {
    await remoteDatasource.deleteRole(id);
  }

  @override
  Future<void> assignRolePermissions(String id, List<String> permissions) async {
    final request = AssignRolePermissionsRequestDto(permissions: permissions);
    await remoteDatasource.assignRolePermissions(id, request);
  }
}
