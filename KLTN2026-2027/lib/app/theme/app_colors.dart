import 'package:flutter/material.dart';

/// Design tokens for colors across the KLTN2026-2027 application.
/// Provides brand palettes, semantic functional colors, neutral slate scales,
/// surfaces, borders, and backward compatibility for legacy color constants.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // 1. BRAND PALETTE (EMERALD & MINT)
  // ---------------------------------------------------------------------------
  /// Main brand color - energetic, fresh mint/emerald green.
  static const Color primary = Color(0xFF3CC18E);
  static const Color primaryDark = Color(0xFF2EA578);
  static const Color primaryLight = Color(0xFF55D4A2);
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
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color onSuccess = Color(0xFF065F46);

  /// Warning states, pending confirmations, caution alerts.
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color onWarning = Color(0xFF92400E);

  /// Error states, form validations, cancelled sessions, destructive actions.
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color onError = Color(0xFF991B1B);

  /// Informational banners, tips, help notices.
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color onInfo = Color(0xFF1E40AF);

  // ---------------------------------------------------------------------------
  // 4. NEUTRAL SLATE SCALE (OLED & LCD BALANCED)
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

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
  // 5. SURFACE & BACKGROUND TOKENS
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0B1220);
  static const Color surfaceDarkCard = Color(0xFF162032);
  static const Color surfaceDarkInput = Color(0xFF1E293B);

  // ---------------------------------------------------------------------------
  // 6. BORDER & DIVIDER TOKENS
  // ---------------------------------------------------------------------------
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderStrong = Color(0xFFCBD5E1);
  static const Color borderFocus = Color(0xFF3CC18E);
  static const Color divider = Color(0xFFEAEAEA);
  static const Color overlay = Color(0x66000000);

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
  // 10. BACKWARD COMPATIBILITY ALIASES (FOR EXISTING CODEBASE)
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
  static const Color cText = Colors.black87;
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
