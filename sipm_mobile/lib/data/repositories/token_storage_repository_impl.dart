import 'package:sipm_mobile/app/services/secure_storage_service.dart';
import 'package:sipm_mobile/domain/entities/auth_token.dart';
import 'package:sipm_mobile/domain/repositories/token_storage_repository.dart';

class TokenStorageRepositoryImpl implements TokenStorageRepository {
  final SecureStorageService _secureStorage;

  TokenStorageRepositoryImpl(this._secureStorage);

  @override
  Future<void> saveAuthToken(AuthToken token) async {
    await _secureStorage.saveAuthToken(token);
  }

  @override
  Future<AuthToken?> getAuthToken() async {
    return await _secureStorage.getAuthToken();
  }

  @override
  Future<void> clearAuthToken() async {
    await _secureStorage.clearAuthToken();
  }

  @override
  Future<void> setRememberMe(bool value) async {
    await _secureStorage.setRememberMe(value);
  }

  @override
  Future<bool> getRememberMe() async {
    return await _secureStorage.getRememberMe();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _secureStorage.isLoggedIn();
  }

  @override
  Future<void> saveTenantId(int tenantId) async {
    await _secureStorage.saveTenantId(tenantId);
  }

  @override
  Future<int?> getTenantId() async {
    return await _secureStorage.getTenantId();
  }

  @override
  Future<void> saveEmployeeId(int employeeId) async {
    await _secureStorage.saveEmployeeId(employeeId);
  }

  @override
  Future<int?> getEmployeeId() async {
    return await _secureStorage.getEmployeeId();
  }

  @override
  Future<void> saveLastLoginCredentials(String username, String password) async {
    await _secureStorage.saveLastLoginCredentials(username, password);
  }
}
