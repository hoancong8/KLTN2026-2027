import 'package:flutter/material.dart';

/// Design tokens for colors across the KLTN2026-2027 application.
/// Provides brand palettes, semantic functional colors, neutral slate scales,
/// surfaces, borders, domain-specific sports tokens, and backward compatibility.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // 1. BRAND PALETTE (EMERALD & MINT)
  // ---------------------------------------------------------------------------
  /// Main brand color - energetic, fresh mint/emerald green.
  static const Color primary = Color(0xFF3CC18E);
  static const Color primaryDark = Color(0xFF2EA578);
  static const Color primaryLight = Color(0xFF55D4A2);
  static const Color primaryHeader = Color(0xFF007A55);
  static const Color primaryContainer = Color(0xFFE8F9F3);
  static const Color primaryMuted = Color(0xFFD1FAE5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF0F5A40);

  // ---------------------------------------------------------------------------
  // 2. SECONDARY / ACCENT PALETTE (OCEAN SKY & WARM AMBER)
  // ---------------------------------------------------------------------------
  /// Secondary color - ocean sky blue for auxiliary accents & highlights.
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryDark = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryContainer = Color(0xFFF0F9FF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF075985);

  /// Warm amber / gold - used for MVP ratings, tournament tiers, badges.
  static const Color accent = Color(0xFFFFA61E);
  static const Color accentLight = Color(0xFFFFF3DD);
  static const Color accentDark = Color(0xFFD97706);
  static const Color onAccent = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // 3. SEMANTIC FUNCTIONAL COLORS
  // ---------------------------------------------------------------------------
  /// Success states, confirmed bookings, winning sets.
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color onSuccess = Color(0xFF065F46);

  /// Warning states, pending confirmations, caution alerts.
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color onWarning = Color(0xFF92400E);

  /// Error states, form validations, cancelled sessions, destructive actions.
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorContainer = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color onError = Color(0xFF991B1B);

  /// Informational banners, tips, help notices.
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoContainer = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color onInfo = Color(0xFF1E40AF);

  // ---------------------------------------------------------------------------
  // 4. NEUTRAL SLATE SCALE (OLED & LCD BALANCED)
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral950 = Color(0xFF020617);

  // ---------------------------------------------------------------------------
  // 5. SURFACE & BACKGROUND TOKENS (LIGHT DEFAULT)
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0B1220);
  static const Color surfaceDarkCard = Color(0xFF162032);
  static const Color surfaceDarkInput = Color(0xFF1E293B);
  static const Color navyDark = Color(0xFF0F1E36);

  // ---------------------------------------------------------------------------
  // 6. BORDER & DIVIDER TOKENS
  // ---------------------------------------------------------------------------
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderStrong = Color(0xFFCBD5E1);
  static const Color borderFocus = Color(0xFF3CC18E);
  static const Color divider = Color(0xFFEAEAEA);
  static const Color overlay = Color(0x66000000);
  static const Color overlaySubtle = Color(0x1A000000);

  // ---------------------------------------------------------------------------
  // 7. TEXT SEMANTIC HIERARCHY
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textBrand = Color(0xFF3CC18E);

  // ---------------------------------------------------------------------------
  // 8. BADMINTON & SPORTS DOMAIN SPECIFIC TOKENS
  // ---------------------------------------------------------------------------
  static const Color courtGreen = Color(0xFF0D5E3A);
  static const Color courtLine = Color(0xFFFFFFFF);
  static const Color tierGold = Color(0xFFF59E0B);
  static const Color tierSilver = Color(0xFF94A3B8);
  static const Color tierBronze = Color(0xFFB45309);

  static const Color statusUpcoming = Color(0xFF3B82F6);
  static const Color statusOngoing = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF64748B);
  static const Color statusCancelled = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // 8.1 CLUB ROLE & BADGE PALETTE TOKENS
  // ---------------------------------------------------------------------------
  static const Color roleHost = Color(0xFF9333EA);
  static const Color roleDeputy = Color(0xFF2563EB);
  static const Color roleTreasurer = Color(0xFFD97706);
  static const Color roleMember = Color(0xFF16A34A);
  static const Color roleGuest = Color(0xFF6B7280);
  static const Color roleViolet = Color(0xFF7C3AED);
  static const Color roleTeal = Color(0xFF0D9488);
  static const Color roleRose = Color(0xFFE11D48);
  static const Color roleOrange = Color(0xFFEA580C);
  static const Color roleSky = Color(0xFF0284C7);

  // ---------------------------------------------------------------------------
  // 8.2 SKILL LEVEL PALETTE TOKENS
  // ---------------------------------------------------------------------------
  static const Color skillBeginner = Color(0xFF9E9E9E);
  static const Color skillElementary = Color(0xFF8BC34A);
  static const Color skillIntermediate = Color(0xFF4CAF50);
  static const Color skillUpperIntermediate = Color(0xFF0284C7);
  static const Color skillAdvanced = Color(0xFF3F51B5);
  static const Color skillSemiPro = Color(0xFFF59E0B);
  static const Color skillPro = Color(0xFFEF4444);

  // ---------------------------------------------------------------------------
  // 8.3 ACCENT HIGHLIGHT & SHADE TOKENS
  // ---------------------------------------------------------------------------
  static const Color accentOrange = Color(0xFFFF5722);
  static const Color accentOrangeLight = Color(0xFFFF7043);
  static const Color violetLight = Color(0xFFF3E8FF);
  static const Color violetBorder = Color(0xFFD8B4FE);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color amberText = Color(0xFFB45309);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFE6F7F5);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFFDE8EC);

  // ---------------------------------------------------------------------------
  // 9. GRADIENTS
  // ---------------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3CC18E), Color(0xFF2EA578)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1220), Color(0xFF162032)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient brandSubtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x143CC18E), Color(0xFFFFFFFF)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA61E), Color(0xFFD97706)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // ---------------------------------------------------------------------------
  // 10. CONTEXTUAL ADAPTIVE HELPER
  // ---------------------------------------------------------------------------
  /// Helper to access dynamic theme tokens according to current BuildContext.
  static AppThemeColors of(BuildContext context) =>
      Theme.of(context).extension<AppThemeColors>() ??
      (Theme.of(context).brightness == Brightness.dark
          ? AppThemeColors.dark
          : AppThemeColors.light);

  // ---------------------------------------------------------------------------
  // 11. BACKWARD COMPATIBILITY ALIASES (FOR EXISTING CODEBASE)
  // ---------------------------------------------------------------------------
  static const Color bgr = white;
  static const Color cYan = Color(0xFFF4FDFA);
  static const Color cYanPrimary = Color(0xFF21D4B4);
  static const Color cBlack_50 = Color(0xFF1C1B1B);
  static const Color cGray = Color(0xFF6F7384);
  static const Color cGray_50 = Color(0xFFF4F5FD);
  static const Color cYan_50 = Color(0xFFF4FDFA);
  static const Color cError = Color(0xFFCC1B1B);
  static const Color cRed = cError;
  static const Color cGray_100 = Color(0xFFC0C0C0);
  static const Color cGreen_50 = Color(0xFF08E488);
  static const Color cGreen = Color(0xFF16A34A);
  static const Color cBlue = Color(0xFF1F8BDA);
  static const Color cBlack = Color(0xFF000000);
  static const Color cRed_50 = Color(0xFFEE4D4D);
  static const Color cGreen70 = Color(0xFFF2F5EB);
  static const Color cGray70 = Color(0xFFE2E2E2);
  static const Color cMainApp = Color(0xFFFFA61E);
  static const Color cMain50 = Color(0xFFFFB442);
  static const Color cMain70 = Color(0xFFFFE8BC);
  static const Color cBgr = Color(0xFFF8F8F8);
  static const Color cMain = Color(0xFF3CC18E);
  static const Color cBorderInput = Color(0xFFB7BBC1);
  static const Color cTitle = Color(0xFF263238);
  static const Color cDark = Color(0xFF0F172A);
  static const Color cWeak = Color(0xFFFAC71E);
  static const Color cNeedCheck = Color(0xFFFF6D0C);
  static const Color cAlert = Color(0xFFFA2020);
  static const Color cText = Color(0xDD000000);
  static const Color cMuted = Color(0xFF8C8C8C);
  static const Color cChip = Color(0xFFEFF8F4);
  static const Color cDivider = Color(0xFFEAEAEA);

  // Legacy numbered palette
  static const Color color1 = Color(0xFF404045);
  static const Color color2 = Color(0xFFFFFFFF);
  static const Color color3 = Color(0xFF3E8EEB);
  static const Color color4 = Color(0xFF23C4DA);
  static const Color color5 = Color(0xFFFAC02C);
  static const Color color6 = Color(0xFFFA2CD9);
  static const Color color7 = Color(0xFF2FD6A4);
  static const Color color8 = Color(0xFF2FD635);
  static const Color color9 = Color(0xFF196EED);
  static const Color color10 = Color(0xFF0B62E4);
  static const Color color11 = Color(0xFF307DF0);
  static const Color color12 = Color(0xFF4D90F4);
  static const Color color13 = Color(0xFF0BBAE0);
  static const Color color14 = Color(0xFF0BE0E0);
  static const Color color15 = Color(0xFF1FEDED);
  static const Color color16 = Color(0xFF52F4F4);
  static const Color color17 = Color(0xFF07E87C);
  static const Color color18 = Color(0xFF23EF8D);
  static const Color color19 = Color(0xFF5DFDB0);
  static const Color color20 = Color(0xFF10E94D);
  static const Color color21 = Color(0xFF62E910);
  static const Color color22 = Color(0xFF6BF218);
  static const Color color23 = Color(0xFF8DFC49);
  static const Color color24 = Color(0xFFB4DF08);
  static const Color color25 = Color(0xFFC6F01C);
  static const Color color26 = Color(0xFFD5FA40);
  static const Color color27 = Color(0xFFEFCB0E);
  static const Color color28 = Color(0xFFF6D941);
  static const Color color29 = Color(0xFFF3AB1F);
  static const Color color30 = Color(0xFFF6B941);
  static const Color color31 = Color(0xFFED6C0F);
  static const Color color32 = Color(0xFFFF9040);
  static const Color color33 = Color(0xFFFF6C6C);
  static const Color color34 = Color(0xFFF52525);
  static const Color color35 = Color(0xFFF41673);
  static const Color color36 = Color(0xFFFF4A96);
  static const Color color37 = Color(0xFFE507B5);
  static const Color color38 = Color(0xFFF314C2);
  static const Color color39 = Color(0xFFD605E9);
  static const Color color40 = Color(0xFFD51FF2);
  static const Color color41 = Color(0xFF8404E9);
  static const Color color42 = Color(0xFF9E23FE);
  static const Color color43 = Color(0xFF8423FE);
  static const Color color44 = Color(0xFF5C23FE);
  static const Color color45 = Color(0xFF4C48FF);
  static const Color color46 = Color(0xFF3F3BFE);
}

