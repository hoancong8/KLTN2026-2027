import 'i_app_messages.dart';

/// Lớp ngoại lệ cơ sở cho toàn bộ ứng dụng.
/// Domain không biết về Flutter — chỉ biết [IAppMessages].
class AppException implements Exception {
  final String? message;
  final dynamic originalError;

  const AppException({this.message, this.originalError});

  /// Trả về thông báo đã được dịch.
  /// Ưu tiên [message] từ API, fallback về [IAppMessages.errorSystem].
  /// Subclass override method này để chọn đúng key.
  String resolve(IAppMessages messages) =>
      (message?.isNotEmpty == true) ? message! : messages.errorSystem;

  @override
  String toString() {
    if (message?.isNotEmpty == true) return message!;
    if (originalError != null) return originalError.toString();
    return runtimeType.toString();
  }
}

// ---------------------------------------------------------------------------
// Common subclasses — dùng trong AppExceptionHandler và BaseRemoteDatasource
// ---------------------------------------------------------------------------

class ConnectionException extends AppException {
  const ConnectionException({super.message, super.originalError});
  @override
  String resolve(IAppMessages messages) =>
      (message?.isNotEmpty == true) ? message! : messages.errorConnection;
}

class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException({super.message, super.originalError});
  @override
  String resolve(IAppMessages messages) =>
      (message?.isNotEmpty == true) ? message! : messages.errorNetworkTimeout;
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message, super.originalError});
  @override
  String resolve(IAppMessages messages) =>
      (message?.isNotEmpty == true) ? message! : messages.errorForbidden;
}

class NotFoundException extends AppException {
  const NotFoundException({super.message, super.originalError});
  @override
  String resolve(IAppMessages messages) =>
      (message?.isNotEmpty == true) ? message! : messages.errorNotFound;
}

class ServerException extends AppException {
  const ServerException({super.message, super.originalError});
  @override
  String resolve(IAppMessages messages) =>
      (message?.isNotEmpty == true) ? message! : messages.errorServer;
}

class InvalidResponseException extends AppException {
  const InvalidResponseException({super.originalError});
  @override
  String resolve(IAppMessages messages) => messages.errorInvalidResponse;
}
