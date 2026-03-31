import '../../entities/notification_message.dart';
import '../../repositories/notification_repository.dart';

class GetInitialNotificationMessageUseCase {
  final NotificationRepository repository;

  GetInitialNotificationMessageUseCase(this.repository);

  NotificationMessage? execute() {
    return repository.getInitialMessage();
  }

  void clear() {
    repository.clearInitialMessage();
  }
}
