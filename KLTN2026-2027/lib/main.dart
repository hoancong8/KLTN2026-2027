// main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';
import 'app/consts/app_config.dart';
import 'app/my_app.dart';
import 'app/services/secure_storage_service.dart';
import 'app/provider.dart';
import 'firebase_options.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLog.info(
    '[FCM Background] Message received: ${message.notification?.title}',
  );
}

void main() async {
  // 1. Preserve native splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    try {
      final token = await FirebaseMessaging.instance.getToken();
      AppLog.info('===> FCM TOKEN: $token');
    } catch (e) {
      AppLog.info('===> FCM GET TOKEN ERROR: $e');
    }
  }

  // 3. Determine initial route concurrently under native splash
  String initialRoute = AppConfig.loginPath;
  AuthToken? finalToken;
  UserProfile? initialUserProfile;

  try {
    final token = await SecureStorageService.instance.getAuthToken();
    if (token != null) {
      finalToken = token;
      initialRoute = AppConfig.homePath;

      // Create a temporary container to use Riverpod for fetching profile on startup
      final container = ProviderContainer(
        overrides: [authTokenProvider.overrideWith((_) => token)],
      );
      try {
        // 1. Thử fetch User Profile & Permissions bằng token hiện tại
        initialUserProfile = await container
            .read(currentUserProfileProvider.notifier)
            .fetchProfile();

        // 2. Nếu fetch profile trả về null (token hết hạn), thử refresh token dự phòng
        if (initialUserProfile == null) {
          try {
            final newToken = await container
                .read(refreshTokenUseCaseProvider)
                .execute(token);
            await SecureStorageService.instance.saveAuthToken(newToken);
            finalToken = newToken;

            final refreshContainer = ProviderContainer(
              overrides: [authTokenProvider.overrideWith((_) => newToken)],
            );
            try {
              initialUserProfile = await refreshContainer
                  .read(currentUserProfileProvider.notifier)
                  .fetchProfile();
            } finally {
              refreshContainer.dispose();
            }
          } catch (refreshErr) {
            AppLog.info('[Main] Token refresh failed: $refreshErr');
            // Nếu cả token hiện tại và refresh đều không hợp lệ -> mới đưa về login
            finalToken = null;
            initialRoute = AppConfig.loginPath;
            await SecureStorageService.instance.clearAuthToken();
          }
        }
      } catch (e) {
        AppLog.info('[Main] Profile fetch error: $e');
      } finally {
        container.dispose();
      }
    }
  } catch (e) {
    AppLog.info('[Main] Auth check failed: $e');
  }

  // 4. Run app
  runApp(
    ProviderScope(
      overrides: [
        if (finalToken != null)
          authTokenProvider.overrideWith((ref) => finalToken),
        if (initialUserProfile != null)
          currentUserProfileProvider.overrideWith(
            () => CurrentUserProfileNotifier(initialUserProfile),
          ),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}
