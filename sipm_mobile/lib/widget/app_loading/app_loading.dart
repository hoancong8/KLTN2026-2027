import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;
}

class AppLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final String? message;
  final Color textColor;
  final bool showBackground;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const AppLoading({
    super.key,
    this.size = 28,
    this.strokeWidth = 3,
    this.color = AppColor.cMain,
    this.message,
    this.textColor = Colors.white,
    this.showBackground = true,
    this.backgroundColor = const Color(0xCC000000),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );

    if (!showBackground && message == null) {
      return indicator;
    }

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        if (message != null) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message!,
              style: TextStyle(color: textColor, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    if (!showBackground) {
      return row;
    }

    return Center(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}

class AppLoadingOverlay {
  static OverlayEntry? overlayEntry;
  static bool isShowing = false;

  static void show({
    String? message,
    bool barrierDismissible = false,
    Color? barrierColor,
    double blurBackground = 0,
    Color indicatorColor = AppColor.cMain,
  }) {
    if (isShowing) return;

    final context = AppNavigator.context;
    if (context == null) return;

    final overlayState = Overlay.of(context, rootOverlay: true);

    overlayEntry = OverlayEntry(
      builder: (_) {
        Widget content = Stack(
          children: [
            ModalBarrier(
              color: barrierColor ?? Colors.black.withAlpha(268),
              dismissible: barrierDismissible,
            ),
            AppLoading(
              message: message,
              color: indicatorColor,
              showBackground: true,
            ),
          ],
        );

        if (blurBackground > 0) {
          content = BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurBackground,
              sigmaY: blurBackground,
            ),
            child: content,
          );
        }

        return content;
      },
    );

    overlayState.insert(overlayEntry!);
    isShowing = true;
  }

  static void hide() {
    if (!isShowing) return;

    try {
      overlayEntry?.remove();
    } catch (_) {
    } finally {
      overlayEntry = null;
      isShowing = false;
    }
  }
}
