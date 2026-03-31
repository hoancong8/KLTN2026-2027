import '../../repositories/notification_repository.dart';

class RegisterDeviceTokenUseCase {
  final NotificationRepository repository;

  RegisterDeviceTokenUseCase(this.repository);

  Future<void> execute() async {
    final token = await repository.getDeviceToken();
    if (token != null) {
      await repository.registerDeviceToken(token);
    }
  }
}
