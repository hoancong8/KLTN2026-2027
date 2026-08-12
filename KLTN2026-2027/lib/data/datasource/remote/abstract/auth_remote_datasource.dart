import '../../../dto/auth/change_password_request_dto.dart';
import '../../../dto/auth/login_request_dto.dart';
import '../../../dto/auth/login_response_dto.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<bool> changePassword(ChangePasswordRequestDto request);
  Future<void> logout();
  Future<LoginResponseDto> refreshToken(String refreshToken);
}
