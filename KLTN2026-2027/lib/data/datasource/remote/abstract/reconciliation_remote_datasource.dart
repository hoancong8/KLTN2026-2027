import '../../../dto/reconciliation/reconciliation_dto.dart';

abstract class ReconciliationRemoteDatasource {
  Future<ReconciliationPageDto> getReconciliations(
    String clubId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<ReconciliationTransactionDto> getReconciliationDetail(
    String clubId,
    String transactionId,
  );

  Future<ReconciliationTransactionDto> confirmManualReconciliation(
    String clubId,
    String transactionId, {
    required String feeId,
    required String reason,
  });
}
