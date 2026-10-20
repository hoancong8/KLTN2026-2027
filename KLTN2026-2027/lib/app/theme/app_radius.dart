import 'package:flutter/material.dart';

/// Design tokens for corner radii and border shapes across KLTN2026-2027.
class AppRadius {
  AppRadius._();

  // ---------------------------------------------------------------------------
  // 1. RAW NUMERICAL VALUES
  // ---------------------------------------------------------------------------
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  // ---------------------------------------------------------------------------
  // 2. RADIUS INSTANCES
  // ---------------------------------------------------------------------------
  static const Radius circularNone = Radius.zero;
  static const Radius circularXs = Radius.circular(xs);
  static const Radius circularSm = Radius.circular(sm);
  static const Radius circularMd = Radius.circular(md);
  static const Radius circularLg = Radius.circular(lg);
  static const Radius circularXl = Radius.circular(xl);
  static const Radius circularXxl = Radius.circular(xxl);
  static const Radius circularFull = Radius.circular(full);

  // ---------------------------------------------------------------------------
  // 3. BORDER RADIUS (ALL SIDES)
  // ---------------------------------------------------------------------------
  static const BorderRadius borderNone = BorderRadius.zero;
  static const BorderRadius borderXs = BorderRadius.all(circularXs);
  static const BorderRadius borderSm = BorderRadius.all(circularSm);
  static const BorderRadius borderMd = BorderRadius.all(circularMd);
  static const BorderRadius borderLg = BorderRadius.all(circularLg);
  static const BorderRadius borderXl = BorderRadius.all(circularXl);
  static const BorderRadius borderXxl = BorderRadius.all(circularXxl);
  static const BorderRadius borderFull = BorderRadius.all(circularFull);

  // ---------------------------------------------------------------------------
  // 4. SEMANTIC COMPONENT SHAPES
  // ---------------------------------------------------------------------------
  static const BorderRadius card = borderLg;
  static const BorderRadius dialog = BorderRadius.all(circularXl);
  static const BorderRadius bottomSheet = BorderRadius.vertical(top: circularXxl);
  static const BorderRadius button = borderMd;
  static const BorderRadius buttonPill = borderFull;
  static const BorderRadius input = borderMd;
  static const BorderRadius chip = borderSm;
  static const BorderRadius tag = BorderRadius.all(Radius.circular(6));
  static const BorderRadius badge = borderFull;

  // ---------------------------------------------------------------------------
  // 5. DIRECTIONAL SHAPE GENERATORS
  // ---------------------------------------------------------------------------
  static BorderRadius top(double r) => BorderRadius.vertical(top: Radius.circular(r));
  static BorderRadius bottom(double r) => BorderRadius.vertical(bottom: Radius.circular(r));
  static BorderRadius left(double r) => BorderRadius.horizontal(left: Radius.circular(r));
  static BorderRadius right(double r) => BorderRadius.horizontal(right: Radius.circular(r));
}
