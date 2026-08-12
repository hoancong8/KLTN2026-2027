import 'package:kltn2026_2027/app/consts/app_log.dart';

import '../../../app/services/secure_storage_service.dart';
import '../../entities/auth_token.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/token_storage_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  final TokenStorageRepository tokenStorage;

  LoginUseCase(this.repository, this.tokenStorage);

  Future<AuthToken> execute({
    required String username,
    required String password,
  }) async {
    final token = await repository.login(
      username: username,
      password: password,
    );

    // Luôn lưu token
    await tokenStorage.saveAuthToken(token);
    await tokenStorage.setRememberMe(true);
    AppLog.info(
      '[LoginUseCase] RefreshToken saved to storage: ${SecureStorageService.instance.getAuthToken()}',
    );
    if (username.trim().isNotEmpty && password.isNotEmpty) {
      await tokenStorage.saveLastLoginCredentials(username.trim(), password);
    }
    return token;
  }
}
