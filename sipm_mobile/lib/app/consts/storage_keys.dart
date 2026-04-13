/// Keys for secure storage
/// All keys used to store data in flutter_secure_storage
class StorageKeys {
  StorageKeys._();

  // Auth tokens
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String employeeId = 'employee_id'; // NEW
  static const String tenantId = 'tenant_id'; // NEW
  static const String twoFactorToken = 'two_factor_token';

  // User preferences
  static const String rememberMe = 'remember_me';

  // Biometric authentication
  static const String biometricEnabled = 'biometric_enabled';
  static const String biometricUsername = 'biometric_username';
  static const String biometricPassword = 'biometric_password';
  static const String biometricSetup = 'biometric_setup';
  static const String biometricPin = 'biometric_pin';
  static const String lastUsername = 'last_username';
  static const String lastPassword = 'last_password';

  //user setting language
  static const String languageCode = 'language_code';
}
