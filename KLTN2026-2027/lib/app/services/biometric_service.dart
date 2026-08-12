import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../consts/app_log.dart';
import '../utils/biometric_helper.dart';
import '../../domain/exceptions/i_app_messages.dart';
import '../../domain/services/i_biometric_service.dart';
import 'secure_storage_service.dart';

class BiometricService implements IBiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      AppLog.info('Checking biometric availability...');
      final status = await BiometricHelper.getBiometricStatus();
      BiometricHelper.printBiometricDebugInfo(status);
      return status['canCheckBiometrics'] == true && status['isDeviceSupported'] == true;
    } catch (e) {
      AppLog.error('Error checking biometrics: ', e);
      return false;
    }
  }

  @override
  Future<List<AppBiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      AppLog.info('Available biometrics: $availableBiometrics');

      return availableBiometrics.map((type) {
        switch (type) {
          case BiometricType.face: return AppBiometricType.face;
          case BiometricType.fingerprint: return AppBiometricType.fingerprint;
          case BiometricType.iris: return AppBiometricType.iris;
          case BiometricType.weak: return AppBiometricType.weak;
          case BiometricType.strong: return AppBiometricType.strong;
        }
      }).toList();
    } catch (e) {
      AppLog.error('Error getting available biometrics: ', e);
      return [];
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      AppLog.info('Starting authentication...');

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        AppLog.info('Device cannot check biometrics');
        return false;
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      AppLog.info('Authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      AppLog.error('PlatformException during authentication: ', e);
      return false;
    } catch (e) {
      AppLog.error('General authentication error: ', e);
      return false;
    }
  }

  @override
  Future<bool> isBiometricSetup() async {
    return SecureStorageService.instance.getBiometricSetup();
  }

  @override
  Future<void> saveCurrentUserCredentials(String username, String password) async {
    await SecureStorageService.instance.saveBiometricCredentials(username, password);
    await SecureStorageService.instance.setBiometricEnabled(true);
    AppLog.info('Saved biometric credentials for user: $username');
  }

  @override
  Future<Map<String, String>?> getCurrentUserCredentials() async {
    return SecureStorageService.instance.getBiometricCredentials();
  }

  /// Setup biometric. Credentials can be provided directly or loaded from last login.
  @override
  Future<bool> setupBiometric({
    required IAppMessages messages,
    required String pin,
    String? username,
    String? password,
  }) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      if (username == null || password == null) {
        final lastCredentials = await SecureStorageService.instance.getLastLoginCredentials();
        if (lastCredentials == null) {
          AppLog.info('No credentials available for biometric setup');
          return false;
        }
        username = lastCredentials['username']!;
        password = lastCredentials['password']!;
      }

      final authenticated = await authenticate(reason: messages.biometricReasonLogin);
      if (!authenticated) return false;

      await SecureStorageService.instance.setBiometricSetup(true);
      await SecureStorageService.instance.saveBiometricPin(pin);
      await saveCurrentUserCredentials(username, password);

      return true;
    } catch (e) {
      AppLog.error('Setup biometric error: ', e);
      return false;
    }
  }

  @override
  Future<void> clearCredentials() async {
    await SecureStorageService.instance.clearBiometricCredentials();
  }

  @override
  Future<void> clearSessionOnly() async {
    await SecureStorageService.instance.clearAuthToken();
    AppLog.info('Cleared session only, keeping biometric credentials');
  }
}
