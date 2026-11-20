import '../../domain/entities/reconciliation/reconciliation_page.dart';
import '../../domain/entities/reconciliation/reconciliation_transaction.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../datasource/remote/abstract/reconciliation_remote_datasource.dart';
import '../mapper/reconciliation_mapper.dart';

class ReconciliationRepositoryImpl implements ReconciliationRepository {
  final ReconciliationRemoteDatasource remoteDatasource;

  ReconciliationRepositoryImpl(this.remoteDatasource);

  @override
  Future<ReconciliationPage> getReconciliations(
    String clubId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dto = await remoteDatasource.getReconciliations(
      clubId,
      status: status,
      page: page,
      pageSize: pageSize,
    );
    return dto.toEntity();
  }

  @override
  Future<ReconciliationTransaction> getReconciliationDetail(
    String clubId,
    String transactionId,
  ) async {
    final dto = await remoteDatasource.getReconciliationDetail(
      clubId,
      transactionId,
    );
    return dto.toEntity();
  }

  @override
  Future<ReconciliationTransaction> confirmManualReconciliation(
    String clubId,
    String transactionId, {
    required String feeId,
    required String reason,
  }) async {
    final dto = await remoteDatasource.confirmManualReconciliation(
      clubId,
      transactionId,
      feeId: feeId,
      reason: reason,
    );
    return dto.toEntity();
  }
}
