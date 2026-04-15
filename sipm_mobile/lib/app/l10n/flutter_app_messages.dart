import '../l10n_gen/app_localizations.dart';
import '../../domain/exceptions/i_app_messages.dart';

/// Concrete implementation của [IAppMessages] dùng Flutter's [AppLocalizations].
/// Đây là nơi DUY NHẤT trong toàn bộ exception system biết về Flutter framework.
class FlutterAppMessages implements IAppMessages {
  final AppLocalizations _l;

  const FlutterAppMessages(this._l);

  // --- Lỗi chung ---
  @override
  String get errorSystem => _l.error_system_retry;

  @override
  String get errorConnection => _l.error_no_internet;

  @override
  String get errorNetworkTimeout => _l.error_network_timeout;

  @override
  String get errorForbidden => _l.error_forbidden_action;

  @override
  String get errorNotFound => _l.error_not_found;

  @override
  String get errorServer => _l.error_server_problem;

  @override
  String get errorInvalidResponse => _l.error_invalid_response;

  // --- Auth ---
  @override
  String get errorSessionExpired => _l.error_session_expired;

  @override
  String get otpVerification => _l.auth_verify_otp;

  @override
  String get authSessionExpiredMessage => _l.auth_session_expired_message;

  @override
  String get authSessionExpiredTitle => _l.auth_session_expired_title;

  @override
  String get authLoginAgain => _l.auth_login_again;

  @override
  String get errorSignalRNotConnected => _l.error_signalr_disconnected;

  // --- Biometric ---
  @override
  String get biometricReasonLogin => _l.auth_biometric_reason_login;

  @override
  String get biometricNotAvailable => _l.auth_biometric_error_not_available;

  @override
  String get biometricNotEnrolled => _l.auth_biometric_error_not_enrolled;

  @override
  String get biometricNotSetup => _l.auth_biometric_error_not_setup;

  @override
  String get biometricAuthFailed => _l.auth_biometric_error_not_available;

  @override
  String get biometricNoCredentials => _l.auth_biometric_error_no_credentials;

  @override
  String get biometricInvalidCredentials =>
      _l.auth_biometric_error_invalid_credentials;
}
