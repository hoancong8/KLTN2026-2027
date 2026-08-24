import 'package:dio/dio.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/user/user_lock_request_dto.dart';
import '../../../dto/user/user_response_dto.dart';
import '../../../dto/user/user_roles_request_dto.dart';
import '../abstract/user_remote_datasource.dart';
import '../base_remote_datasource.dart';

class UserRemoteDatasourceImpl extends BaseRemoteDatasource implements UserRemoteDatasource {
  final Dio dio;

  UserRemoteDatasourceImpl(this.dio);

  @override
  Future<UserResponseDto> getUserMe() async {
    try {
      final response = await dio.get(AppConfig.userMePath);
      return handleResponse(response, (data) => UserResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<PagedResultDto<UserResponseDto>> getUsers({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
  }) async {
    try {
      final response = await dio.get(
        AppConfig.usersPath,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
        },
      );
      return handleResponse(
        response,
        (data) => PagedResultDto.fromJson(data, (item) => UserResponseDto.fromJson(item)),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<UserResponseDto> getUserById(String id) async {
    try {
      final response = await dio.get('${AppConfig.usersPath}/$id');
      return handleResponse(response, (data) => UserResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> lockUser(String id, UserLockRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.usersPath}/$id/lock',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> updateUserRoles(String id, UserRolesRequestDto request) async {
    try {
      final response = await dio.put(
        '${AppConfig.usersPath}/$id/roles',
        data: request.toJson(),
      );
      return handleResponse(response, (_) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
