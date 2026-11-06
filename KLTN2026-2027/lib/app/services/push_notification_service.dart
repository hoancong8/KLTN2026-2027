import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../consts/app_config.dart';
import '../consts/app_log.dart';
import '../consts/app_router.dart';
import '../theme/theme.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  Future<void> requestPermission() async {
    try {
      if (kIsWeb) return;
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      AppLog.info('[FCM] Permission status: ${settings.authorizationStatus}');

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      AppLog.info('[FCM] requestPermission error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      if (kIsWeb) return null;
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLog.info('[FCM] getToken error: $e');
      return null;
    }
  }

  String getPlatform() {
    if (kIsWeb) return 'WEB';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'IOS';
    return 'ANDROID';
  }

  void initForegroundHandler({VoidCallback? onNotificationReceived}) {
    if (kIsWeb) return;
    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLog.info('[FCM Foreground] Received: ${message.notification?.title}');
      onNotificationReceived?.call();
      _showInAppNotificationBanner(message);
    });
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
  }

  void _showInAppNotificationBanner(RemoteMessage message) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final title = message.notification?.title ?? message.data['title'] ?? 'Thông báo mới';
    final body = message.notification?.body ?? message.data['body'] ?? message.data['content'] ?? '';
    final colors = context.colors;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.base),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        backgroundColor: colors.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colors.cardBorder),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_active_rounded, color: colors.primary, size: 20),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (body.isNotEmpty) ...[
                    AppSpacing.gapH4,
                    Text(
                      body,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Xem',
          textColor: colors.primary,
          onPressed: () {
            context.push(AppConfig.notificationsPath);
          },
        ),
      ),
    );
  }
}

