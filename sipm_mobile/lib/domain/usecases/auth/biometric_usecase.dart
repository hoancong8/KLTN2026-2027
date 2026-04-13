import '../../services/i_biometric_service.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/i_app_messages.dart';

// ---------------------------------------------------------------------------
// Biometric exceptions — theo đúng pattern của auth_exceptions.dart
// ---------------------------------------------------------------------------

class BiometricNotAvailableException extends AppException {
  const BiometricNotAvailableException();
  @override
  String resolve(IAppMessages messages) => messages.biometricNotAvailable;
}

class BiometricNotEnrolledException extends AppException {
  const BiometricNotEnrolledException();
  @override
  String resolve(IAppMessages messages) => messages.biometricNotEnrolled;
}

class BiometricNotSetupException extends AppException {
  const BiometricNotSetupException();
  @override
  String resolve(IAppMessages messages) => messages.biometricNotSetup;
}

class BiometricAuthFailedException extends AppException {
  const BiometricAuthFailedException();
  @override
  String resolve(IAppMessages messages) => messages.biometricAuthFailed;
}

class BiometricNoCredentialsException extends AppException {
  const BiometricNoCredentialsException();
  @override
  String resolve(IAppMessages messages) => messages.biometricNoCredentials;
}

class BiometricInvalidCredentialsException extends AppException {
  const BiometricInvalidCredentialsException();
  @override
  String resolve(IAppMessages messages) => messages.biometricInvalidCredentials;
}

// ---------------------------------------------------------------------------
// Use case
// ---------------------------------------------------------------------------

class BiometricUseCase {
  final IBiometricService _biometricService;

  BiometricUseCase(this._biometricService);

  Future<bool> checkBiometricSetup() async {
    return _biometricService.isBiometricSetup();
  }

  /// Gọi từ ViewModel sau khi login thành công để cập nhật credentials cho biometric.
  Future<void> saveCredentialsAfterLogin(String username, String password) async {
    final isSetup = await _biometricService.isBiometricSetup();
    if (isSetup && username.isNotEmpty && password.isNotEmpty) {
      await _biometricService.saveCurrentUserCredentials(username, password);
    }
  }

  Future<bool> canUseBiometric() async {
    return _biometricService.canCheckBiometrics();
  }

  Future<Map<String, String>?> authenticateWithBiometric(IAppMessages messages) async {
    final canCheck = await _biometricService.canCheckBiometrics();
    if (!canCheck) throw const BiometricNotAvailableException();

    final availableBiometrics = await _biometricService.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) throw const BiometricNotEnrolledException();

    final isSetup = await _biometricService.isBiometricSetup();
    if (!isSetup) throw const BiometricNotSetupException();

    final authenticated = await _biometricService.authenticate(
      reason: messages.biometricReasonLogin,
    );
    if (!authenticated) throw const BiometricAuthFailedException();

    final credentials = await _biometricService.getCurrentUserCredentials();
    if (credentials == null) throw const BiometricNoCredentialsException();

    if (credentials['username']?.isEmpty == true || credentials['password']?.isEmpty == true) {
      throw const BiometricInvalidCredentialsException();
    }

    return credentials;
  }
}