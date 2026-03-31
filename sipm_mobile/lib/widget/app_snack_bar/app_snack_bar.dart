import 'dart:ui';
import 'package:flutter/material.dart';

class AppSnackBar {
  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;

  static void showBase(
    BuildContext context,
    String message, {
    required Color background,
    required IconData icon,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 2),
  }) {
    _dismiss();

    final overlay = Overlay.of(context);
    late AnimationController controller;
    late Animation<Offset> slideAnimation;
    late Animation<double> fadeAnimation;

    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: overlay,
    );

    slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    _currentController = controller;

    _currentEntry = OverlayEntry(
      builder: (context) {
        return _GlassSnackBarWidget(
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

    overlay.insert(_currentEntry!);
    controller.forward();

    Future.delayed(duration, () {
      _dismissWithAnimation();
    });
  }

  static void _dismiss() {
    _currentController?.dispose();
    _currentController = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void _dismissWithAnimation() {
    if (_currentController != null && _currentEntry != null) {
      _currentController!.reverse().then((_) {
        _currentEntry?.remove();
        _currentEntry = null;
        _currentController?.dispose();
        _currentController = null;
      });
    }
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

  static void error(BuildContext context, String message) {
    showBase(
      context,
      message,
      background: const Color(0xFF7F1D1D),
      icon: Icons.error_outline,
      iconColor: Colors.white,
      textColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void success(BuildContext context, String message) {
    showBase(
      context,
      message,
      background: const Color(0xFF065F5B),
      icon: Icons.check_circle_outline,
      iconColor: Colors.white,
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

class _GlassSnackBarWidget extends StatelessWidget {
  final String message;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const _GlassSnackBarWidget({
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
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: background.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
                        color: iconColor.withOpacity(0.15),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
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
    );
  }
}
