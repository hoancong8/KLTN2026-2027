/// Interface thuần Dart — không import bất kỳ thứ gì của Flutter.
/// Domain định nghĩa "hợp đồng" các thông báo lỗi mà nó cần.
/// Presentation layer (FlutterAppMessages) cung cấp concrete implementation.
abstract interface class IAppMessages {
  // --- Lỗi chung ---
  String get errorSystem;
  String get errorConnection;
  String get errorNetworkTimeout;
  String get errorForbidden;
  String get errorNotFound;
  String get errorServer;
  String get errorInvalidResponse;
  String get errorSignalRNotConnected;

  // --- Auth ---
  String get errorSessionExpired;
  String get otpVerification;
  String get authSessionExpiredTitle;
  String get authSessionExpiredMessage;
  String get authLoginAgain;

  // --- Biometric ---
  String get biometricReasonLogin;
  String get biometricNotAvailable;
  String get biometricNotEnrolled;
  String get biometricNotSetup;
  String get biometricAuthFailed;
  String get biometricNoCredentials;
  String get biometricInvalidCredentials;

  // Khi thêm exception mới:
  // 1. Thêm getter ở đây
  // 2. Implement trong FlutterAppMessages
  // 3. Thêm key vào ARB files
}
