import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import '../consts/app_log.dart';
import '../l10n_gen/app_localizations.dart';

class BiometricHelper {
  static Future<Map<String, dynamic>> getBiometricStatus() async {
    final LocalAuthentication localAuth = LocalAuthentication();

    try {
      final canCheckBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      final availableBiometrics = await localAuth.getAvailableBiometrics();

      return {
        'canCheckBiometrics': canCheckBiometrics,
        'isDeviceSupported': isDeviceSupported,
        'availableBiometrics': availableBiometrics,
        'hasFingerprint': availableBiometrics.contains(BiometricType.fingerprint),
        'hasFace': availableBiometrics.contains(BiometricType.face),
        'hasIris': availableBiometrics.contains(BiometricType.iris),
        'hasWeak': availableBiometrics.contains(BiometricType.weak),
        'hasStrong': availableBiometrics.contains(BiometricType.strong),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'canCheckBiometrics': false,
        'isDeviceSupported': false,
        'availableBiometrics': <BiometricType>[],
      };
    }
  }

  static String getBiometricErrorMessage(PlatformException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'NotAvailable':
        return l10n.auth_biometric_error_not_available;
      case 'NotEnrolled':
        return l10n.auth_biometric_error_not_enrolled;
      case 'LockedOut':
        return l10n.auth_biometric_error_locked_out;
      case 'PermanentlyLockedOut':
        return l10n.auth_biometric_error_permanently_locked;
      case 'UserCancel':
        return l10n.auth_biometric_error_user_cancel;
      case 'BiometricOnlyNotSupported':
        return l10n.auth_biometric_error_not_supported;
      case 'DeviceNotSupported':
        return l10n.auth_biometric_error_device_not_supported;
      case 'PasscodeNotSet':
        return l10n.auth_biometric_error_passcode_not_set;
      default:
        return l10n.auth_biometric_error_unknown(e.message ?? e.code);
    }
  }

  static void printBiometricDebugInfo(Map<String, dynamic> status) {
    if (!kDebugMode) return;

    AppLog.info('=== BIOMETRIC DEBUG INFO ===');
    AppLog.info('Can check biometrics: ${status['canCheckBiometrics']}');
    AppLog.info('Device supported: ${status['isDeviceSupported']}');
    AppLog.info('Available biometrics: ${status['availableBiometrics']}');
    AppLog.info('Has fingerprint: ${status['hasFingerprint']}');
    AppLog.info('Has face: ${status['hasFace']}');
    AppLog.info('Has iris: ${status['hasIris']}');
    AppLog.info('Has weak: ${status['hasWeak']}');
    AppLog.info('Has strong: ${status['hasStrong']}');

    if (status['hasFace'] == true) {
      AppLog.info('PRIMARY BIOMETRIC: Face ID / Face Recognition');
    } else if (status['hasFingerprint'] == true) {
      AppLog.info('PRIMARY BIOMETRIC: Fingerprint / Touch ID');
    } else if (status['hasStrong'] == true) {
      AppLog.info('PRIMARY BIOMETRIC: Strong biometric available');
    }

    if (status['error'] != null) {
      AppLog.info('Error: ${status['error']}');
    }
    AppLog.info('=== END DEBUG INFO ===');
  }
}