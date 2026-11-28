import '../entities/payment/session_advance.dart';

abstract interface class SessionAdvanceRepository {
  Future<SessionAdvance?> quote(String sessionId);
  Future<SessionAdvance> prepare(String sessionId);
  Future<SessionAdvance> report(String sessionId);
  Future<SessionAdvance> saveAccount(
    String sessionId,
    String bank,
    String account,
    String holder,
  );
  Future<List<SessionAdvance>> listMine();
  Future<List<SessionAdvance>> listClub(String groupId);
  Future<SessionAdvance> review(
    String groupId,
    String advanceId,
    String? transactionId,
  );
  Future<SessionAdvance> claim(String groupId, String advanceId);
  Future<SessionAdvance> refund(
    String groupId,
    String advanceId,
    num amount,
    String reference,
    String evidence,
  );
}
