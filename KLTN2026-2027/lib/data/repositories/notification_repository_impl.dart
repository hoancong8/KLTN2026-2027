import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/remote/abstract/notification_remote_datasource.dart';
import '../mapper/notification_mapper.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remote;

  NotificationRepositoryImpl(this.remote);

  @override
  Future<List<AppNotification>> getMyNotifications() async {
    final dtos = await remote.getMyNotifications();
    return NotificationMapper.toEntities(dtos);
  }

  @override
  Future<void> markAsRead(String id) {
    return remote.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return remote.markAllAsRead();
  }
}

