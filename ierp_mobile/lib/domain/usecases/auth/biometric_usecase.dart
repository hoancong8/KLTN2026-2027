import '../../../app/services/biometric_service.dart';

class BiometricUseCase {
  final BiometricService _biometricService;

  BiometricUseCase(this._biometricService);

  Future<bool> checkBiometricSetup() async {
    return await _biometricService.isBiometricSetup();
  }

  Future<bool> canUseBiometric() async {
    return await _biometricService.canCheckBiometrics();
  }

  Future<Map<String, String>?> authenticateWithBiometric() async {
    final canCheck = await _biometricService.canCheckBiometrics();
    if (!canCheck) {
      throw BiometricException('Sinh trắc học không khả dụng, vui lòng thiết lập trong Cài đặt.');
    }

    final availableBiometrics = await _biometricService.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      throw BiometricException('Không có sinh trắc học nào được đăng ký');
    }

    final isSetup = await _biometricService.isBiometricSetup();
    if (!isSetup) {
      throw BiometricException('Sinh trắc học chưa được thiết lập.');
    }

    final authenticated = await _biometricService.authenticate(
      reason: 'Xác thực để đăng nhập vào ứng dụng',
    );

    if (!authenticated) {
      throw BiometricException('Xác thực sinh trắc học không thành công');
    }

    final credentials = await _biometricService.getCurrentUserCredentials();
    if (credentials == null) {
      throw BiometricException('Không tìm thấy thông tin đăng nhập. Vui lòng thiết lập lại trong Cài đặt.');
    }

    if (credentials['username']?.isEmpty == true || credentials['password']?.isEmpty == true) {
      throw BiometricException('Thông tin đăng nhập không hợp lệ.');
    }


    return credentials;
  }
}

class BiometricException implements Exception {
  final String message;
  BiometricException(this.message);

  @override
  String toString() => message;
}