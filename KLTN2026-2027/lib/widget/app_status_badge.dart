import 'package:flutter/material.dart';
import '../app/theme/theme.dart';

enum AppBadgeVariant { primary, secondary, success, warning, error, info, neutral }

/// Reusable semantic status badge adhering to KLTN2026-2027 Design System tokens.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppBadgeVariant variant;
  final bool isBold;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.neutral,
    this.isBold = true,
  });

  const AppStatusBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.isBold = true,
  }) : variant = AppBadgeVariant.success;

  const AppStatusBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.isBold = true,
  }) : variant = AppBadgeVariant.warning;

  const AppStatusBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.isBold = true,
  }) : variant = AppBadgeVariant.error;

  const AppStatusBadge.info({
    super.key,
    required this.label,
    this.icon,
    this.isBold = true,
  }) : variant = AppBadgeVariant.info;

  const AppStatusBadge.primary({
    super.key,
    required this.label,
    this.icon,
    this.isBold = true,
  }) : variant = AppBadgeVariant.primary;

  const AppStatusBadge.neutral({
    super.key,
    required this.label,
    this.icon,
    this.isBold = true,
  }) : variant = AppBadgeVariant.neutral;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color badgeColor;
    switch (variant) {
      case AppBadgeVariant.primary:
        badgeColor = colors.primary;
        break;
      case AppBadgeVariant.secondary:
        badgeColor = colors.secondary;
        break;
      case AppBadgeVariant.success:
        badgeColor = colors.success;
        break;
      case AppBadgeVariant.warning:
        badgeColor = colors.warning;
        break;
      case AppBadgeVariant.error:
        badgeColor = colors.error;
        break;
      case AppBadgeVariant.info:
        badgeColor = colors.info;
        break;
      case AppBadgeVariant.neutral:
        badgeColor = colors.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: AppRadius.tag,
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: badgeColor),
            AppSpacing.gapW4,
          ],
          Text(
            label,
            style: isBold
                ? AppTypography.labelSmall.bold.colored(badgeColor)
                : AppTypography.labelSmall.colored(badgeColor),
          ),
        ],
      ),
    );
  }
}
