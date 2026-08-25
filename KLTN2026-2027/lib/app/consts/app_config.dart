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
      return 'http://192.168.1.80:54796'; // Production
    }

    if (kIsWeb) {
      return 'https://localhost:44302'; // Web Browser
    }

    // Development - Tự động detect platform
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://localhost:44302'; // iOS Simulator
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://10.0.2.2:44302'; // Android Emulator
    } else {
      return 'https://localhost:44302'; // Default
    }
  }

  // ===== 🔐 1. Authentication APIs (/api/v1/auth) =====
  static const login = '/api/v1/auth/login';
  static const register = '/api/v1/auth/register';
  static const refreshToken = '/api/v1/auth/refresh';
  static const logOut = '/api/v1/auth/logout';
  static const changePassword = '/api/services/app/Profile/ChangePassword';
  static const sendTwoFactorCode = '/api/TokenAuth/SendTwoFactorAuthCode';
  static const tenantInfo = '/TenantInfo';

  // ===== 🛡️ 2. Roles Management APIs (/api/v1/roles) =====
  static const rolesPath = '/api/v1/roles';

  // ===== 👥 3. User Management APIs (/api/v1/user) =====
  static const usersPath = '/api/v1/user';
  static const userMePath = '/api/v1/user/me';
  static const userPermissionsPath = '/api/v1/user/permissions';
  static const userAllPermissionsPath = '/api/v1/user/all-permissions';

  // ===== 🏢 3. Venues Management APIs (/api/v1/venues) =====
  static const venuesPath = '/api/v1/venues';

  // ===== 📅 4. Venue Schedules Management APIs (/api/v1/venue-schedules) =====
  static const venueSchedulesPath = '/api/v1/venue-schedules';

  // ===== 🏸 5. Courts Management APIs (/api/v1/courts) =====
  static const courtsPath = '/api/v1/courts';

  // ===== 💰 6. Court Pricings Management APIs (/api/v1/court-pricings) =====
  static const courtPricingsPath = '/api/v1/court-pricings';

  // ===== 🔔 Notification & Legacy Service APIs =====
  static const registerDeviceToken =
      '/api/services/app/FcmNotification/SaveDeviceToken';
  static const deleteDeviceToken =
      '/api/services/app/FcmNotification/RemoveDeviceToken';
  static const changeProfilePath = '/api/services/app/Employee/ChangeProfile';
  static const getProfilePath = '/api/services/app/Dms/GetEmployeeByUserId';
  static const sessionInfoPath =
      '/api/services/app/Session/GetCurrentLoginInformations';

  // ===== 💬 Chat Services =====
  static const getChatImage = '/App/Chat/GetImage';
  static const getChatFile = '/App/Chat/GetFile';
  static const uploadChatFile = '/App/Chat/UploadFile';
  static const getUserChatFriendsWithSettings =
      '/api/services/app/chat/GetUserChatFriendsWithSettings';
  static const getUserChatMessages =
      '/api/services/app/Chat/GetUserChatMessages';
  static const blockUser = '/api/services/app/Friendship/BlockUser';
  static const unblockUser = '/api/services/app/Friendship/UnblockUser';
  static const findUsers = '/api/services/app/CommonLookup/FindUsers';
  static const createFriendshipRequest =
      '/api/services/app/Friendship/CreateFriendshipRequest';
  static const markAllUnreadMessagesOfUserAsRead =
      '/api/services/app/Chat/MarkAllUnreadMessagesOfUserAsRead';

  // ===== 🚦 Routes App (GoRouter) =====
  static const splashPath = '/';
  static const loginPath = '/login';
  static const logoutPath = '/logOut';
  static const otpPath = '/otp';
  static const homePath = '/home';
  static const profilePath = '/profile';
  static const chatDetailPath = '/chat/detail';
  static const changePasswordPath = '/change-password';
  static const fullScreenImagePath = '/full-screen-image';
  static const blockedUsersPath = '/blockedUsers';
}
