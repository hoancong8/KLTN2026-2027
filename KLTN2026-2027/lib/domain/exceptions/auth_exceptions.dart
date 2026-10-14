import 'app_exception.dart';
import 'i_app_messages.dart';

class SessionExpiredException extends AppException {
  const SessionExpiredException();
  @override
  String resolve(IAppMessages messages) => messages.errorSessionExpired;
}

class AuthFailedException extends AppException {
  const AuthFailedException([String? message]) : super(message: message);
}

class ChangePasswordFailedException extends AppException {
  const ChangePasswordFailedException([String? message]) : super(message: message);
}
