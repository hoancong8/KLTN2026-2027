import '../../entities/notification_message.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationMessageStreamUseCase {
  final NotificationRepository repository;

  GetNotificationMessageStreamUseCase(this.repository);

  Stream<NotificationMessage> execute() {
    return repository.onMessageReceived;
  }
}
