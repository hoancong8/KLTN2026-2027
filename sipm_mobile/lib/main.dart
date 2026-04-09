// main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';
import 'package:sipm_mobile/domain/entities/auth_token.dart';
import 'app/consts/app_config.dart';
import 'app/my_app.dart';
import 'app/services/secure_storage_service.dart';
import 'app/provider.dart';
import 'app/services/signalr_service.dart';
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

  if (!kIsWeb && AppConfig.env == 'dev') {
    HttpOverrides.global = DevHttpOverrides();
  }

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Determine initial route concurrently under native splash
  String initialRoute = AppConfig.loginPath;
  AuthToken? finalToken;
  try {
    final token = await SecureStorageService.instance.getAuthToken();
    if (token != null) {
      // Create a temporary container to use Riverpod for the refresh usecase
      final container = ProviderContainer(
        overrides: [authTokenProvider.overrideWith((_) => token)],
      );
      try {
        final newToken = await container
            .read(refreshTokenUseCaseProvider)
            .execute(token);
        // Refresh success
        await SecureStorageService.instance.saveAuthToken(newToken);
        initialRoute = AppConfig.homePath;
        finalToken = newToken;
      } catch (e) {
        AppLog.info('[Main] Token refresh failed: $e');
        initialRoute = AppConfig.loginPath;
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
      overrides: finalToken != null
          ? [authTokenProvider.overrideWith((ref) => finalToken)]
          : [],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}
