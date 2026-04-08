import '../../../../app/consts/app_config.dart';
import '../../../dto/auth/change_password_request_dto.dart';
import '../../../dto/auth/login_request_dto.dart';
import '../../../dto/auth/login_response_dto.dart';
import '../abstract/auth_remote_datasource.dart';
import 'package:dio/dio.dart';
import '../base_remote_datasource.dart';

class AuthRemoteDatasourceImpl extends BaseRemoteDatasource implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl(this.dio);

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      final res = await dio.post(
        AppConfig.login,
        data: request.toJson(),
      );

      return handleResponse(res, (data) => LoginResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<bool> changePassword(ChangePasswordRequestDto request) async {
    try {
      final res = await dio.post(
        AppConfig.changePassword,
        data: request.toJson(),
      );

      return handleResponse(res, (data) => res.statusCode == 200);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.get(AppConfig.logOut);
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<LoginResponseDto> refreshToken(String refreshToken) async {
    try {
      final res = await dio.post(
        AppConfig.refreshToken,
        queryParameters: {'refreshToken': refreshToken},
      );
      return handleResponse(res, (data) => LoginResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }
}
