import '../../entities/reconciliation/reconciliation_page.dart';
import '../../entities/reconciliation/reconciliation_transaction.dart';
import '../../repositories/reconciliation_repository.dart';

class GetReconciliationsUseCase {
  final ReconciliationRepository repository;
  const GetReconciliationsUseCase(this.repository);

  Future<ReconciliationPage> execute(
    String clubId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      repository.getReconciliations(
        clubId,
        status: status,
        page: page,
        pageSize: pageSize,
      );
}

class GetReconciliationDetailUseCase {
  final ReconciliationRepository repository;
  const GetReconciliationDetailUseCase(this.repository);

  Future<ReconciliationTransaction> execute(
    String clubId,
    String transactionId,
  ) =>
      repository.getReconciliationDetail(clubId, transactionId);
}

class ConfirmManualReconciliationUseCase {
  final ReconciliationRepository repository;
  const ConfirmManualReconciliationUseCase(this.repository);

  Future<ReconciliationTransaction> execute(
    String clubId,
    String transactionId, {
    required String feeId,
    required String reason,
  }) =>
      repository.confirmManualReconciliation(
        clubId,
        transactionId,
        feeId: feeId,
        reason: reason,
      );
}
