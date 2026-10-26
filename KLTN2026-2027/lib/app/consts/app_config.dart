import 'package:flutter/foundation.dart';

class AppConfig {
  // ===== Environment =====
  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  // ===== Base URL =====
  static const _overrideBaseUrl = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }
    return _defaultBaseUrl;
  }

  // URL mặc định theo environment và platform
  static String get _defaultBaseUrl {
    if (env == 'prod') {
      return 'http://192.168.1.24:54796'; // Production (IP máy tính hiện tại)
    }

    if (kIsWeb) {
      return 'http://localhost:54796'; // Web Browser
    }

    // Development - Tự động detect platform
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:54796'; // iOS Simulator
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:54796'; // Android Emulator
    } else {
      return 'http://localhost:54796'; // Default
    }
  }

  // ===== [API] 1. Authentication APIs (/api/v1/auth) =====
  static const login = '/api/v1/auth/login';
  static const register = '/api/v1/auth/register';
  static const externalRegister = '/api/v1/auth/external-register';
  static const refreshToken = '/api/v1/auth/refresh';
  static const logOut = '/api/v1/auth/logout';
  static const changePassword = '/api/v1/user/reset-password';

  // ===== [API] 2. Clubs Management APIs (/api/v1/clubs) =====
  static const clubsPath = '/api/v1/clubs';
  static const myClubsPath = '$clubsPath/my-clubs';
  static const clubJoinPath = '$clubsPath/join';
  static const clubsExplorePath = '$clubsPath/explore';
  static String clubDetailPath(String id) => '$clubsPath/$id';
  static String clubInfoPath(String id) => '$clubsPath/$id/info';
  static String clubSchedulesPath(String id) => '$clubsPath/$id/schedules';
  static String clubFeeRulePath(String id) => '$clubsPath/$id/fee-rule';
  static String clubMembersPath(String id) => '$clubsPath/$id/members';
  static String clubMemberRolePath(String id, String userId) =>
      '$clubsPath/$id/members/$userId/role';
  static String clubMemberDetailPath(String id, String userId) =>
      '$clubsPath/$id/members/$userId';
  static const clubPermissionsPath = '$clubsPath/permissions';
  static String clubRolesPath(String id) => '$clubsPath/$id/roles';
  static String clubRolePermissionsPath(String id, String roleId) =>
      '$clubsPath/$id/roles/$roleId/permissions';
  static String clubRoleDetailPath(String id, String roleId) =>
      '$clubsPath/$id/roles/$roleId';
  static String clubJoinRequestsPath(String id) =>
      '$clubsPath/$id/join-requests';
  static String clubApproveJoinRequestPath(String id, String requestId) =>
      '$clubsPath/$id/join-requests/$requestId/approve';
  static String clubRejectJoinRequestPath(String id, String requestId) =>
      '$clubsPath/$id/join-requests/$requestId/reject';

  // ===== [API] 3. Roles Management APIs (/api/v1/roles) =====
  static const rolesPath = '/api/v1/roles';

  // ===== [API] 4. User Management APIs (/api/v1/user) =====
  static const usersPath = '/api/v1/user';
  static const userMePath = '/api/v1/user/me';
  static const userProfilePath = '/api/v1/user/profile';
  static const userPermissionsPath = '/api/v1/user/permissions';
  static const userAllPermissionsPath = '/api/v1/user/all-permissions';

  // ===== [API] 5. Venues Management APIs (/api/v1/venues) =====
  static const venuesPath = '/api/v1/venues';
  static const venueRecommendationsPath = '/api/v1/venues/recommendations';

  // ===== [API] 6. Venue Schedules Management APIs (/api/v1/venue-schedules) =====
  static const venueSchedulesPath = '/api/v1/venue-schedules';

  // ===== [API] 7. Courts Management APIs (/api/v1/courts) =====
  static const courtsPath = '/api/v1/courts';

  // ===== [API] 8. Court Pricings Management APIs (/api/v1/court-pricings) =====
  static const courtPricingsPath = '/api/v1/court-pricings';

  // ===== [API] 9. Sessions Management APIs (/api/v1/sessions) =====
  static const sessionsPath = '/api/v1/sessions';
  static String sessionClubPath(String clubId) => '$sessionsPath/club/$clubId';
  static String sessionDetailPath(String sessionId) =>
      '$sessionsPath/$sessionId';
  static String sessionStatusPath(String sessionId) =>
      '$sessionsPath/$sessionId/status';
  static String sessionBookingsPath(String sessionId) =>
      '$sessionsPath/$sessionId/bookings';
  static String sessionMyBookingPath(String sessionId) =>
      '$sessionsPath/$sessionId/bookings/me';
  static String sessionConfirmBookingPath(String sessionId, String bookingId) =>
      '$sessionsPath/$sessionId/bookings/$bookingId/confirm';
  static const myBookingsPath = '$sessionsPath/my-bookings';
  static String sessionRecruitmentsPath(String sessionId) =>
      '$sessionsPath/$sessionId/recruitments';
  static const exploreRecruitmentsPath = '$sessionsPath/recruitments/explore';
  static String joinRecruitmentPath(String recruitmentId) =>
      '$sessionsPath/recruitments/$recruitmentId/join';
  static String cancelRecruitmentPath(String recruitmentId) =>
      '$sessionsPath/recruitments/$recruitmentId/cancel';

  // ===== [ROUTER] Routes App (GoRouter) =====
  static const splashPath = '/';
  static const loginPath = '/login';
  static const registerPath = '/register';
  static const logoutPath = '/logOut';
  static const homePath = '/home';
  static const profilePath = '/profile';
  static const changePasswordPath = '/change-password';
  static const adminUsersPath = '/admin/users';
  static const adminRolesPath = '/admin/roles';
  static const clubManagementPath = '/club/management';
  static const exploreClubsScreenPath = '/explore-clubs';
  static const exploreRecruitmentsScreenPath = '/explore-recruitments';
  static String clubDetailRoutePath(String clubId) => '/club/$clubId';
  static String sessionDetailRoutePath(String sessionId) =>
      '/session/$sessionId';
  static String createSessionRoutePath(String clubId) =>
      '/session-create/$clubId';
}
