import '../../../dto/auth/login_response_dto.dart';
import '../../../dto/auth/otp_login_request_dto.dart';

abstract class Auth2FARemoteDatasource {
  Future<void> sendOtp({required String provider});
  Future<LoginResponseDto> loginWithOtp(OtpLoginRequestDto request);
}