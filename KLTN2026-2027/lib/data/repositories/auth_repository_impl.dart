import '../../domain/entities/auth_register_result.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote/abstract/auth_remote_datasource.dart';
import '../dto/auth/change_password_request_dto.dart';
import '../dto/auth/login_request_dto.dart';
import '../dto/auth/register_request_dto.dart';
import '../mapper/auth_mapper.dart';
import '../mapper/auth_register_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  AuthRepositoryImpl(this.remote);

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
    return AuthMapper.toEntity(res);
  }

  @override
  Future<AuthRegisterResult> register({
    required String fullName,
    String? email,
    String? phoneNumber,
    required String password,
    int gender = 0,
    String skillLevel = 'NB',
  }) async {
    final dto = RegisterRequestDto(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      gender: gender,
      skillLevel: skillLevel,
    );
    final res = await remote.register(dto);
    return AuthRegisterMapper.toEntity(res);
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
      throw const ChangePasswordFailedException();
    }
  }

  @override
  Future<void> logout() async {
    await remote.logout();
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final res = await remote.refreshToken(refreshToken);
    return AuthMapper.toEntity(res);
  }
}
