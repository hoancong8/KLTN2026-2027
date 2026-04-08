import 'dart:io';
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

    if (error is SocketException) {
      return AppException(l10nSelector: (l) => l.error_connection);
    }

    return AppException(
      l10nSelector: (l) => l.error_system,
      originalError: error,
    );
  }

  static AppException _handleDioException(DioException e) {
    // 1. Kiểm tra nếu request bị cancel (thường do Interceptor báo hết hạn phiên)
    if (e.type == DioExceptionType.cancel) {
      return SessionExpiredException();
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // 2. Thử bóc tách message từ nội dung trả về của Server (ABP Framework)
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      // ABP thường để lỗi trong trường 'error'
      final error = data['error'] ?? (data['result'] is Map ? data['result']['error'] : null);
      if (error is Map) {
        serverMessage = error['message']?.toString() ?? error['Message']?.toString();
      }
      serverMessage ??= data['message']?.toString();
    }

    // 3. Nếu là lỗi xác thực 401
    if (statusCode == 401) {
      return AuthFailedException(serverMessage);
    }

    // 4. Các lỗi HTTP thông dụng khác
    if (statusCode != null) {
      if (statusCode == 403) {
        return AppException(l10nSelector: (l) => l.error_forbidden);
      }
      if (statusCode == 404) {
        return AppException(l10nSelector: (l) => l.error_not_found);
      }
      if (statusCode >= 500) {
        return AppException(l10nSelector: (l) => l.error_server);
      }
    }

    // 5. Các lỗi Network của Dio
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException(l10nSelector: (l) => l.error_network_timeout);
    }

    if (e.type == DioExceptionType.connectionError) {
      return AppException(l10nSelector: (l) => l.error_connection);
    }

    // 6. Fallback
    return AppException(
      message: serverMessage,
      l10nSelector: serverMessage == null ? (l) => l.error_system : null,
      originalError: e,
    );
  }
}
