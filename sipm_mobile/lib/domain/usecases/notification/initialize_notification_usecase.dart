import '../../repositories/notification_repository.dart';

class InitializeNotificationUseCase {
  final NotificationRepository repository;

  InitializeNotificationUseCase(this.repository);

  Future<void> execute() async {
    await repository.initialize();
  }
}
