import '../../data/dto/session/session_info_dto.dart';

abstract class SessionRepository {
  Future<SessionInfoDto> getCurrentLoginInfo();
}
