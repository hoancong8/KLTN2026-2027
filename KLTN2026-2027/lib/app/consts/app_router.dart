// app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/ui/screen/home/home_screen.dart';
import 'package:kltn2026_2027/ui/screen/login/login_screen.dart';
import 'package:kltn2026_2027/ui/screen/profile/profile_screen.dart';
import 'package:kltn2026_2027/ui/screen/change_password/change_password_screen.dart';
import '../../ui/screen/admin/role_management/role_management_screen.dart';
import '../../ui/screen/admin/user_management/user_management_screen.dart';
import '../../ui/screen/club/club_management_screen.dart';
import '../../ui/screen/club/create_club/create_club_screen.dart';
import '../../ui/screen/club/settings/club_settings_screen.dart';
import '../../ui/screen/club/role_management/club_role_management_screen.dart';
import '../../ui/screen/club/session_detail_screen.dart';
import '../../ui/screen/club_detail/club_detail_screen.dart';
import '../../ui/screen/explore_clubs/explore_clubs_screen.dart';
import '../../ui/screen/home/tab/explore/explore_recruitments_page.dart';
import '../../ui/screen/login/register_screen.dart';
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
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text("Splash Screen Obsolete"))),
      ),
      GoRoute(
        path: AppConfig.loginPath,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConfig.registerPath,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConfig.homePath,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConfig.profilePath,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConfig.changePasswordPath,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppConfig.adminUsersPath,
        builder: (_, _) => const UserManagementScreen(),
      ),
      GoRoute(
        path: AppConfig.adminRolesPath,
        builder: (_, _) => const RoleManagementScreen(),
      ),
      GoRoute(
        path: AppConfig.clubManagementPath,
        builder: (_, _) => const ClubManagementScreen(),
      ),
      GoRoute(
        path: AppConfig.exploreRecruitmentsScreenPath,
        builder: (_, _) => const ExploreRecruitmentsPage(),
      ),
      GoRoute(
        path: AppConfig.exploreClubsScreenPath,
        builder: (_, _) => const ExploreClubsScreen(),
      ),
      GoRoute(
        path: '/club/create',
        builder: (_, _) => const CreateClubScreen(),
      ),
      GoRoute(
        path: '/club/:clubId',
        builder: (_, state) {
          final clubId = state.pathParameters['clubId'] ?? '';
          return ClubDetailScreen(clubId: clubId);
        },
      ),
      GoRoute(
        path: '/club/:clubId/settings',
        builder: (_, state) {
          final clubId = state.pathParameters['clubId'] ?? '';
          return ClubSettingsScreen(clubId: clubId);
        },
      ),
      GoRoute(
        path: '/club/:clubId/roles',
        builder: (_, state) {
          final clubId = state.pathParameters['clubId'] ?? '';
          return ClubRoleManagementScreen(clubId: clubId);
        },
      ),
      GoRoute(
        path: '/session/:sessionId',
        builder: (_, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return SessionDetailScreen(sessionId: sessionId);
        },
      ),
    ],
  );
}
