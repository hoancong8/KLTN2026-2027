import '../../../dto/notification/notification_dto.dart';

abstract class NotificationRemoteDatasource {
  Future<List<NotificationDto>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

