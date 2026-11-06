import '../../entities/app_notification.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<AppNotification>> execute() {
    return repository.getMyNotifications();
  }
}

