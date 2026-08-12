import '../exceptions/i_app_messages.dart';

enum AppBiometricType {
  face,
  fingerprint,
  iris,
  weak,
  strong,
}

abstract class IBiometricService {
  Future<bool> canCheckBiometrics();
  Future<List<AppBiometricType>> getAvailableBiometrics();
  Future<bool> authenticate({required String reason});
  Future<bool> isBiometricSetup();
  Future<void> saveCurrentUserCredentials(String username, String password);
  Future<Map<String, String>?> getCurrentUserCredentials();
  Future<bool> setupBiometric({
    required IAppMessages messages,
    required String pin,
    String? username,
    String? password,
  });
  Future<void> clearCredentials();
  Future<void> clearSessionOnly();
}
