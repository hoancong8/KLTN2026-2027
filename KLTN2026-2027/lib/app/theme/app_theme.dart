import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Central theme configuration for KLTN2026-2027 application.
/// Provides meticulously tuned Material 3 Light and Dark themes that
/// respect brand colors, accessibility standards, and clean elevation.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // 1. LIGHT THEME
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    const colors = AppThemeColors.light;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: colors.primary,
      onPrimary: AppColors.white,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.accent,
      onTertiary: AppColors.white,
      tertiaryContainer: colors.accentLight,
      onTertiaryContainer: const Color(0xFFB45309),
      error: colors.error,
      onError: AppColors.white,
      errorContainer: colors.errorContainer,
      onErrorContainer: AppColors.onError,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: colors.background,
      surfaceContainer: colors.surfaceSubtle,
      surfaceContainerHigh: colors.border,
      surfaceContainerHighest: colors.borderStrong,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      shadow: const Color(0x14000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      fontFamily: null,
      extensions: const <ThemeExtension<dynamic>>[
        AppThemeColors.light,
      ],

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary, size: AppSpacing.iconMd),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: colors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          elevation: 0,
          minimumSize: const Size(64, AppSpacing.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          side: BorderSide(color: colors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.labelLarge.copyWith(color: colors.primary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          textStyle: AppTypography.labelLarge.copyWith(color: colors.primary),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md + 2,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textPlaceholder),
        labelStyle: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.onPrimaryContainer, size: AppSpacing.iconMd);
          }
          return IconThemeData(color: colors.textMuted, size: AppSpacing.iconMd);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: colors.primaryDark,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(color: colors.textMuted);
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textMuted,
        labelStyle: AppTypography.titleSmall,
        unselectedLabelStyle: AppTypography.titleSmall,
        indicatorColor: colors.primary,
        dividerColor: colors.borderSubtle,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSubtle,
        selectedColor: colors.primaryContainer,
        labelStyle: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: colors.onPrimaryContainer),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
        side: BorderSide(color: colors.borderSubtle),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        showDragHandle: true,
        dragHandleColor: colors.borderStrong,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: colors.textInverse),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      // ListTile Theme
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: AppSpacing.iconMd,
      ),

      // Text Theme
      textTheme: AppTypography.toTextTheme(
        defaultColor: colors.textPrimary,
        secondaryColor: colors.textSecondary,
        mutedColor: colors.textMuted,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. DARK THEME
  // ---------------------------------------------------------------------------
  static ThemeData get dark {
    const colors = AppThemeColors.dark;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.primary,
      onPrimary: AppColors.white,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.background,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.accent,
      onTertiary: colors.background,
      tertiaryContainer: colors.accentLight,
      onTertiaryContainer: const Color(0xFFFDE68A),
      error: colors.error,
      onError: colors.background,
      errorContainer: colors.errorContainer,
      onErrorContainer: const Color(0xFFFECACA),
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: const Color(0xFF0F172A),
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surfaceSubtle,
      surfaceContainerHighest: const Color(0xFF334155),
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      shadow: const Color(0x33000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      fontFamily: null,
      extensions: const <ThemeExtension<dynamic>>[
        AppThemeColors.dark,
      ],

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary, size: AppSpacing.iconMd),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: colors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.white),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          elevation: 0,
          minimumSize: const Size(64, AppSpacing.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          side: BorderSide(color: colors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTypography.labelLarge.copyWith(color: colors.primary),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          textStyle: AppTypography.labelLarge.copyWith(color: colors.primary),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md + 2,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textPlaceholder),
        labelStyle: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.onPrimaryContainer, size: AppSpacing.iconMd);
          }
          return IconThemeData(color: colors.textMuted, size: AppSpacing.iconMd);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: colors.primaryLight,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(color: colors.textMuted);
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textMuted,
        labelStyle: AppTypography.titleSmall,
        unselectedLabelStyle: AppTypography.titleSmall,
        indicatorColor: colors.primary,
        dividerColor: colors.borderSubtle,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSubtle,
        selectedColor: colors.primaryContainer,
        labelStyle: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: colors.onPrimaryContainer),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
        side: BorderSide(color: colors.borderSubtle),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        showDragHandle: true,
        dragHandleColor: colors.borderStrong,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),

      // ListTile Theme
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: AppSpacing.iconMd,
      ),

      // Text Theme
      textTheme: AppTypography.toTextTheme(
        defaultColor: colors.textPrimary,
        secondaryColor: colors.textSecondary,
        mutedColor: colors.textMuted,
      ),
    );
  }
}
