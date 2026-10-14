// lib/domain/usecases/auth/register_usecase.dart

import '../../entities/auth_register_result.dart';
import '../../entities/auth_token.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/token_storage_repository.dart';

class RegisterParams {
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String password;
  final int gender;
  final String skillLevel;

  const RegisterParams({
    required this.fullName,
    this.email,
    this.phoneNumber,
    required this.password,
    this.gender = 0,
    this.skillLevel = 'NB',
  });
}

class RegisterUseCase {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorage;

  RegisterUseCase(this.authRepository, this.tokenStorage);

  Future<AuthRegisterResult> execute(RegisterParams params) async {
    final result = await authRepository.register(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
      gender: params.gender,
      skillLevel: params.skillLevel,
    );

    // Save tokens if registration automatically authenticates the user
    if (result.accessToken.isNotEmpty) {
      final token = AuthToken(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userId: result.userId,
      );
      await tokenStorage.saveAuthToken(token);
    }

    return result;
  }
}
