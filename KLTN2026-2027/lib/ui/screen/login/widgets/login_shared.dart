import 'package:flutter/material.dart';
import '../../../../../../app/theme/theme.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import '../../../../app/utils/exception_ext.dart';
import '../../../../domain/exceptions/app_exception.dart';

Widget buildLoginHeader({required AppLocalizations l10n}) {
  return Builder(
    builder: (context) {
      final colors = context.colors;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.com_app_name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            l10n.com_welcome_back,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    },
  );
}

Widget buildPrimaryButton({
  required String text,
  required VoidCallback? onPressed,
}) {
  return Builder(
    builder: (context) {
      final colors = context.colors;
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
    },
  );
}

Widget buildBiometricButton({
  required AppLocalizations l10n,
  required VoidCallback? onPressed,
}) {
  return Builder(
    builder: (context) {
      final colors = context.colors;
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(Icons.fingerprint, color: colors.primary, size: 22),
          label: Text(
            l10n.auth_biometric_login,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    },
  );
}

Widget buildErrorBox(BuildContext context, AppException error) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.colors.error.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: context.colors.error, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            error.getDisplayMessage(AppLocalizations.of(context)!),
            style: TextStyle(
              color: context.colors.error,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
