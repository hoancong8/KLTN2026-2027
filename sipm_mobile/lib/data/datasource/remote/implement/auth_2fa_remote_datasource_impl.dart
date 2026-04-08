import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/data/dto/auth/login_response_dto.dart';
import 'package:sipm_mobile/data/dto/auth/otp_login_request_dto.dart';
import 'package:dio/dio.dart';
import '../abstract/auth_2fa_remote_datasource.dart';
import '../base_remote_datasource.dart';

class Auth2faRemoteDatasourceImpl extends BaseRemoteDatasource implements Auth2FARemoteDatasource{
  final Dio _dio;
  Auth2faRemoteDatasourceImpl(this._dio);

  @override
  Future<LoginResponseDto> loginWithOtp(OtpLoginRequestDto request) async{
    try {
      final res = await _dio.post(
        AppConfig.login,
        data: request.toJson(),
      );

      return handleResponse(res, (data) => LoginResponseDto.fromJson(data));
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> sendOtp({required String provider}) async {
    try {
      final res = await _dio.post(
        AppConfig.sendTwoFactorCode,
        data: {
          'provider': provider,
        }
      );
      return handleResponse(res, (data) => null);
    } catch (e) {
      throw handleError(e);
    }
  }
}
