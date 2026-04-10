import '../../domain/exceptions/app_exception.dart';
import '../l10n/flutter_app_messages.dart';
import '../l10n_gen/app_localizations.dart';

/// Extension cung cấp cú pháp thân thiện cho UI.
/// Giữ tên [getDisplayMessage] để tương thích với toàn bộ codebase hiện tại.
extension AppExceptionDisplayExt on AppException {
  /// Trả về thông báo lỗi đã được dịch theo ngôn ngữ hiện tại.
  ///
  /// Dùng với [AppLocalizations]:
  /// ```dart
  /// error.getDisplayMessage(context.l10n)
  /// error.getDisplayMessage(ref.l10n)
  /// ```
  String getDisplayMessage(AppLocalizations l10n) =>
      resolve(FlutterAppMessages(l10n));
}
