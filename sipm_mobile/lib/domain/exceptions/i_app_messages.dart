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

  // --- Auth ---
  String get errorSessionExpired;
  String get otpVerification;

  // Khi thêm exception mới:
  // 1. Thêm getter ở đây
  // 2. Implement trong FlutterAppMessages
  // 3. Thêm key vào ARB files
}
