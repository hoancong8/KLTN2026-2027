import 'package:dio/dio.dart';
import '../../domain/exceptions/app_exception.dart';
import '../../domain/exceptions/auth_exceptions.dart';

class AppExceptionHandler {
  /// Hàm tĩnh để xử lý và chuyển đổi mọi lỗi thành AppException.
  static AppException handle(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error.runtimeType.toString() == 'SocketException') {
      return const ConnectionException();
    }

    return AppException(originalError: error);
  }

  static AppException _handleDioException(DioException e) {
    // 1. Kiểm tra nếu request bị cancel (thường do Interceptor báo hết hạn phiên)
    if (e.type == DioExceptionType.cancel) {
      return const SessionExpiredException();
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // 2. Thử bóc tách message từ nội dung trả về của Server (ABP Framework)
    String? message;
    if (data is Map<String, dynamic>) {
      // ABP thường để lỗi trong trường 'error'
      final error = data['error'] ?? (data['result'] is Map ? data['result']['error'] : null);
      if (error is Map) {
        message = error['message']?.toString() ?? error['Message']?.toString();
      }
      message ??= data['message']?.toString();
    }

    // 3. Nếu là lỗi xác thực 401
    if (statusCode == 401) {
      return AuthFailedException(message);
    }

    // 4. Các lỗi HTTP thông dụng khác
    if (statusCode != null) {
      if (statusCode == 403) return const ForbiddenException();
      if (statusCode == 404) return const NotFoundException();
      if (statusCode >= 500) return const ServerException();
    }

    // 5. Các lỗi Network của Dio
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkTimeoutException();
    }

    if (e.type == DioExceptionType.connectionError) {
      return const ConnectionException();
    }

    // 6. Fallback — dùng message nếu có, ngược lại base class trả errorSystem
    return AppException(message: message, originalError: e);
  }
}
