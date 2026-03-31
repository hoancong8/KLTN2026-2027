import '../entities/notification_message.dart';

abstract class NotificationRepository {
  Future<void> initialize();
  Future<String?> getDeviceToken();
  Future<void> registerDeviceToken(String deviceToken);
  Future<void> deleteDeviceToken();
  Stream<NotificationMessage> get onMessageReceived;
  Stream<NotificationMessage> get onMessageOpened;
  NotificationMessage? getInitialMessage();
  void clearInitialMessage();
}
