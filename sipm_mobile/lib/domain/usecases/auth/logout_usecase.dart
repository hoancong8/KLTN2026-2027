import 'package:sipm_mobile/app/consts/app_log.dart';
import 'package:sipm_mobile/domain/repositories/auth_repository.dart';
import 'package:sipm_mobile/domain/repositories/token_storage_repository.dart';
import 'delete_device_token_usecase.dart';

class LogoutUseCase {
  final AuthRepository repository;
  final TokenStorageRepository tokenStorage;
  final DeleteDeviceTokenUseCase deleteDeviceTokenUseCase;

  LogoutUseCase(
    this.repository,
    this.tokenStorage,
    this.deleteDeviceTokenUseCase,
  );

  Future<void> execute() async {
    // Delete device token trước khi logout (ignore errors)
    try {
      await deleteDeviceTokenUseCase.execute();
    } catch (e) {
      AppLog.info('[LogoutUseCase] Failed to delete device token: $e');
    }

    await repository.logout();
    await tokenStorage.clearAuthToken();
  }
}
