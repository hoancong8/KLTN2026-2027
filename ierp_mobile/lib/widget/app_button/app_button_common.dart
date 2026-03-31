import 'package:flutter/material.dart';

import 'app_button.dart';

enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

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
    Key? key,
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
  }) : super(key: key);

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
      print(e);
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
          borderRadius: BorderRadius.circular(widget.borderRadius ?? getBorderRadius()),
          border: getBorder(isDisabled),
          boxShadow: widget.elevation != null && !isDisabled
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: widget.elevation!,
              offset: Offset(0, widget.elevation! / 2),
            ),
          ]
              : widget.type == AppButtonType.primary && !isDisabled
              ? [
            BoxShadow(
              color: (getBackgroundColor(false) ?? Colors.blue).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
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
      AppButtonSize.small => 40,
      AppButtonSize.medium => 48,
      AppButtonSize.large => 56,
    };
  }

  EdgeInsetsGeometry getPadding() {
    return switch (widget.size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      AppButtonSize.small => 8,
      AppButtonSize.medium => 10,
      AppButtonSize.large => 12,
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
      return Colors.grey[300];
    }

    if (widget.backgroundColor != null) {
      return widget.backgroundColor;
    }

    return switch (widget.type) {
      AppButtonType.primary => const Color(0xFF4CAF50),
      AppButtonType.secondary => const Color(0xFF2196F3),
      AppButtonType.outlined || AppButtonType.text => Colors.transparent,
      AppButtonType.danger => const Color(0xFFF44336),
    };
  }

  Color getTextColor(bool isDisabled) {
    if (isDisabled) {
      return Colors.grey[600]!;
    }

    if (widget.textColor != null) {
      return widget.textColor!;
    }

    return switch (widget.type) {
      AppButtonType.primary || AppButtonType.secondary || AppButtonType.danger => Colors.white,
      AppButtonType.outlined => widget.borderColor ?? const Color(0xFF4CAF50),
      AppButtonType.text => const Color(0xFF4CAF50),
    };
  }

  /// Loading color dựa trên button type
  Color getLoadingColor(bool isDisabled) {
    if (isDisabled) {
      return Colors.grey[600]!;
    }

    return switch (widget.type) {
      AppButtonType.primary || AppButtonType.secondary || AppButtonType.danger => Colors.white,
      AppButtonType.outlined => widget.borderColor ?? const Color(0xFF4CAF50),
      AppButtonType.text => const Color(0xFF4CAF50),
    };
  }

  Border? getBorder(bool isDisabled) {
    if (widget.type == AppButtonType.outlined) {
      return Border.all(
        color: isDisabled ? Colors.grey[400]! : (widget.borderColor ?? const Color(0xFF4CAF50)),
        width: 1,
      );
    }
    return null;
  }
}