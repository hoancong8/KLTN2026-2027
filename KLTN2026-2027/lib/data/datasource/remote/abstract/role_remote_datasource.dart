import '../../../dto/role/role_request_dto.dart';
import '../../../dto/role/role_response_dto.dart';

abstract class RoleRemoteDatasource {
  Future<List<RoleResponseDto>> getRoles();
  Future<void> createRole(RoleCreateUpdateRequestDto request);
  Future<void> updateRole(String id, RoleCreateUpdateRequestDto request);
  Future<void> deleteRole(String id);
  Future<void> assignRolePermissions(String id, AssignRolePermissionsRequestDto request);
}
