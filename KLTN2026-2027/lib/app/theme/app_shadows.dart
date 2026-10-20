import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens for elevation and box shadows across KLTN2026-2027.
class AppShadows {
  AppShadows._();

  // ---------------------------------------------------------------------------
  // 1. NEUTRAL ELEVATION LEVELS
  // ---------------------------------------------------------------------------
  static const List<BoxShadow> none = [];

  /// Subtle elevation for cards, list tiles, and secondary buttons.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x080F172A),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Standard elevation for cards, selected items, and floating elements.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F0F172A),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// High elevation for popovers, dropdown menus, and bottom sheets.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x140F172A),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  /// Maximum elevation for modal dialogs and alert dialogs.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F0F172A),
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: -6,
    ),
  ];

  /// Top shadow for bottom navigation bars and sticky CTA bottom containers.
  static const List<BoxShadow> bottomBar = [
    BoxShadow(
      color: Color(0x080F172A),
      offset: Offset(0, -4),
      blurRadius: 16,
    ),
  ];

  // ---------------------------------------------------------------------------
  // 2. COLORED BRAND GLOWS
  // ---------------------------------------------------------------------------
  /// Soft emerald brand glow for primary CTA buttons.
  static List<BoxShadow> primaryGlow([Color? color]) {
    final c = color ?? AppColors.primary;
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.35),
        offset: const Offset(0, 6),
        blurRadius: 16,
        spreadRadius: -2,
      ),
    ];
  }

  /// Dynamic colored shadow builder for status badges and tags.
  static List<BoxShadow> colored(
    Color color, {
    double opacity = 0.25,
    double blur = 12,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: offset,
        blurRadius: blur,
      ),
    ];
  }
}
