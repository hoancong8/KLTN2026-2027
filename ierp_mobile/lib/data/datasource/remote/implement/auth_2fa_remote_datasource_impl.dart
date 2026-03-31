import 'package:ierp_mobile/app/consts/app_config.dart';
import 'package:ierp_mobile/data/dto/auth/login_response_dto.dart';

import 'package:ierp_mobile/data/dto/auth/otp_login_request_dto.dart';
import 'package:dio/dio.dart';

import '../abstract/auth_2fa_remote_datasource.dart';

class Auth2faRemoteDatasourceImpl implements Auth2FARemoteDatasource{
  final Dio _dio;
  Auth2faRemoteDatasourceImpl(this._dio);

  @override
  Future<LoginResponseDto> loginWithOtp(OtpLoginRequestDto request) async{
    final res = await _dio.post(
      AppConfig.login,
      data: request.toJson(),
    );

    return LoginResponseDto.fromJson(res.data);
  }

  @override
  Future<void> sendOtp({required String provider}) async {
    await _dio.post(
      AppConfig.sendTwoFactorCode,
      data: {
        'provider': provider,
      }
    );
  }

}