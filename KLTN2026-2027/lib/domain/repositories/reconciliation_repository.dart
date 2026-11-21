import '../entities/reconciliation/reconciliation_page.dart';
import '../entities/reconciliation/reconciliation_transaction.dart';

abstract class ReconciliationRepository {
  Future<ReconciliationPage> getReconciliations(
    String clubId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<ReconciliationTransaction> getReconciliationDetail(
    String clubId,
    String transactionId,
  );

  Future<ReconciliationTransaction> confirmManualReconciliation(
    String clubId,
    String transactionId, {
    required String feeId,
    required String reason,
  });
}
