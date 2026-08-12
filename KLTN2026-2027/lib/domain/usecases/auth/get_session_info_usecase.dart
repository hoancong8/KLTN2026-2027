import '../../entities/session_info.dart';
import '../../repositories/session_repository.dart';

class GetSessionInfoUseCase {
  final SessionRepository repository;

  GetSessionInfoUseCase(this.repository);

  Future<SessionInfo> execute() {
    return repository.getCurrentLoginInfo();
  }
}
