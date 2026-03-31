import '../../repositories/notification_repository.dart';

class DeleteDeviceTokenUseCase {
  final NotificationRepository repository;

  DeleteDeviceTokenUseCase(this.repository);

  Future<void> execute() async {
    await repository.deleteDeviceToken();
  }
}
