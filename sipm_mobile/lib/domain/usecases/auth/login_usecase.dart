import 'package:sipm_mobile/app/consts/app_log.dart';

import '../../../app/services/secure_storage_service.dart';
import '../../entities/auth_token.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthToken> execute({
    required String username,
    required String password,
  }) async {
    final token = await repository.login(
      username: username,
      password: password,
    );

    // Luôn lưu token
    await SecureStorageService.instance.saveAuthToken(token);
    await SecureStorageService.instance.setRememberMe(true);
    AppLog.info(
      '[LoginUseCase] RefreshToken saved to storage: ${SecureStorageService.instance.getAuthToken()}',
    );
    return token;
  }
}
