import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

