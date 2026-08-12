import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/notification/notification_message_dto.dart';
import '../../../dto/notification/register_device_token_request_dto.dart';
import '../abstract/notification_remote_datasource.dart';
import '../base_remote_datasource.dart';

class NotificationRemoteDatasourceImpl extends BaseRemoteDatasource
    implements NotificationRemoteDatasource {
  final Dio dio;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localNotifications;
  final int? Function()? userIdProvider;

  final _messageReceivedController =
  StreamController<NotificationMessageDto>.broadcast();
  final _messageOpenedController =
  StreamController<NotificationMessageDto>.broadcast();

  NotificationMessageDto? _initialMessageCache;
  final Set<int> _foregroundLocalNotificationIds = {};

  NotificationRemoteDatasourceImpl({
    required this.dio,
    required this.messaging,
    required this.localNotifications,
    this.userIdProvider,
  });

  @override
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    void onDidReceiveNotificationResponse(NotificationResponse response) {
      if (response.payload == null) return;
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _messageOpenedController.add(NotificationMessageDto(
          title: null,
          body: null,
          data: data,
        ));
      } catch (_) {}
    }

    await localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    await localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    final fcmSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (fcmSettings.authorizationStatus == AuthorizationStatus.denied) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (_isMessageFromSelf(message)) return;
      final dto = NotificationMessageDto.fromRemoteMessage(message);
      _messageReceivedController.add(dto);
      final messageId = int.tryParse(message.messageId ?? '');
      if (messageId != null) _foregroundLocalNotificationIds.add(messageId);
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageId = int.tryParse(message.messageId ?? '');
      if (messageId != null && _foregroundLocalNotificationIds.remove(messageId)) return;
      final dto = NotificationMessageDto.fromRemoteMessage(message);
      _messageOpenedController.add(dto);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null && !_isMessageFromSelf(initialMessage)) {
      _initialMessageCache = NotificationMessageDto.fromRemoteMessage(initialMessage);
    }
  }

  bool _isMessageFromSelf(RemoteMessage message) {
    if (userIdProvider == null) return false;
    final currentUserId = userIdProvider!();
    if (currentUserId == null) return false;
    final senderIdRaw = message.data['userId'] ?? message.data['senderId'];
    if (senderIdRaw == null) return false;
    try {
      return int.parse(senderIdRaw.toString()) == currentUserId;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;
    await localNotifications.show(
      message.hashCode, // local notification display ID
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: payload,
    );
  }

  @override
  Future<String?> getToken() => messaging.getToken();

  @override
  Future<void> registerDeviceToken(RegisterDeviceTokenRequestDto request) async {
    try {
      await dio.post(AppConfig.registerDeviceToken, data: request.toJson());
    } catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteDeviceToken() async {
    final token = await messaging.getToken();
    if (token == null) return;
    try {
      await dio.delete(
        AppConfig.deleteDeviceToken,
        queryParameters: {'deviceToken': token},
      );
    } catch (_) {
      try {
        await dio.delete(AppConfig.deleteDeviceToken, data: {'deviceToken': token});
      } catch (e) {
        throw handleError(e);
      }
    }
  }

  @override
  NotificationMessageDto? getInitialMessage() => _initialMessageCache;

  @override
  void clearInitialMessage() => _initialMessageCache = null;

  @override
  Stream<NotificationMessageDto> get onMessageReceived =>
      _messageReceivedController.stream;

  @override
  Stream<NotificationMessageDto> get onMessageOpened =>
      _messageOpenedController.stream;
}
