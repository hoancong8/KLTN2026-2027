import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/domain/repositories/auth_repository.dart';
import 'package:kltn2026_2027/domain/repositories/token_storage_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  final TokenStorageRepository tokenStorage;

  LogoutUseCase(
    this.repository,
    this.tokenStorage,
  );

  Future<void> execute() async {
    try {
      await repository.logout();
    } catch (e) {
      AppLog.info('[LogoutUseCase] Failed to logout from remote: $e');
    }

    await tokenStorage.clearAuthToken();
  }
}
