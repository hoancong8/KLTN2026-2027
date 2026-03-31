class AppMessages {
  // Common Messages
  static const success = 'Thành công';
  static const unknownError = 'Lỗi không xác định';

  // Network Error Messages
  static const networkError = 'Không thể kết nối máy chủ';
  static const connectionTimeout = 'Hết thời gian kết nối';
  static const receiveTimeout = 'Hết thời gian nhận dữ liệu';

  // HTTP Error Messages
  static const unauthorized = 'Phiên đăng nhập đã hết hạn';
  static const forbidden = 'Không có quyền truy cập';
  static const notFound = 'Không tìm thấy dữ liệu';
  static const serverError = 'Lỗi hệ thống';

  // Auth Messages
  static const loginSuccess = 'Đăng nhập thành công';
  static const loginFailed = 'Đăng nhập thất bại';
  static const logoutSuccess = 'Đăng xuất thành công';
  static const invalidCredentials = 'Tên đăng nhập hoặc mật khẩu không đúng';
  static const otpSent = 'Mã OTP đã được gửi';
  static const otpInvalid = 'Mã OTP không hợp lệ';
  static const otpExpired = 'Mã OTP đã hết hạn';
}
