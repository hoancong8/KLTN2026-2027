import 'package:kltn2026_2027/domain/entities/auth_token.dart';
import '../entities/auth_register_result.dart';

abstract class AuthRepository {
  Future<AuthToken> login({
    required String username,
    required String password,
  });

  Future<AuthRegisterResult> register({
    required String fullName,
    String? email,
    String? phoneNumber,
    required String password,
    int gender = 0,
    String skillLevel = 'NB',
  });

  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AuthToken> refreshToken(String refreshToken);
}
