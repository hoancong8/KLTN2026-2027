import '../../../dto/notification/notification_message_dto.dart';
import '../../../dto/notification/register_device_token_request_dto.dart';

abstract class NotificationRemoteDatasource {
  Future<void> initialize();
  Future<String?> getToken();
  Future<void> registerDeviceToken(RegisterDeviceTokenRequestDto request);
  Future<void> deleteDeviceToken();
  Stream<NotificationMessageDto> get onMessageReceived;
  Stream<NotificationMessageDto> get onMessageOpened;
  NotificationMessageDto? getInitialMessage();
  void clearInitialMessage();
}
