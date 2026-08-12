import 'package:kltn2026_2027/domain/entities/session_info.dart';

abstract class SessionRepository {
  Future<SessionInfo> getCurrentLoginInfo();
}
