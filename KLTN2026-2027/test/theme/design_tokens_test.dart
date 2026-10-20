import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/consts/app_dimens.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

void main() {
  group('Design Tokens - AppColors & AppColor Tests', () {
    test('Primary and brand colors are properly defined', () {
      expect(AppColors.primary, equals(const Color(0xFF3CC18E)));
      expect(AppColors.primaryDark, equals(const Color(0xFF2EA578)));
      expect(AppColors.primaryContainer, equals(const Color(0xFFE8F9F3)));
      expect(AppColors.secondary, equals(const Color(0xFF0EA5E9)));
      expect(AppColors.accent, equals(const Color(0xFFFFA61E)));
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
    });

    test('Dark theme satisfies Material 3 and dark slate specs', () {
      final theme = AppTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.surfaceDark));
    });
  });
}
