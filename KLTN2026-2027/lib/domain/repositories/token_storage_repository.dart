import 'package:kltn2026_2027/domain/entities/auth_token.dart';

abstract class TokenStorageRepository {
  Future<void> saveAuthToken(AuthToken token);
  Future<AuthToken?> getAuthToken();
  Future<void> clearAuthToken();
  Future<void> setRememberMe(bool value);
  Future<bool> getRememberMe();
  Future<bool> isLoggedIn();
  Future<void> saveLastLoginCredentials(String username, String password);
}
