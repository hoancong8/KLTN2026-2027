import 'package:flutter/material.dart';

/// Design tokens for spacing, padding, margins, gaps, and dimensions across KLTN2026-2027.
class AppSpacing {
  AppSpacing._();

  // ---------------------------------------------------------------------------
  // 1. RAW NUMERICAL VALUES (8-POINT GRID WITH 4-POINT SUB-GRID)
  // ---------------------------------------------------------------------------
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double x4l = 48.0;
  static const double x5l = 64.0;

  // ---------------------------------------------------------------------------
  // 2. EDGE INSETS (ALL SIDES)
  // ---------------------------------------------------------------------------
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allBase = EdgeInsets.all(base);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  // ---------------------------------------------------------------------------
  // 3. EDGE INSETS (HORIZONTAL & VERTICAL)
  // ---------------------------------------------------------------------------
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalBase = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalBase = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);

  // ---------------------------------------------------------------------------
  // 4. SCREEN & COMPONENT PADDINGS
  // ---------------------------------------------------------------------------
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: base, vertical: base);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets screenVertical = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets card = EdgeInsets.all(base);
  static const EdgeInsets dialog = EdgeInsets.all(xl);
  static const EdgeInsets bottomSheet = EdgeInsets.fromLTRB(lg, md, lg, xl);

  // ---------------------------------------------------------------------------
  // 5. REUSABLE GAP SIZEDBOXES (HORIZONTAL WIDTH)
  // ---------------------------------------------------------------------------
  static const SizedBox gapW4 = SizedBox(width: xs);
  static const SizedBox gapW8 = SizedBox(width: sm);
  static const SizedBox gapW12 = SizedBox(width: md);
  static const SizedBox gapW16 = SizedBox(width: base);
  static const SizedBox gapW20 = SizedBox(width: lg);
  static const SizedBox gapW24 = SizedBox(width: xl);
  static const SizedBox gapW32 = SizedBox(width: xxl);

  // ---------------------------------------------------------------------------
  // 6. REUSABLE GAP SIZEDBOXES (VERTICAL HEIGHT)
  // ---------------------------------------------------------------------------
  static const SizedBox gapH4 = SizedBox(height: xs);
  static const SizedBox gapH8 = SizedBox(height: sm);
  static const SizedBox gapH12 = SizedBox(height: md);
  static const SizedBox gapH16 = SizedBox(height: base);
  static const SizedBox gapH20 = SizedBox(height: lg);
  static const SizedBox gapH24 = SizedBox(height: xl);
  static const SizedBox gapH32 = SizedBox(height: xxl);
  static const SizedBox gapH40 = SizedBox(height: xxxl);
  static const SizedBox gapH48 = SizedBox(height: x4l);
  static const SizedBox gapH64 = SizedBox(height: x5l);

  // ---------------------------------------------------------------------------
  // 7. ICON SIZES
  // ---------------------------------------------------------------------------
  static const double iconXs = 14.0;
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;

  // ---------------------------------------------------------------------------
  // 8. COMPONENT SIZES
  // ---------------------------------------------------------------------------
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  static const double inputHeight = 48.0;
  static const double inputHeightDense = 40.0;

  static const double avatarSm = 32.0;
  static const double avatarMd = 44.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  static const double appBarHeight = 56.0;
  static const double bottomBarHeight = 64.0;
  static const double tabletBreakpoint = 600.0;
}
