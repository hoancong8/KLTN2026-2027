import '../../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.markAsRead(id);
  }
}

