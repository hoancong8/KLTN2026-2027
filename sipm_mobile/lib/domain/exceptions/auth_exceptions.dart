import 'app_exception.dart';

class RequiresTwoFactorException extends AppException {
  RequiresTwoFactorException() : super(l10nSelector: (l) => l.otpVerification);
}

class SessionExpiredException extends AppException {
  SessionExpiredException() : super(l10nSelector: (l) => l.error_session_expired);
}

class AuthFailedException extends AppException {
  AuthFailedException([String? message]) : super(message: message);
}

class ChangePasswordFailedException extends AppException {
  ChangePasswordFailedException([String? message]) 
      : super(message: message ?? 'Đổi mật khẩu không thành công!');
}
