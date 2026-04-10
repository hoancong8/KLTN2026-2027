import '../l10n_gen/app_localizations.dart';
import '../../domain/exceptions/i_app_messages.dart';

/// Concrete implementation của [IAppMessages] dùng Flutter's [AppLocalizations].
/// Đây là nơi DUY NHẤT trong toàn bộ exception system biết về Flutter framework.
class FlutterAppMessages implements IAppMessages {
  final AppLocalizations _l;

  const FlutterAppMessages(this._l);

  // --- Lỗi chung ---
  @override
  String get errorSystem => _l.error_system;

  @override
  String get errorConnection => _l.error_connection;

  @override
  String get errorNetworkTimeout => _l.error_network_timeout;

  @override
  String get errorForbidden => _l.error_forbidden;

  @override
  String get errorNotFound => _l.error_not_found;

  @override
  String get errorServer => _l.error_server;

  @override
  String get errorInvalidResponse => _l.error_invalid_response;

  // --- Auth ---
  @override
  String get errorSessionExpired => _l.error_session_expired;

  @override
  String get otpVerification => _l.otpVerification;
}
