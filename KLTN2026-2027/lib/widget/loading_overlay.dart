import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';

/// A loading overlay widget that displays a centered loading indicator
/// with a white card background. Can be used as a Stack child overlay.
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color barrierColor;
  final Color indicatorColor;
  final Color cardColor;
  final Color textColor;
  final double cardPadding;
  final double cardBorderRadius;
  final double indicatorSize;
  final double strokeWidth;
  final bool isDefaultProcessing;

  const LoadingOverlay({
    super.key,
    this.message,
    this.barrierColor = const Color(0x1A000000), // 10% black
    this.indicatorColor = AppColor.cMain,
    this.cardColor = AppColor.white,
    this.textColor = AppColor.cTitle,
    this.cardPadding = 24,
    this.cardBorderRadius = 16,
    this.indicatorSize = 36,
    this.strokeWidth = 3,
    this.isDefaultProcessing = false,
  });

  /// Default constructor with "Đang xử lý..." message
  const LoadingOverlay.processing({
    super.key,
    this.barrierColor = const Color(0x1A000000),
    this.indicatorColor = AppColor.cMain,
    this.cardColor = AppColor.white,
    this.textColor = AppColor.cTitle,
    this.cardPadding = 24,
    this.cardBorderRadius = 16,
    this.indicatorSize = 36,
    this.strokeWidth = 3,
  }) : message = null,
       isDefaultProcessing = true;

  @override
  Widget build(BuildContext context) {
    String? displayMessage = message;
    if (isDefaultProcessing) {
      displayMessage = context.l10n.com_processing;
    }
    return Container(
      color: barrierColor,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                ),
              ),
              if (displayMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  displayMessage,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    decoration: TextDecoration.none,
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
