import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_token.dart';
import '../consts/storage_keys.dart';

/// Service for handling secure storage operations
/// Provides methods to save, retrieve, and delete auth tokens
class SecureStorageService {
  static SecureStorageService? _instance;
  late final FlutterSecureStorage _storage;

  SecureStorageService._() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
      webOptions: WebOptions(
        dbName: 'KLTN_SecureStorage',
        publicKey: 'KLTN_PublicKey',
      ),
    );
  }

  /// Get singleton instance
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  /// Save auth token to secure storage
  Future<void> saveAuthToken(AuthToken token) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.accessToken, token.accessToken);
        await prefs.setString(StorageKeys.refreshToken, token.refreshToken);
        if (token.userId != null) {
          await prefs.setString(StorageKeys.userId, token.userId!);
        }
      }

      await Future.wait([
        _storage.write(key: StorageKeys.accessToken, value: token.accessToken),
        _storage.write(
          key: StorageKeys.refreshToken,
          value: token.refreshToken,
        ),
        if (token.userId != null)
          _storage.write(
            key: StorageKeys.userId,
            value: token.userId!,
          ),
      ]);
    } catch (_) {}
  }

  /// Get auth token from secure storage
  /// Returns null if token is not found or incomplete
  Future<AuthToken?> getAuthToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString(StorageKeys.accessToken);
        final refreshToken = prefs.getString(StorageKeys.refreshToken);

        if (accessToken != null && refreshToken != null) {
          final userIdStr = prefs.getString(StorageKeys.userId);

          return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: userIdStr,
          );
        }
      }

      final accessToken = await _storage.read(key: StorageKeys.accessToken);
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      final userIdStr = await _storage.read(key: StorageKeys.userId);

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userIdStr,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clear all auth tokens from secure storage
  Future<void> clearAuthToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(StorageKeys.accessToken);
        await prefs.remove(StorageKeys.refreshToken);
        await prefs.remove(StorageKeys.userId);
        await prefs.remove(StorageKeys.activeClubId);
      }
    } catch (_) {}

    try {
      await Future.wait([
        _storage.delete(key: StorageKeys.accessToken),
        _storage.delete(key: StorageKeys.refreshToken),
        _storage.delete(key: StorageKeys.userId),
        _storage.delete(key: StorageKeys.activeClubId),
      ]);
    } catch (_) {}
  }

  /// Save Active Club ID (Guid string)
  Future<void> saveActiveClubId(String clubId) async {
    await _storage.write(key: StorageKeys.activeClubId, value: clubId);
  }

  /// Get Active Club ID (Guid string)
  Future<String?> getActiveClubId() async {
    return await _storage.read(key: StorageKeys.activeClubId);
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final accessToken = await _storage.read(key: StorageKeys.accessToken);
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Save remember me preference
  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: StorageKeys.rememberMe, value: value.toString());
  }

  /// Get remember me preference
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: StorageKeys.rememberMe);
    return value == 'true';
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Biometric related methods

  /// Save biometric enabled preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: StorageKeys.biometricEnabled,
      value: enabled.toString(),
    );
  }

  /// Get biometric enabled preference
  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: StorageKeys.biometricEnabled);
    return value == 'true';
  }

  /// Save credentials for biometric login
  Future<void> saveBiometricCredentials(
    String username,
    String password,
  ) async {
    await Future.wait([
      _storage.write(key: StorageKeys.biometricUsername, value: username),
      _storage.write(key: StorageKeys.biometricPassword, value: password),
    ]);
  }

  /// Get saved biometric credentials
  Future<Map<String, String>?> getBiometricCredentials() async {
    final username = await _storage.read(key: StorageKeys.biometricUsername);
    final password = await _storage.read(key: StorageKeys.biometricPassword);

    if (username == null || password == null) {
      return null;
    }

    return {'username': username, 'password': password};
  }

  /// Save last login credentials (separate from biometric)
  Future<void> saveLastLoginCredentials(
    String username,
    String password,
  ) async {
    await Future.wait([
      _storage.write(key: StorageKeys.lastUsername, value: username),
      _storage.write(key: StorageKeys.lastPassword, value: password),
    ]);
  }

  /// Get last login credentials
  Future<Map<String, String>?> getLastLoginCredentials() async {
    final username = await _storage.read(key: StorageKeys.lastUsername);
    final password = await _storage.read(key: StorageKeys.lastPassword);

    if (username == null || password == null) {
      return null;
    }

    return {'username': username, 'password': password};
  }

  /// Save biometric setup flag
  Future<void> setBiometricSetup(bool value) async {
    await _storage.write(
      key: StorageKeys.biometricSetup,
      value: value.toString(),
    );
  }

  /// Get biometric setup flag
  Future<bool> getBiometricSetup() async {
    final value = await _storage.read(key: StorageKeys.biometricSetup);
    return value == 'true';
  }

  /// Save biometric PIN securely
  Future<void> saveBiometricPin(String pin) async {
    await _storage.write(key: StorageKeys.biometricPin, value: pin);
  }

  /// Get biometric PIN
  Future<String?> getBiometricPin() async {
    return _storage.read(key: StorageKeys.biometricPin);
  }

  /// Clear biometric credentials
  Future<void> clearBiometricCredentials() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.biometricUsername),
      _storage.delete(key: StorageKeys.biometricPassword),
      _storage.delete(key: StorageKeys.biometricEnabled),
      _storage.delete(key: StorageKeys.biometricSetup),
      _storage.delete(key: StorageKeys.biometricPin),
    ]);
  }
}
