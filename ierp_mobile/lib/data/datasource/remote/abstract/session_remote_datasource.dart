import '../../../dto/session/session_info_dto.dart';

abstract class SessionRemoteDatasource {
  Future<SessionInfoDto> getCurrentLoginInfo();
}
