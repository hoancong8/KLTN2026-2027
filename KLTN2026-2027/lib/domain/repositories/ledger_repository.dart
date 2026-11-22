import '../entities/ledger/ledger.dart';

abstract class LedgerRepository {
  Future<LedgerOverview> overview(String clubId, LedgerDates dates);
  Future<LedgerPage<LedgerTransaction>> transactions(
    String clubId,
    LedgerFilter filter,
    int page,
  );
  Future<LedgerPage<LedgerDebt>> debts(
    String clubId,
    LedgerFilter filter,
    int page,
  );
  Future<LedgerPage<LedgerCandidate>> candidates(
    String clubId,
    String month,
    String search,
    int page,
  );
  Future<LedgerInvoice> invoice(String clubId, String ledgerId);
  Future<void> issue(String clubId, String userId, String month);
  Future<void> collect(
    String clubId,
    String contributionId,
    String requestId,
    LedgerMoney amount,
  );
  Future<void> expense(String clubId, LedgerExpense expense);
}
