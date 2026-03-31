import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationMessageDto {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;

  NotificationMessageDto({
    this.title,
    this.body,
    this.data,
  });

  factory NotificationMessageDto.fromRemoteMessage(RemoteMessage message) {
    return NotificationMessageDto(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
