import '../../../../app/consts/app_config.dart';
import '../../../dto/auth/change_password_request_dto.dart';
import '../../../dto/auth/login_request_dto.dart';
import '../../../dto/auth/login_response_dto.dart';
import '../abstract/auth_remote_datasource.dart';
import 'package:dio/dio.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl(this.dio);

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final res = await dio.post(
      AppConfig.login,
      data: request.toJson(),
    );

    return LoginResponseDto.fromJson(res.data);
  }

  @override
  Future<bool> changePassword(ChangePasswordRequestDto request) async {
    final res = await dio.post(
      AppConfig.changePassword,
      data: request.toJson(),
    );

    return res.statusCode == 200;
  }

  @override
  Future<void> logout() async {
    await dio.get(AppConfig.logOut);
  }

  @override
  Future<LoginResponseDto> refreshToken(String refreshToken) async {
    final res = await dio.post(
      AppConfig.refreshToken,
      queryParameters: {'refreshToken': refreshToken},
    );
    return LoginResponseDto.fromJson(res.data);
  }
}
