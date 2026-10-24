import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme/theme.dart';

/// Standard 2-step confirmation dialog with tactile haptic feedback.
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
    this.isDestructive = false,
  });

  /// Displays the confirmation dialog and triggers haptic feedback on affirmative action.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionColor = isDestructive ? colors.error : colors.primary;

    return AlertDialog(
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      title: Text(
        title,
        style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium.colored(colors.textSecondary),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: colors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(cancelText, style: AppTypography.labelLarge.colored(colors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: Text(confirmText, style: AppTypography.labelLarge.bold.colored(AppColors.white)),
        ),
      ],
    );
  }
}
