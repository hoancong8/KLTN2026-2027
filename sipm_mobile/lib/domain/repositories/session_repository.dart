import 'package:sipm_mobile/domain/entities/session_info.dart';

abstract class SessionRepository {
  Future<SessionInfo> getCurrentLoginInfo();
}
