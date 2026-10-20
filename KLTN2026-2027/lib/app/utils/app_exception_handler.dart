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

    // 2. Thử bóc tách message từ nội dung trả về của Server (RFC 7807 ProblemDetails hoặc ABP)
    String? message;
    if (data is Map) {
      // 2.1 Bóc tách mảng errors trong RFC 7807 ValidationProblemDetails trước tiên
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final errorMessages = <String>[];
        for (final entry in errors.entries) {
          if (entry.value is List) {
            for (final msg in (entry.value as List)) {
              if (msg != null && msg.toString().trim().isNotEmpty) {
                errorMessages.add(msg.toString().trim());
              }
            }
          } else if (entry.value != null && entry.value.toString().trim().isNotEmpty) {
            errorMessages.add(entry.value.toString().trim());
          }
        }
        if (errorMessages.isNotEmpty) {
          message = errorMessages.first;
        }
      }

      // 2.2 Chuẩn RFC 7807 ProblemDetails (detail)
      message ??= data['detail']?.toString();

      // 2.3 Fallback ABP error object
      if (message == null) {
        final error = data['error'] ?? (data['result'] is Map ? data['result']['error'] : null);
        if (error is Map) {
          message = error['message']?.toString() ?? error['Message']?.toString();
        }
      }
      message ??= data['message']?.toString();

      // 2.4 Fallback title nếu không có message cụ thể và title không phải chuỗi chung chung
      if (message == null && data['title'] != null) {
        final title = data['title'].toString();
        if (title.isNotEmpty && title != 'One or more validation errors occurred.') {
          message = title;
        }
      }
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
