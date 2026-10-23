import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens for typography across the KLTN2026-2027 application.
/// Strictly follows standard typographic scales with carefully calibrated
/// font sizes, line heights, font weights, and letter spacings.
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // 1. DISPLAY (Hero sections, large numbers, match score highlights)
  // ---------------------------------------------------------------------------
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ---------------------------------------------------------------------------
  // 2. HEADLINE (Screen headers, section banners, large modal titles)
  // ---------------------------------------------------------------------------
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // ---------------------------------------------------------------------------
  // 3. TITLE (App bars, card headers, list item titles, dialog headers)
  // ---------------------------------------------------------------------------
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // 4. BODY (Reading text, descriptions, details, list subtitles)
  // ---------------------------------------------------------------------------
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ---------------------------------------------------------------------------
  // 5. LABEL (Buttons, chips, badges, tags, form field labels, captions)
  // ---------------------------------------------------------------------------
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // ---------------------------------------------------------------------------
  // 6. FUNCTIONAL ALIASES
  // ---------------------------------------------------------------------------
  static const TextStyle button = labelLarge;
  static const TextStyle caption = bodySmall;

  // ---------------------------------------------------------------------------
  // 7. MATERIAL 3 TEXT THEME CONVERSION & THEME-AWARE TYPOGRAPHY
  // ---------------------------------------------------------------------------
  /// Generates a complete Material 3 TextTheme instance.
  static TextTheme toTextTheme({
    Color? defaultColor,
    Color? secondaryColor,
    Color? mutedColor,
  }) {
    final c = defaultColor ?? AppColors.textPrimary;
    final sec = secondaryColor ?? defaultColor ?? AppColors.textSecondary;
    final mut = mutedColor ?? defaultColor ?? AppColors.textMuted;
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: c),
      displayMedium: displayMedium.copyWith(color: c),
      displaySmall: displaySmall.copyWith(color: c),
      headlineLarge: headlineLarge.copyWith(color: c),
      headlineMedium: headlineMedium.copyWith(color: c),
      headlineSmall: headlineSmall.copyWith(color: c),
      titleLarge: titleLarge.copyWith(color: c),
      titleMedium: titleMedium.copyWith(color: c),
      titleSmall: titleSmall.copyWith(color: c),
      bodyLarge: bodyLarge.copyWith(color: c),
      bodyMedium: bodyMedium.copyWith(color: sec),
      bodySmall: bodySmall.copyWith(color: mut),
      labelLarge: labelLarge.copyWith(color: c),
      labelMedium: labelMedium.copyWith(color: sec),
      labelSmall: labelSmall.copyWith(color: mut),
    );
  }

  /// Shortcut to access theme-adaptive TextTheme via current BuildContext.
  static TextTheme of(BuildContext context) => Theme.of(context).textTheme;
}

/// Fluent chaining extensions on TextStyle for fast & clean styling in UI widgets.
extension AppTextStyleExtension on TextStyle {
  /// Replace color fluently
  TextStyle colored(Color color) => copyWith(color: color);

  /// Change opacity fluently
  TextStyle withOpacity(double opacity) =>
      copyWith(color: (color ?? AppColors.textPrimary).withValues(alpha: opacity));

  /// Change font size fluently
  TextStyle withSize(double size) => copyWith(fontSize: size);

  /// Change line height fluently
  TextStyle withHeight(double height) => copyWith(height: height);

  /// FontWeight helpers
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Decoration helpers
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);
}
