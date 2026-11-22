import '../../entities/ledger/ledger.dart';
import '../../repositories/ledger_repository.dart';

class GetLedgerOverviewUseCase {
  final LedgerRepository _repository;
  const GetLedgerOverviewUseCase(this._repository);

  Future<LedgerOverview> execute(String clubId, LedgerDates dates) =>
      _repository.overview(clubId, dates);
}

class ListLedgerTransactionsUseCase {
  final LedgerRepository _repository;
  const ListLedgerTransactionsUseCase(this._repository);

  Future<LedgerPage<LedgerTransaction>> execute(
    String clubId,
    LedgerFilter filter,
    int page,
  ) => _repository.transactions(clubId, filter, page);
}

class ListLedgerDebtsUseCase {
  final LedgerRepository _repository;
  const ListLedgerDebtsUseCase(this._repository);

  Future<LedgerPage<LedgerDebt>> execute(
    String clubId,
    LedgerFilter filter,
    int page,
  ) => _repository.debts(clubId, filter, page);
}

class ListLedgerCandidatesUseCase {
  final LedgerRepository _repository;
  const ListLedgerCandidatesUseCase(this._repository);

  Future<LedgerPage<LedgerCandidate>> execute(
    String clubId,
    String month,
    String search,
    int page,
  ) => _repository.candidates(clubId, month, search, page);
}

class DownloadLedgerInvoiceUseCase {
  final LedgerRepository _repository;
  const DownloadLedgerInvoiceUseCase(this._repository);

  Future<LedgerInvoice> execute(String clubId, String ledgerId) =>
      _repository.invoice(clubId, ledgerId);
}

class IssueLedgerContributionUseCase {
  final LedgerRepository _repository;
  const IssueLedgerContributionUseCase(this._repository);

  Future<void> execute(String clubId, String userId, String month) =>
      _repository.issue(clubId, userId, month);
}

class CollectLedgerContributionUseCase {
  final LedgerRepository _repository;
  const CollectLedgerContributionUseCase(this._repository);

  Future<void> execute(
    String clubId,
    String contributionId,
    String requestId,
    LedgerMoney amount,
  ) => _repository.collect(clubId, contributionId, requestId, amount);
}

class CreateLedgerExpenseUseCase {
  final LedgerRepository _repository;
  const CreateLedgerExpenseUseCase(this._repository);

  Future<void> execute(String clubId, LedgerExpense expense) =>
      _repository.expense(clubId, expense);
}
