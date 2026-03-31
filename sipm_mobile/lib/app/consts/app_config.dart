import 'dart:io';

class AppConfig {
  // ===== Environment =====
  static const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  // ===== Base URL =====
  static final baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  // URL mặc định theo environment và platform
  static String get _defaultBaseUrl {
    if (env == 'prod') {
      return 'https://erp.lamhai.net'; // Production
    }

    // Development - Tự động detect platform
    if (Platform.isIOS) {
      return 'https://localhost:44302'; // iOS Simulator
    } else if (Platform.isAndroid) {
      return 'https://10.0.2.2:44302'; // Android Emulator
    } else {
      return 'https://localhost:44302'; // Default
    }
  }

  // Lưu ý khi test trên máy thật (Real Device):
  // Máy thật KHÔNG thể dùng localhost hay 10.0.2.2
  // Phải dùng IP máy tính trong cùng mạng WiFi:
  //
  // Cách 1: Dùng --dart-define khi chạy
  // flutter run --dart-define=BASE_URL=http://192.168.1.100:44302
  //
  // Cách 2: Tìm IP máy tính:
  // - Windows: mở CMD, gõ: ipconfig (tìm IPv4 Address)
  // - macOS/Linux: mở Terminal, gõ: ifconfig (tìm inet)
  // - Thường là: 192.168.1.x hoặc 192.168.0.x

  // ===== API paths =====
  static const login = '/api/TokenAuth/Authenticate';
  static const refreshToken = '/api/TokenAuth/RefreshToken';
  static const logOut = '/api/TokenAuth/LogOut';
  static const changePassword = '/api/services/app/Profile/ChangePassword';
  static const sendTwoFactorCode = '/api/TokenAuth/SendTwoFactorAuthCode';
  static const tenantInfo = '/TenantInfo';

  static const registerDeviceToken =
      '/api/services/app/FcmNotification/SaveDeviceToken';
  static const deleteDeviceToken =
      '/api/services/app/FcmNotification/RemoveDeviceToken';
  static const changeProfilePath = '/api/services/app/Employee/ChangeProfile';
  static const getProfilePath = '/api/services/app/Dms/GetEmployeeByUserId';
  static const sessionInfoPath =
      '/api/services/app/Session/GetCurrentLoginInformations';

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

  // ===== Routes =====
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
