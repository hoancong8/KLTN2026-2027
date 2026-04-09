import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';
import '../../../../app/consts/app_config.dart';
import '../../../dto/notification/notification_message_dto.dart';
import '../../../dto/notification/register_device_token_request_dto.dart';
import '../abstract/notification_remote_datasource.dart';

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final Dio dio;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localNotifications;

  final _messageReceivedController =
      StreamController<NotificationMessageDto>.broadcast();

  final _messageOpenedController =
      StreamController<NotificationMessageDto>.broadcast();

  // Cache initial message
  NotificationMessageDto? _initialMessageCache;

  final int? Function()? userIdProvider;

  NotificationRemoteDatasourceImpl({
    required this.dio,
    required this.messaging,
    required this.localNotifications,
    this.userIdProvider,
  });

  // Track message IDs that were displayed as local notifications while the app
  // was in the foreground. For these messages, the tap is handled by
  // onDidReceiveNotificationResponse. We must NOT also handle them in
  // onMessageOpenedApp to avoid double-navigation.
  final Set<int> _foregroundLocalNotificationIds = {};

  @override
  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    // Callback for when a notification is tapped while the app is running
    void onDidReceiveNotificationResponse(NotificationResponse response) {
      if (response.payload != null) {
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          AppLog.info('[FCM] Local notification tapped with data: $data');
          final dto = NotificationMessageDto(
            title:
                null, // Title and body are already shown, only data matters for routing
            body: null,
            data: data,
          );
          _messageOpenedController.add(dto);
        } catch (e) {
          AppLog.info('[FCM] Error decoding notification payload: $e');
        }
      }
    }

    await localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );
    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // Request FCM permission
    final fcmSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (fcmSettings.authorizationStatus == AuthorizationStatus.denied) {
      AppLog.info('[FCM] User declined notification permissions');
      return;
    }

    AppLog.info('[FCM] Permission granted: ${fcmSettings.authorizationStatus}');

    // Get and print FCM token
    final token = await messaging.getToken();
    AppLog.info('[FCM] Device Token: $token');

    // Listen to foreground messages — these are shown as local notifications.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (_isMessageFromSelf(message)) {
        AppLog.info('[FCM] Skipping self-sent foreground message');
        return;
      }

      AppLog.info(
        '[FCM] Foreground message received: ${message.notification?.title}',
      );
      final dto = NotificationMessageDto.fromRemoteMessage(message);
      _messageReceivedController.add(dto);
      _foregroundLocalNotificationIds.add(message.hashCode);
      _showLocalNotification(message);
    });

    // Listen to messages opened from background/terminated state.
    // Skip messages that were shown as foreground local notifications because
    // their tap is already handled by onDidReceiveNotificationResponse.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLog.info(
        '[FCM] Message opened from background: ${message.notification?.title}',
      );
      if (_foregroundLocalNotificationIds.remove(message.hashCode)) {
        AppLog.info(
          '[FCM] Skipping onMessageOpenedApp — already handled as local notification tap',
        );
        return;
      }
      final dto = NotificationMessageDto.fromRemoteMessage(message);
      _messageOpenedController.add(dto);
    });

    // Check if app was opened from a terminated state.
    // We only store the message in cache. HomeViewModel reads it via
    // GetInitialNotificationMessageUseCase — no stream event is fired here
    // to avoid the 500ms race condition with subscriber registration.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null && !_isMessageFromSelf(initialMessage)) {
      AppLog.info(
        '[FCM] App opened from terminated state: ${initialMessage.notification?.title}',
      );
      _initialMessageCache = NotificationMessageDto.fromRemoteMessage(
        initialMessage,
      );
    }
  }

  bool _isMessageFromSelf(RemoteMessage message) {
    if (userIdProvider == null) return false;
    final currentUserId = userIdProvider!();
    final data = message.data;

    AppLog.info('[FCM Debug] currentUserId: $currentUserId');
    AppLog.info('[FCM Debug] Notification data: $data');

    if (currentUserId == null) return false;

    // ABP/Chat typically includes userId or senderId in the data payload
    final senderIdRaw = data['userId'] ?? data['senderId'];
    if (senderIdRaw == null) return false;

    try {
      final senderId = int.parse(senderIdRaw.toString());
      final isSelf = senderId == currentUserId;
      AppLog.info('[FCM Debug] senderId: $senderId, isSelf: $isSelf');
      return isSelf;
    } catch (e) {
      AppLog.info('[FCM Debug] Error parsing senderId: $e');
      return false;
    }
  }

  @override
  NotificationMessageDto? getInitialMessage() => _initialMessageCache;

  @override
  void clearInitialMessage() {
    _initialMessageCache = null;
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
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Encode data to string payload
    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;

    await localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: payload,
    );
  }

  @override
  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  @override
  Future<void> registerDeviceToken(
    RegisterDeviceTokenRequestDto request,
  ) async {
    await dio.post(AppConfig.registerDeviceToken, data: request.toJson());
    AppLog.info('[FCM] Device token registered: ${request.deviceToken}');
  }

  @override
  Future<void> deleteDeviceToken() async {
    final token = await messaging.getToken();
    if (token != null) {
      try {
        // Thử với query parameter trước
        await dio.delete(
          AppConfig.deleteDeviceToken,
          queryParameters: {'deviceToken': token},
        );
        AppLog.info('[FCM] Device token deleted successfully: $token');
      } catch (e) {
        AppLog.info('[FCM] Delete token error: $e');
        // Nếu fail, thử với body
        try {
          await dio.delete(
            AppConfig.deleteDeviceToken,
            data: {'deviceToken': token},
          );
          AppLog.info('[FCM] Device token deleted with body: $token');
        } catch (e2) {
          AppLog.info('[FCM] Delete token failed both ways: $e2');
          rethrow;
        }
      }
    }
  }

  @override
  Stream<NotificationMessageDto> get onMessageReceived =>
      _messageReceivedController.stream;

  @override
  Stream<NotificationMessageDto> get onMessageOpened =>
      _messageOpenedController.stream;
}
