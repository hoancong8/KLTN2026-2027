import '../../domain/entities/auth_token.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote/abstract/auth_2fa_remote_datasource.dart';
import '../datasource/remote/abstract/auth_remote_datasource.dart';
import '../dto/auth/change_password_request_dto.dart';
import '../dto/auth/login_request_dto.dart';
import '../dto/auth/otp_login_request_dto.dart';
import '../mapper/auth_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final Auth2FARemoteDatasource auth2faRemote;

  AuthRepositoryImpl(this.remote, this.auth2faRemote);

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final dto = LoginRequestDto(
      email: username,
      password: password,
    );

    final res = await remote.login(dto);

    if (res.requiresTwoFactorVerification) {
      throw RequiresTwoFactorException();
    }

    return AuthMapper.toEntity(res);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final success = await remote.changePassword(
      ChangePasswordRequestDto(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    if (!success) {
      throw ChangePasswordFailedException();
    }
  }

  @override
  Future<void> logout() async {
    await remote.logout();
  }

  @override
  Future<AuthToken> loginWithOtp({
    required String username,
    required String password,
    required String code,
  }) async {
    final res = await auth2faRemote.loginWithOtp(
      OtpLoginRequestDto(
        username: username,
        password: password,
        code: code,
      ),
    );

    return AuthMapper.toEntity(res);
  }

  @override
  Future<void> sendOtp({required String provider}) async {
    return await auth2faRemote.sendOtp(provider: provider);
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final res = await remote.refreshToken(refreshToken);
    return AuthMapper.toEntity(res);
  }
}
