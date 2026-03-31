import '../../data/datasource/remote/abstract/session_remote_datasource.dart';
import '../../data/dto/session/session_info_dto.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDatasource remoteDatasource;

  SessionRepositoryImpl(this.remoteDatasource);

  @override
  Future<SessionInfoDto> getCurrentLoginInfo() {
    return remoteDatasource.getCurrentLoginInfo();
  }
}
