import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_log.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

import 'app_button.dart';

enum AppButtonType { primary, secondary, outlined, text, danger }

enum AppButtonSize { small, medium, large }

class AppButtonCommon extends StatefulWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final bool enabled;
  final bool? isLoading;
  final Duration autoLoadingDuration;
  final AppButtonType type;
  final AppButtonSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppButtonCommon({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.isLoading,
    this.autoLoadingDuration = const Duration(milliseconds: 500),
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.large,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  State<AppButtonCommon> createState() => AppButtonCommonState();
}

class AppButtonCommonState extends State<AppButtonCommon> {
  bool internalLoading = false;

  Future<void> handlePress() async {
    if (widget.onPressed == null) return;
    if (isLoadingState) return;

    try {
      if (widget.isLoading == null) {
        setState(() {
          internalLoading = true;
        });
      }

      await Future.wait([
        widget.onPressed!(),
        Future.delayed(widget.autoLoadingDuration),
      ]);
    } catch (e) {
      AppLog.warning(e);
    } finally {
      if (widget.isLoading == null && mounted) {
        setState(() {
          internalLoading = false;
        });
      }
    }
  }

  bool get isLoadingState {
    if (widget.isLoading != null) {
      return widget.isLoading!;
    }
    return internalLoading;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.onPressed == null;

    return AppButton(
      onTap: (isDisabled || isLoadingState) ? null : handlePress,
      child: Container(
        width: widget.width ?? double.infinity,
        height: getHeight(),
        padding: widget.padding ?? getPadding(),
        decoration: BoxDecoration(
          color: getBackgroundColor(isDisabled),
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? getBorderRadius(),
          ),
          border: getBorder(isDisabled),
          boxShadow: widget.elevation != null && !isDisabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: widget.elevation!,
                    offset: Offset(0, widget.elevation! / 2),
                  ),
                ]
              : widget.type == AppButtonType.primary && !isDisabled
              ? AppShadows.primaryGlow(getBackgroundColor(false))
              : null,
        ),
        child: isLoadingState
            ? Center(
                child: SizedBox(
                  width: getLoadingSize(),
                  height: getLoadingSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getLoadingColor(isDisabled),
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    SizedBox(width: getIconSpacing()),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.fontSize ?? getFontSize(),
                        fontWeight: widget.fontWeight ?? FontWeight.w600,
                        color: getTextColor(isDisabled),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (widget.suffixIcon != null) ...[
                    SizedBox(width: getIconSpacing()),
                    widget.suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }

  /// Size configurations
  double getHeight() {
    return switch (widget.size) {
      AppButtonSize.small => AppSpacing.buttonHeightSm,
      AppButtonSize.medium => AppSpacing.buttonHeightMd,
      AppButtonSize.large => AppSpacing.buttonHeightLg,
    };
  }

  EdgeInsetsGeometry getPadding() {
    return switch (widget.size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.base,
      ),
    };
  }

  double getFontSize() {
    return switch (widget.size) {
      AppButtonSize.small => 13,
      AppButtonSize.medium => 14,
      AppButtonSize.large => 16,
    };
  }

  double getBorderRadius() {
    return switch (widget.size) {
      AppButtonSize.small => AppRadius.sm,
      AppButtonSize.medium => AppRadius.md,
      AppButtonSize.large => AppRadius.md,
    };
  }

  double getLoadingSize() {
    return switch (widget.size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 20,
      AppButtonSize.large => 24,
    };
  }

  double getIconSpacing() {
    return switch (widget.size) {
      AppButtonSize.small => 6,
      AppButtonSize.medium => 8,
      AppButtonSize.large => 10,
    };
  }

  /// Color configurations
  Color? getBackgroundColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.neutral200;
    }

    if (widget.backgroundColor != null) {
      return widget.backgroundColor;
    }

    return switch (widget.type) {
      AppButtonType.primary => AppColors.primary,
      AppButtonType.secondary => AppColors.secondary,
      AppButtonType.outlined || AppButtonType.text => Colors.transparent,
      AppButtonType.danger => AppColors.error,
    };
  }

  Color getTextColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.neutral500;
    }

    if (widget.textColor != null) {
      return widget.textColor!;
    }

    return switch (widget.type) {
      AppButtonType.primary ||
      AppButtonType.secondary ||
      AppButtonType.danger => AppColors.white,
      AppButtonType.outlined => widget.borderColor ?? AppColors.primary,
      AppButtonType.text => AppColors.primary,
    };
  }

  /// Loading color based on button type
  Color getLoadingColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.neutral500;
    }

    return switch (widget.type) {
      AppButtonType.primary ||
      AppButtonType.secondary ||
      AppButtonType.danger => AppColors.white,
      AppButtonType.outlined => widget.borderColor ?? AppColors.primary,
      AppButtonType.text => AppColors.primary,
    };
  }

  Border? getBorder(bool isDisabled) {
    if (widget.type == AppButtonType.outlined) {
      return Border.all(
        color: isDisabled
            ? AppColors.neutral300
            : (widget.borderColor ?? AppColors.primary),
        width: 1.5,
      );
    }
    return null;
  }
}
