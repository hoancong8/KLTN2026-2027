import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

export '../theme/app_radius.dart';
export '../theme/app_spacing.dart';

/// Legacy dimensions utility class enhanced with modern design tokens.
class AppDimens {
  AppDimens._();

  // ---------------------------------------------------------------------------
  // 1. LEGACY SCREEN HELPERS & BREAKPOINTS
  // ---------------------------------------------------------------------------
  static const double appBarHeight = AppSpacing.appBarHeight;
  static const double tabletBreakpoint = AppSpacing.tabletBreakpoint;

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  static Widget kHeightBottom(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: SizedBox(
        height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 12,
      ),
    );
  }

  static bool isMobileScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  // ---------------------------------------------------------------------------
  // 2. DESIGN TOKEN SHORTCUTS (SPACING & GAPS)
  // ---------------------------------------------------------------------------
  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double base = AppSpacing.base;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double xxl = AppSpacing.xxl;

  static const SizedBox gapW4 = AppSpacing.gapW4;
  static const SizedBox gapW8 = AppSpacing.gapW8;
  static const SizedBox gapW12 = AppSpacing.gapW12;
  static const SizedBox gapW16 = AppSpacing.gapW16;
  static const SizedBox gapW20 = AppSpacing.gapW20;
  static const SizedBox gapW24 = AppSpacing.gapW24;
  static const SizedBox gapW32 = AppSpacing.gapW32;

  static const SizedBox gapH4 = AppSpacing.gapH4;
  static const SizedBox gapH8 = AppSpacing.gapH8;
  static const SizedBox gapH12 = AppSpacing.gapH12;
  static const SizedBox gapH16 = AppSpacing.gapH16;
  static const SizedBox gapH20 = AppSpacing.gapH20;
  static const SizedBox gapH24 = AppSpacing.gapH24;
  static const SizedBox gapH32 = AppSpacing.gapH32;
  static const SizedBox gapH40 = AppSpacing.gapH40;
  static const SizedBox gapH48 = AppSpacing.gapH48;
  static const SizedBox gapH64 = AppSpacing.gapH64;

  // ---------------------------------------------------------------------------
  // 3. RADIUS SHORTCUTS
  // ---------------------------------------------------------------------------
  static const BorderRadius radiusSm = AppRadius.borderSm;
  static const BorderRadius radiusMd = AppRadius.borderMd;
  static const BorderRadius radiusLg = AppRadius.borderLg;
  static const BorderRadius radiusXl = AppRadius.borderXl;
  static const BorderRadius radiusFull = AppRadius.borderFull;
}
