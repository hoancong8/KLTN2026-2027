import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';

class AppSnack {
  static OverlayEntry? currentEntry;
  static AnimationController? currentController;

  static void showBase(
    BuildContext context,
    String message, {
    required Color background,
    required IconData icon,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 2),
  }) {
    dismissImmediate();

    final overlay = Overlay.of(context);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: overlay,
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    currentController = controller;

    final entry = OverlayEntry(
      builder: (ctx) {
        return GlassSnackBarWidget(
          message: message,
          background: background,
          icon: icon,
          iconColor: iconColor,
          textColor: textColor,
          slideAnimation: slideAnimation,
          fadeAnimation: fadeAnimation,
        );
      },
    );

    currentEntry = entry;
    overlay.insert(entry);
    controller.forward();

    Future.delayed(duration, () {
      if (currentEntry == entry && currentController == controller) {
        dismissWithAnimation(entry, controller);
      }
    });
  }

  static void dismissImmediate() {
    try {
      currentEntry?.remove();
    } catch (e) {
      AppLog.warning(e);
    }
    currentEntry = null;
    try {
      currentController?.dispose();
    } catch (e) {
      AppLog.warning(e);
    }
    currentController = null;
  }

  static void dismissWithAnimation(
    OverlayEntry entry,
    AnimationController controller,
  ) {
    controller.reverse().then((_) {
      try {
        entry.remove();
      } catch (e) {
        AppLog.warning(e);
      }
      try {
        controller.dispose();
      } catch (e) {
        AppLog.warning(e);
      }
      if (currentEntry == entry) {
        currentEntry = null;
      }
      if (currentController == controller) {
        currentController = null;
      }
    });
  }

  static void success(BuildContext context, String message) {
    showBase(
      context,
      message,
      background: AppColor.cMain,
      icon: Icons.check_circle_outline,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }

  static void error(BuildContext context, String message) {
    showBase(
      context,
      message,
      background: AppColor.cError,
      icon: Icons.error_outline,
      iconColor: Colors.white,
      textColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void warning(BuildContext context, String message) {
    showBase(
      context,
      message,
      background: const Color(0xFF1A1A1A),
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.amberAccent,
      textColor: Colors.white,
    );
  }

  static void info(BuildContext context, String message) {
    showBase(
      context,
      message,
      background: const Color(0xFF1E3A5F),
      icon: Icons.info_outline,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }
}

class GlassSnackBarWidget extends StatelessWidget {
  final String message;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const GlassSnackBarWidget({
    super.key,
    required this.message,
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: background.withAlpha(200),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha(45),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha(45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 20, color: iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
