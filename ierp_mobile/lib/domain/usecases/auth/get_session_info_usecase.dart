import '../../../data/dto/session/session_info_dto.dart';
import '../../repositories/session_repository.dart';

class GetSessionInfoUseCase {
  final SessionRepository repository;

  GetSessionInfoUseCase(this.repository);

  Future<SessionInfoDto> execute() {
    return repository.getCurrentLoginInfo();
  }
}
