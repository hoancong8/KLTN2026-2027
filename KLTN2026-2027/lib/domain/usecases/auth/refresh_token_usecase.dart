import '../../entities/auth_token.dart';
import '../../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthToken> execute(AuthToken currentToken) async {
    AuthToken apiResult = await repository.refreshToken(currentToken.refreshToken);
    return apiResult.copyWith(
      accessToken: apiResult.accessToken,
      refreshToken: currentToken.refreshToken,
      userId: currentToken.userId,
    );
  }
}
