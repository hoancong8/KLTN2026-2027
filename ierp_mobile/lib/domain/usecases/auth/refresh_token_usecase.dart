import '../../entities/auth_token.dart';
import '../../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthToken> execute(AuthToken currentToken) async {
    AuthToken apiResult = await repository.refreshToken(currentToken.refreshToken);
    AuthToken result = apiResult.copyWith(
      accessToken: apiResult.accessToken,
      refreshToken: currentToken.refreshToken,
      twoFactorRememberClientToken: currentToken.twoFactorRememberClientToken,
      userId: currentToken.userId,
    );
    return result;
  }
}
