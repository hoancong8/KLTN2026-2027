import 'package:ierp_mobile/domain/entities/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<void> sendOtp({
    required String provider,
  });

  Future<AuthToken> loginWithOtp({
    required String username,
    required String password,
    required String code,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AuthToken> refreshToken(String refreshToken);
}