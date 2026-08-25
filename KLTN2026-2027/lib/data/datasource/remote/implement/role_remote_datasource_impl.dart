import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/role/role_request_dto.dart';
import '../../../dto/role/role_response_dto.dart';
import '../abstract/role_remote_datasource.dart';
import '../base_remote_datasource.dart';

class RoleRemoteDatasourceImpl extends BaseRemoteDatasource implements RoleRemoteDatasource {
  final Dio dio;

  RoleRemoteDatasourceImpl(this.dio);

  @override
  Future<List<RoleResponseDto>> getRoles() async {
    try {
      final response = await dio.get(AppConfig.rolesPath);
      return handleListResponse(response, (item) => RoleResponseDto.fromJson(item));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> createRole(RoleCreateUpdateRequestDto request) async {
    try {
      final response = await dio.post(
        AppConfig.rolesPath,
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateRole(String id, RoleCreateUpdateRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.rolesPath}/$id',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      final response = await dio.delete('${AppConfig.rolesPath}/$id');
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> assignRolePermissions(String id, AssignRolePermissionsRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.rolesPath}/$id/permissions',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
