import '../../domain/entities/app_notification.dart';
import '../dto/notification/notification_dto.dart';

class NotificationMapper {
  static AppNotification toEntity(NotificationDto dto) {
    return AppNotification(
      id: dto.id,
      title: dto.title,
      content: dto.content,
      type: dto.type,
      referenceType: dto.referenceType,
      referenceId: dto.referenceId,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
    );
  }

  static List<AppNotification> toEntities(List<NotificationDto> dtos) {
    return dtos.map(toEntity).toList();
  }
}

