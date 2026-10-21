import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

/// A loading overlay widget that displays a centered loading indicator
/// with a theme-adaptive card background. Can be used as a Stack child overlay.
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? barrierColor;
  final Color? indicatorColor;
  final Color? cardColor;
  final Color? textColor;
  final double cardPadding;
  final double cardBorderRadius;
  final double indicatorSize;
  final double strokeWidth;
  final bool isDefaultProcessing;

  const LoadingOverlay({
    super.key,
    this.message,
    this.barrierColor,
    this.indicatorColor,
    this.cardColor,
    this.textColor,
    this.cardPadding = AppSpacing.xl,
    this.cardBorderRadius = AppRadius.lg,
    this.indicatorSize = 36,
    this.strokeWidth = 3,
    this.isDefaultProcessing = false,
  });

  /// Default constructor with "Đang xử lý..." message
  const LoadingOverlay.processing({
    super.key,
    this.barrierColor,
    this.indicatorColor,
    this.cardColor,
    this.textColor,
    this.cardPadding = AppSpacing.xl,
    this.cardBorderRadius = AppRadius.lg,
    this.indicatorSize = 36,
    this.strokeWidth = 3,
  })  : message = null,
        isDefaultProcessing = true;

  @override
  Widget build(BuildContext context) {
    String? displayMessage = message;
    if (isDefaultProcessing) {
      displayMessage = context.l10n.com_processing;
    }

    final colors = context.colors;
    final resolvedBarrier = barrierColor ?? AppColors.overlaySubtle;
    final resolvedCard = cardColor ?? colors.cardBackground;
    final resolvedText = textColor ?? colors.textPrimary;
    final resolvedIndicator = indicatorColor ?? colors.primary;

    return Container(
      color: resolvedBarrier,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: resolvedCard,
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(color: colors.cardBorder),
            boxShadow: context.isDark ? AppShadows.none : AppShadows.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(resolvedIndicator),
                ),
              ),
              if (displayMessage != null) ...[
                AppSpacing.gapH16,
                Text(
                  displayMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: resolvedText,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
