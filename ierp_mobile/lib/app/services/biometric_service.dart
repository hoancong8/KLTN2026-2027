import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../utils/biometric_helper.dart';
import 'secure_storage_service.dart';

class BiometricService {

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      print('Checking biometric availability...');
      final status = await BiometricHelper.getBiometricStatus();
      BiometricHelper.printBiometricDebugInfo(status);
      
      return status['canCheckBiometrics'] && status['isDeviceSupported'];
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticate({String reason = 'Xác thực để đăng nhập'}) async {
    try {
      print('Starting authentication with reason: $reason');
      
      // Kiểm tra thiết bị có hỗ trợ không
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        print('Device cannot check biometrics');
        return false;
      }
      
      // Thử phương pháp đơn giản trước
      try {
        final result = await _localAuth.authenticate(
          localizedReason: reason,
        );
        print('Simple authentication result: $result');
        return result;
      } catch (e) {
        print('Simple auth failed, trying with options: $e');
        
        // Nếu thất bại, thử với options
        final result = await _localAuth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        print('Options authentication result: $result');
        return result;
      }
    } on PlatformException catch (e) {
      print('PlatformException during authentication: ${e.code} - ${e.message}');
      final errorMessage = BiometricHelper.getBiometricErrorMessage(e);
      print('User-friendly error: $errorMessage');
      return false;
    } catch (e) {
      print('General authentication error: $e');
      return false;
    }
  }

  Future<bool> isBiometricSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_setup') ?? false;
  }

  Future<void> setBiometricSetup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_setup', value);
  }

  Future<void> saveCurrentUserCredentials(String username, String password) async {
    await SecureStorageService.instance.saveBiometricCredentials(username, password);
    await SecureStorageService.instance.setBiometricEnabled(true);
    print('Saved credentials for user: $username');
    
    // Debug: kiểm tra ngay sau khi lưu
    final saved = await SecureStorageService.instance.getBiometricCredentials();
    print('Verification - saved username: ${saved?['username']}');
  }

  Future<Map<String, String>?> getCurrentUserCredentials() async {
    final credentials = await SecureStorageService.instance.getBiometricCredentials();
    
    print('Getting credentials - username: ${credentials?['username']}, password: ${credentials?['password'] != null ? 'exists' : 'null'}');
    
    if (credentials != null) {
      return credentials;
    }
    
    print('No saved credentials found');
    return null;
  }

  Future<bool> setupBiometricWithLastLogin(String pin) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      
      // Lấy credentials từ last login
      final lastCredentials = await SecureStorageService.instance.getLastLoginCredentials();
      if (lastCredentials == null) {
        print('No last login credentials found');
        return false;
      }
      
      final authenticated = await authenticate(
        reason: 'Xác thực để thiết lập sinh trắc học',
      );
      
      if (authenticated) {
        await setBiometricSetup(true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('biometric_pin', pin);
        
        // Lưu credentials cho biometric
        await saveCurrentUserCredentials(
          lastCredentials['username']!,
          lastCredentials['password']!,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print('Setup biometric error: $e');
      return false;
    }
  }

  Future<bool> setupBiometricWithCredentials(String pin, String username, String password) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      
      final authenticated = await authenticate(
        reason: 'Xác thực để thiết lập sinh trắc học',
      );
      
      if (authenticated) {
        await setBiometricSetup(true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('biometric_pin', pin);
        
        // Lưu credentials mới
        await saveCurrentUserCredentials(username, password);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Setup biometric error: $e');
      return false;
    }
  }

  Future<bool> setupBiometricWithPin(String pin, {String? username, String? password}) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      
      final authenticated = await authenticate(
        reason: 'Xác thực để thiết lập sinh trắc học',
      );
      
      if (authenticated) {
        await setBiometricSetup(true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('biometric_pin', pin);
        
        // Nếu có username/password thì lưu, không thì giữ nguyên
        if (username != null && password != null) {
          await saveCurrentUserCredentials(username, password);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Setup biometric error: $e');
      return false;
    }
  }

  Future<void> clearCredentials() async {
    await SecureStorageService.instance.clearBiometricCredentials();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('biometric_pin');
    await prefs.remove('biometric_setup');
  }

  Future<void> clearSessionOnly() async {
    // Chỉ xóa session token, GIỮU LẠI biometric credentials
    await SecureStorageService.instance.clearAuthToken();
    
    // Debug: kiểm tra credentials vẫn còn sau khi logout
    final credentials = await SecureStorageService.instance.getBiometricCredentials();
    print('After logout - credentials still exist: ${credentials != null}');
    if (credentials != null) {
      print('Username still saved: ${credentials['username']}');
    }
    
    print('Cleared session only, keeping biometric credentials');
  }
}