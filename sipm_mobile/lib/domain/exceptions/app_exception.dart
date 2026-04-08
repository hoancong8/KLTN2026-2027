import '../../app/l10n_gen/app_localizations.dart';

/// Lớp ngoại lệ cơ sở cho toàn bộ ứng dụng.
/// Kết hợp giữa thông báo từ Server (message) và logic đa ngôn ngữ (l10nSelector).
class AppException implements Exception {
  final String? message;
  final String? Function(AppLocalizations)? l10nSelector;
  final dynamic originalError;

  AppException({
    this.message,
    this.l10nSelector,
    this.originalError,
  });

  /// Trả về thông báo lỗi đã được dịch hoặc từ server.
  String getDisplayMessage(AppLocalizations l10n) {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    return l10nSelector?.call(l10n) ?? l10n.error_system;
  }

  @override
  String toString() => message ?? 'AppException';
}
