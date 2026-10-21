import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/consts/app_dimens.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

/// Helper to calculate relative luminance according to W3C WCAG 2.1 specs.
double _calculateLuminance(Color color) {
  double channel(double value) {
    return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Helper to calculate contrast ratio according to W3C WCAG 2.1.
double _contrastRatio(Color c1, Color c2) {
  final l1 = _calculateLuminance(c1);
  final l2 = _calculateLuminance(c2);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Design Tokens - AppColors & AppColor Tests', () {
    test('Primary and brand colors are properly defined', () {
      expect(AppColors.primary, equals(const Color(0xFF3CC18E)));
      expect(AppColors.primaryDark, equals(const Color(0xFF2EA578)));
      expect(AppColors.primaryContainer, equals(const Color(0xFFE8F9F3)));
      expect(AppColors.secondary, equals(const Color(0xFF0EA5E9)));
      expect(AppColors.accent, equals(const Color(0xFFFFA61E)));
      expect(AppColors.transparent, equals(const Color(0x00000000)));
    });

    test('Semantic colors are properly defined', () {
      expect(AppColors.success, equals(const Color(0xFF10B981)));
      expect(AppColors.warning, equals(const Color(0xFFF59E0B)));
      expect(AppColors.error, equals(const Color(0xFFEF4444)));
      expect(AppColors.info, equals(const Color(0xFF3B82F6)));
    });

    test('Legacy AppColor constants remain fully backward compatible', () {
      expect(AppColor.cMain, equals(const Color(0xFF3CC18E)));
      expect(AppColor.white, equals(const Color(0xFFFFFFFF)));
      expect(AppColor.cMuted, equals(const Color(0xFF8C8C8C)));
      expect(AppColor.cTitle, equals(const Color(0xFF263238)));
      expect(AppColor.cDark, equals(const Color(0xFF0F172A)));
      expect(AppColor.cDivider, equals(const Color(0xFFEAEAEA)));
      expect(AppColor.cError, equals(const Color(0xFFCC1B1B)));
      expect(AppColor.cRed, equals(AppColor.cError));
      expect(AppColor.color1, isA<Color>());
      expect(AppColor.color46, isA<Color>());
    });

    test('Gradients are defined and usable', () {
      expect(AppColors.primaryGradient.colors.length, equals(2));
      expect(AppColors.heroGradient.colors.length, equals(2));
      expect(AppColors.cardGradient.colors.length, equals(2));
    });
  });

  group('Design Tokens - AppThemeColors (Adaptive Light & Dark) Tests', () {
    test('Light palette tokens are defined and cohesive', () {
      const light = AppThemeColors.light;
      expect(light.brightness, equals(Brightness.light));
      expect(light.primary, equals(AppColors.primary));
      expect(light.surface, equals(const Color(0xFFFFFFFF)));
      expect(light.cardBackground, equals(const Color(0xFFFFFFFF)));
      expect(light.background, equals(const Color(0xFFF8FAFC)));
      expect(light.textPrimary, equals(const Color(0xFF0F172A)));
    });

    test('Dark palette tokens are defined and cohesive', () {
      const dark = AppThemeColors.dark;
      expect(dark.brightness, equals(Brightness.dark));
      expect(dark.primary, equals(AppColors.primary));
      expect(dark.surface, equals(const Color(0xFF162032)));
      expect(dark.cardBackground, equals(const Color(0xFF162032)));
      expect(dark.background, equals(const Color(0xFF0B1220)));
      expect(dark.textPrimary, equals(const Color(0xFFF8FAFC)));
    });

    test('Light theme contrast ratios satisfy WCAG AA (>= 4.5:1)', () {
      const light = AppThemeColors.light;
      final textPrimaryRatio = _contrastRatio(light.textPrimary, light.surface);
      final textSecondaryRatio = _contrastRatio(light.textSecondary, light.surface);

      expect(textPrimaryRatio, greaterThanOrEqualTo(4.5), reason: 'Light textPrimary must be high contrast');
      expect(textSecondaryRatio, greaterThanOrEqualTo(4.5), reason: 'Light textSecondary must satisfy WCAG AA');
    });

    test('Dark theme contrast ratios satisfy WCAG AA (>= 4.5:1)', () {
      const dark = AppThemeColors.dark;
      final textPrimaryRatio = _contrastRatio(dark.textPrimary, dark.cardBackground);
      final textSecondaryRatio = _contrastRatio(dark.textSecondary, dark.cardBackground);

      expect(textPrimaryRatio, greaterThanOrEqualTo(4.5), reason: 'Dark textPrimary must be high contrast');
      expect(textSecondaryRatio, greaterThanOrEqualTo(4.5), reason: 'Dark textSecondary must satisfy WCAG AA');
    });

    test('ThemeExtension copyWith and lerp functions properly', () {
      const base = AppThemeColors.light;
      final modified = base.copyWith(primary: Colors.purple);
      expect(modified.primary, equals(Colors.purple));
      expect(modified.surface, equals(base.surface));

      final lerped = base.lerp(AppThemeColors.dark, 0.5);
      expect(lerped.brightness, equals(Brightness.dark));
      expect(lerped.background, isNot(equals(base.background)));
    });
  });

  group('Design Tokens - AppTypography Tests', () {
    test('Font sizes follow hierarchy', () {
      expect(AppTypography.displayLarge.fontSize, greaterThan(AppTypography.headlineLarge.fontSize!));
      expect(AppTypography.headlineLarge.fontSize, greaterThan(AppTypography.titleLarge.fontSize!));
      expect(AppTypography.titleLarge.fontSize, greaterThan(AppTypography.bodyLarge.fontSize!));
      expect(AppTypography.bodyLarge.fontSize, greaterThan(AppTypography.bodySmall.fontSize!));
    });

    test('Material 3 TextTheme generation operates properly', () {
      final textTheme = AppTypography.toTextTheme();
      expect(textTheme.displayLarge?.fontSize, equals(32));
      expect(textTheme.headlineLarge?.fontSize, equals(22));
      expect(textTheme.titleLarge?.fontSize, equals(18));
      expect(textTheme.bodyLarge?.fontSize, equals(16));
    });

    test('AppTextStyleExtension fluent chaining works', () {
      final base = AppTypography.bodyMedium;
      final styled = base.colored(Colors.red).bold.underlined;
      expect(styled.color, equals(Colors.red));
      expect(styled.fontWeight, equals(FontWeight.w700));
      expect(styled.decoration, equals(TextDecoration.underline));
    });
  });

  group('Design Tokens - AppSpacing & AppDimens Tests', () {
    test('Numerical spacing scales properly', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(12.0));
      expect(AppSpacing.base, equals(16.0));
      expect(AppSpacing.lg, equals(20.0));
      expect(AppSpacing.xl, equals(24.0));
      expect(AppSpacing.xxl, equals(32.0));
    });

    test('Gap SizedBoxes have correct dimensions', () {
      expect(AppSpacing.gapH8.height, equals(8.0));
      expect(AppSpacing.gapW16.width, equals(16.0));
    });

    test('Legacy AppDimens maintains breakpoints and helpers', () {
      expect(AppDimens.tabletBreakpoint, equals(600.0));
      expect(AppDimens.appBarHeight, equals(56.0));
      expect(AppDimens.gapH16, isA<SizedBox>());
      expect(AppDimens.radiusMd, equals(BorderRadius.circular(12)));
    });
  });

  group('Design Tokens - AppRadius & AppShadows Tests', () {
    test('Radius tokens generate proper BorderRadius', () {
      expect(AppRadius.borderSm, equals(BorderRadius.circular(8.0)));
      expect(AppRadius.borderMd, equals(BorderRadius.circular(12.0)));
      expect(AppRadius.borderLg, equals(BorderRadius.circular(16.0)));
      expect(AppRadius.bottomSheet, equals(const BorderRadius.vertical(top: Radius.circular(24.0))));
    });

    test('Shadow tokens have valid elevations and glows', () {
      expect(AppShadows.none, isEmpty);
      expect(AppShadows.sm, isNotEmpty);
      expect(AppShadows.md, isNotEmpty);
      expect(AppShadows.lg, isNotEmpty);
      expect(AppShadows.xl, isNotEmpty);
      expect(AppShadows.primaryGlow(), isNotEmpty);
    });
  });

  group('Design Tokens - AppTheme Integration Tests', () {
    test('Light theme satisfies Material 3 and brand specs', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
      expect(theme.appBarTheme.backgroundColor, equals(AppColors.surface));
      expect(theme.extension<AppThemeColors>(), isNotNull);
      expect(theme.extension<AppThemeColors>()?.brightness, equals(Brightness.light));
    });

    test('Dark theme satisfies Material 3 and dark slate specs', () {
      final theme = AppTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.surfaceDark));
      expect(theme.extension<AppThemeColors>(), isNotNull);
      expect(theme.extension<AppThemeColors>()?.brightness, equals(Brightness.dark));
    });
  });

  group('Localization - ARB Synchronization Tests', () {
    test('app_vi.arb and app_en.arb have exactly identical key sets', () {
      final viFile = File('lib/l10n/app_vi.arb');
      final enFile = File('lib/l10n/app_en.arb');

      expect(viFile.existsSync(), isTrue, reason: 'app_vi.arb must exist');
      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');

      final viJson = jsonDecode(viFile.readAsStringSync()) as Map<String, dynamic>;
      final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

      final viKeys = viJson.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();

      final missingInEn = viKeys.difference(enKeys);
      final missingInVi = enKeys.difference(viKeys);

      expect(missingInEn, isEmpty, reason: 'Keys in VI but missing in EN: $missingInEn');
      expect(missingInVi, isEmpty, reason: 'Keys in EN but missing in VI: $missingInVi');
      expect(viKeys.length, greaterThanOrEqualTo(250), reason: 'Must have comprehensive coverage');
    });
  });
}
