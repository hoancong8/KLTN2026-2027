import 'package:dio/dio.dart';
import 'package:sipm_mobile/app/consts/app_messages.dart';
import 'package:sipm_mobile/data/datasource/remote/abstract/profile_remote_datasource.dart';
import 'package:sipm_mobile/data/mapper/profile_mapper.dart';
import 'package:sipm_mobile/domain/entities/employee.dart';
import 'package:sipm_mobile/domain/exceptions/auth_exceptions.dart';
import 'package:sipm_mobile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<Employee> getProfile(int employeeId) async {
    try {
      final response = await remote.getProfile(employeeId);
      return ProfileMapper.toEntity(response);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> changeProfile({required Employee employee}) async {
    try {
      final dto = ProfileMapper.toDto(employee);
      await remote.changeProfile(dto);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String? message;

    if (data is Map<String, dynamic>) {
      message = data['error']?['message'] as String?;
    }

    // Request bị cancel từ interceptor khi session expired
    if (e.type == DioExceptionType.cancel) {
      throw SessionExpiredException();
    }

    // 401 từ API trực tiếp (không qua interceptor)
    if (statusCode == 401) {
      throw SessionExpiredException();
    }

    switch (statusCode) {
      case 400:
        throw AuthFailedException(message ?? 'Yêu cầu không hợp lệ');
      case 403:
        throw AuthFailedException(message ?? AppMessages.forbidden);
      case 404:
        throw AuthFailedException(message ?? AppMessages.notFound);
      case 500:
        throw AuthFailedException(message ?? AppMessages.serverError);
      default:
        throw AuthFailedException(message ?? e.message ?? AppMessages.unknownError);
    }
  }
}
