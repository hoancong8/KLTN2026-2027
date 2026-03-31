import '../../app/mapper.dart';
import '../../domain/entities/notification_message.dart';
import '../dto/notification/notification_message_dto.dart';

class NotificationMapper extends Mapper<NotificationMessageDto, NotificationMessage> {
  @override
  NotificationMessage map(NotificationMessageDto input) {
    return NotificationMessage(
      title: input.title,
      body: input.body,
      data: input.data,
    );
  }
}