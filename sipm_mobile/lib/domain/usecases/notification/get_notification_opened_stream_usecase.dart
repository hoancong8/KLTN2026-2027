import '../../entities/notification_message.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationOpenedStreamUseCase {
  final NotificationRepository repository;

  GetNotificationOpenedStreamUseCase(this.repository);

  Stream<NotificationMessage> execute() {
    return repository.onMessageOpened;
  }
}
