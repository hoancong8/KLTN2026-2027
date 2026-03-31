class RequiresTwoFactorException implements Exception {}

class SessionExpiredException implements Exception {}

class AuthFailedException implements Exception {
  final String message;
  AuthFailedException(this.message);

  @override
  String toString() => message;
}

class ChangePasswordFailedException implements Exception {
  final String message;

  ChangePasswordFailedException([
    this.message = 'Đổi mật khẩu không thành công!',
  ]);

  @override
  String toString() => message;
}
