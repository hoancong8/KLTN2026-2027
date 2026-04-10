import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';

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
        'hasFingerprint': availableBiometrics.contains(
          BiometricType.fingerprint,
        ),
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

  static String getBiometricErrorMessage(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return 'Xác thực sinh trắc học không khả dụng trên thiết bị này';
      case 'NotEnrolled':
        return 'Không có sinh trắc học nào được đăng ký. Vui lòng đăng ký vân tay hoặc Face ID trong cài đặt thiết bị';
      case 'LockedOut':
        return 'Xác thực sinh trắc học bị khóa tạm thời do quá nhiều lần thử sai';
      case 'PermanentlyLockedOut':
        return 'Xác thực sinh trắc học bị khóa vĩnh viễn. Vui lòng sử dụng mật khẩu thiết bị';
      case 'UserCancel':
        return 'Người dùng đã hủy xác thực';
      case 'BiometricOnlyNotSupported':
        return 'Thiết bị không hỗ trợ xác thực chỉ bằng sinh trắc học';
      case 'DeviceNotSupported':
        return 'Thiết bị không hỗ trợ xác thực sinh trắc học';
      case 'PasscodeNotSet':
        return 'Chưa thiết lập mật khẩu màn hình khóa';
      default:
        return 'Lỗi xác thực sinh trắc học: ${e.message ?? e.code}';
    }
  }

  static void printBiometricDebugInfo(Map<String, dynamic> status) {
    AppLog.info('=== BIOMETRIC DEBUG INFO ===');
    AppLog.info('Can check biometrics: ${status['canCheckBiometrics']}');
    AppLog.info('Device supported: ${status['isDeviceSupported']}');
    AppLog.info('Available biometrics: ${status['availableBiometrics']}');
    AppLog.info('Has fingerprint: ${status['hasFingerprint']}');
    AppLog.info('Has face: ${status['hasFace']}');
    AppLog.info('Has iris: ${status['hasIris']}');
    AppLog.info('Has weak: ${status['hasWeak']}');
    AppLog.info('Has strong: ${status['hasStrong']}');

    // Hiển thị loại biometric chính
    if (status['hasFace']) {
      AppLog.info('PRIMARY BIOMETRIC: Face ID / Face Recognition');
    } else if (status['hasFingerprint']) {
      AppLog.info('PRIMARY BIOMETRIC: Fingerprint / Touch ID');
    } else if (status['hasStrong']) {
      AppLog.info('PRIMARY BIOMETRIC: Strong biometric available');
    }

    if (status['error'] != null) {
      AppLog.info('Error: ${status['error']}');
    }
    AppLog.info('=== END DEBUG INFO ===');
  }
}
