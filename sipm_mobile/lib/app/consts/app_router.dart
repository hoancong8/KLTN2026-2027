// app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/domain/entities/employee.dart';
import 'package:sipm_mobile/ui/screen/home/home_screen.dart';
import 'package:sipm_mobile/ui/screen/login/login_screen.dart';
import 'package:sipm_mobile/ui/screen/otp/otp_screen.dart';
import 'package:sipm_mobile/ui/screen/profile/profile_screen.dart';
import 'package:sipm_mobile/ui/screen/change_password/change_password_screen.dart';
import '../../ui/screen/blocked_users/blocked_user_screen.dart';
import '../../ui/screen/chat_detail/chat_detail_screen.dart';
import '../../ui/screen/home/tab/chat/widgets/full_screen_image_screen.dart';
import 'app_config.dart';

/// Global navigator key for accessing navigation from anywhere (e.g., Dio interceptor)
final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter generateAppRouter(String initialRoute) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: AppConfig.splashPath,
        builder: (_, __) =>
            Scaffold(body: Center(child: Text("Splash Screen Obsolete"))),
      ),
      GoRoute(
        path: AppConfig.loginPath,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConfig.otpPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return OtpScreen(
            username: extra['username']!,
            password: extra['password']!,
          );
        },
      ),
      GoRoute(path: AppConfig.homePath, builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: AppConfig.profilePath,
        builder: (context, state) {
          final initialEmployee = state.extra as Employee?;
          return ProfileScreen(initialEmployee: initialEmployee);
        },
      ),
      GoRoute(
        path: AppConfig.changePasswordPath,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppConfig.blockedUsersPath,
        builder: (_, __) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: AppConfig.chatDetailPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ChatDetailScreen(
            userId: extra['userId'] as int,
            userName: extra['userName'] as String,
            isOnline: extra['isOnline'] as bool,
            isBlocked: extra['isBlocked'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppConfig.fullScreenImagePath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FullScreenImageScreen(
            imageUrl: extra['imageUrl'] as String,
            headers: extra['headers'] as Map<String, String>?,
          );
        },
      ),
    ],
  );
}
