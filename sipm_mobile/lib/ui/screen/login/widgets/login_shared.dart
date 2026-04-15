import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/l10n_gen/app_localizations.dart';
import '../../../../app/utils/exception_ext.dart';
import '../../../../domain/exceptions/app_exception.dart';

Widget buildLoginHeader({required AppLocalizations l10n}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColor.cMain,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.cMain.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.business_center_outlined,
          color: AppColor.white,
          size: 40,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        l10n.com_app_name,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColor.cTitle,
          letterSpacing: -0.5,
        ),
      ),
      Text(
        l10n.com_welcome_back,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColor.cTitle,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget buildPrimaryButton({
  required String text,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.cMain,
        foregroundColor: AppColor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: AppColor.cMain.withValues(alpha: 0.5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

Widget buildBiometricButton({
  required AppLocalizations l10n,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.cMain,
        side: BorderSide(color: AppColor.cMain, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.fingerprint, color: AppColor.cMain, size: 22),
      label: Text(
        l10n.auth_biometric_login,
        style: const TextStyle(
          color: AppColor.cMain,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget buildErrorBox(BuildContext context, AppException error) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColor.cError.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.cError.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppColor.cError, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            error.getDisplayMessage(AppLocalizations.of(context)!),
            style: const TextStyle(
              color: AppColor.cError,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