/// Shorthand type alias so either AppColor or AppColors can be used interchangeably.
typedef AppColor = AppColors;

// -----------------------------------------------------------------------------
// ADAPTIVE THEME EXTENSION (LIGHT & DARK THEME UNIFICATION)
// -----------------------------------------------------------------------------

/// Immutable ThemeExtension providing theme-adaptive semantic color tokens.
/// Guarantees that any UI component referencing `context.colors.*` automatically
/// resolves the visually correct, high-contrast palette for Light and Dark modes.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceElevated;
  final Color cardBackground;
  final Color cardBorder;
  final Color inputFill;
  final Color inputBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textPlaceholder;
  final Color textDisabled;
  final Color textInverse;
  final Color textBrand;
  final Color border;
  final Color borderSubtle;
  final Color borderStrong;
  final Color divider;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color accent;
  final Color accentLight;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color error;
  final Color errorContainer;
  final Color info;
  final Color infoContainer;
  final Color courtGreen;
  final Color courtLine;

  const AppThemeColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceElevated,
    required this.cardBackground,
    required this.cardBorder,
    required this.inputFill,
    required this.inputBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textPlaceholder,
    required this.textDisabled,
    required this.textInverse,
    required this.textBrand,
    required this.border,
    required this.borderSubtle,
    required this.borderStrong,
    required this.divider,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.accent,
    required this.accentLight,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.error,
    required this.errorContainer,
    required this.info,
    required this.infoContainer,
    required this.courtGreen,
    required this.courtLine,
  });

  /// Light Mode Palette - Crisp, airy, high-contrast Slate & Mint.
  static const AppThemeColors light = AppThemeColors(
    brightness: Brightness.light,
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF1F5F9),
    surfaceElevated: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE2E8F0),
    inputFill: Color(0xFFF1F5F9),
    inputBorder: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    textPlaceholder: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),
    textInverse: Color(0xFFFFFFFF),
    textBrand: Color(0xFF3CC18E),
    border: Color(0xFFE2E8F0),
    borderSubtle: Color(0xFFF1F5F9),
    borderStrong: Color(0xFFCBD5E1),
    divider: Color(0xFFEAEAEA),
    primary: Color(0xFF3CC18E),
    primaryDark: Color(0xFF2EA578),
    primaryLight: Color(0xFF55D4A2),
    primaryContainer: Color(0xFFE8F9F3),
    onPrimaryContainer: Color(0xFF0F5A40),
    secondary: Color(0xFF0EA5E9),
    secondaryContainer: Color(0xFFF0F9FF),
    onSecondaryContainer: Color(0xFF075985),
    accent: Color(0xFFFFA61E),
    accentLight: Color(0xFFFFF3DD),
    success: Color(0xFF10B981),
    successContainer: Color(0xFFECFDF5),
    warning: Color(0xFFF59E0B),
    warningContainer: Color(0xFFFFFBEB),
    error: Color(0xFFEF4444),
    errorContainer: Color(0xFFFEF2F2),
    info: Color(0xFF3B82F6),
    infoContainer: Color(0xFFEFF6FF),
    courtGreen: Color(0xFF0D5E3A),
    courtLine: Color(0xFFFFFFFF),
  );

  /// Dark Mode Palette - Deep Navy Slate, reduced glare, calibrated contrast.
  static const AppThemeColors dark = AppThemeColors(
    brightness: Brightness.dark,
    background: Color(0xFF0B1220),
    surface: Color(0xFF162032),
    surfaceSubtle: Color(0xFF1E293B),
    surfaceElevated: Color(0xFF1E293B),
    cardBackground: Color(0xFF162032),
    cardBorder: Color(0xFF1E293B),
    inputFill: Color(0xFF1E293B),
    inputBorder: Color(0xFF334155),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    textPlaceholder: Color(0xFF475569),
    textDisabled: Color(0xFF334155),
    textInverse: Color(0xFF0F172A),
    textBrand: Color(0xFF3CC18E),
    border: Color(0xFF334155),
    borderSubtle: Color(0xFF1E293B),
    borderStrong: Color(0xFF475569),
    divider: Color(0xFF1E293B),
    primary: Color(0xFF3CC18E),
    primaryDark: Color(0xFF2EA578),
    primaryLight: Color(0xFF55D4A2),
    primaryContainer: Color(0xFF0F5A40),
    onPrimaryContainer: Color(0xFFA7F3D0),
    secondary: Color(0xFF38BDF8),
    secondaryContainer: Color(0xFF075985),
    onSecondaryContainer: Color(0xFFBAE6FD),
    accent: Color(0xFFFBBF24),
    accentLight: Color(0xFF78350F),
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF78350F),
    error: Color(0xFFF87171),
    errorContainer: Color(0xFF7F1D1D),
    info: Color(0xFF60A5FA),
    infoContainer: Color(0xFF1E3A8A),
    courtGreen: Color(0xFF0D5E3A),
    courtLine: Color(0xFFFFFFFF),
  );

  @override
  AppThemeColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceElevated,
    Color? cardBackground,
    Color? cardBorder,
    Color? inputFill,
    Color? inputBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textPlaceholder,
    Color? textDisabled,
    Color? textInverse,
    Color? textBrand,
    Color? border,
    Color? borderSubtle,
    Color? borderStrong,
    Color? divider,
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? accent,
    Color? accentLight,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? error,
    Color? errorContainer,
    Color? info,
    Color? infoContainer,
    Color? courtGreen,
    Color? courtLine,
  }) {
    return AppThemeColors(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      textBrand: textBrand ?? this.textBrand,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      courtGreen: courtGreen ?? this.courtGreen,
      courtLine: courtLine ?? this.courtLine,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t) ?? inputBorder,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t) ?? textPlaceholder,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      textInverse: Color.lerp(textInverse, other.textInverse, t) ?? textInverse,
      textBrand: Color.lerp(textBrand, other.textBrand, t) ?? textBrand,
      border: Color.lerp(border, other.border, t) ?? border,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t) ?? borderSubtle,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t) ?? primaryDark,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t) ?? primaryLight,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t) ?? primaryContainer,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t) ?? onPrimaryContainer,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t) ?? secondaryContainer,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t) ?? onSecondaryContainer,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentLight: Color.lerp(accentLight, other.accentLight, t) ?? accentLight,
      success: Color.lerp(success, other.success, t) ?? success,
      successContainer: Color.lerp(successContainer, other.successContainer, t) ?? successContainer,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t) ?? warningContainer,
      error: Color.lerp(error, other.error, t) ?? error,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      info: Color.lerp(info, other.info, t) ?? info,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t) ?? infoContainer,
      courtGreen: Color.lerp(courtGreen, other.courtGreen, t) ?? courtGreen,
      courtLine: Color.lerp(courtLine, other.courtLine, t) ?? courtLine,
    );
  }
}

/// Convenient BuildContext extension to access design system tokens with zero boilerplate.
extension AppThemeContextExtension on BuildContext {
  /// Resolves the theme-adaptive colors palette for current theme mode.
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppThemeColors.dark
          : AppThemeColors.light);

  /// Standard Material 3 ColorScheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Material 3 TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick check for Dark Mode status.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
