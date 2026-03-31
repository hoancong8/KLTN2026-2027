import '../../entities/auth_token.dart';
import '../../repositories/auth_repository.dart';

class LoginWithOtpUseCase {
  final AuthRepository repository;

  LoginWithOtpUseCase(this.repository);

  Future<AuthToken> execute({
    required String username,
    required String password,
    required String code,
  }) {
    return repository.loginWithOtp(
      username: username,
      password: password,
      code: code,
    );
  }
}
