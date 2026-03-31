import '../../domain/entities/auth_token.dart';
import '../dto/auth/login_response_dto.dart';

class AuthMapper {
  static AuthToken toEntity(LoginResponseDto dto) {
    return AuthToken(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      twoFactorRememberClientToken: dto.twoFactorRememberClientToken,
      userId: dto.userId,
    );
  }
}
