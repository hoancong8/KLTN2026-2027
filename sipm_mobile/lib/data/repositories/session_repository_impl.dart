import '../../domain/entities/session_info.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasource/remote/abstract/session_remote_datasource.dart';
import '../mapper/session_mapper.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDatasource remoteDatasource;

  SessionRepositoryImpl(this.remoteDatasource);

  @override
  Future<SessionInfo> getCurrentLoginInfo() async {
    final dto = await remoteDatasource.getCurrentLoginInfo();
    return SessionMapper.toEntity(dto);
  }
}