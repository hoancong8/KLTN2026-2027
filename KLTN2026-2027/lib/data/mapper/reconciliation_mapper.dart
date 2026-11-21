import '../../domain/entities/reconciliation/reconciliation_page.dart';
import '../../domain/entities/reconciliation/reconciliation_transaction.dart';
import '../dto/reconciliation/reconciliation_dto.dart';

extension ReconciliationTransactionDtoMapper on ReconciliationTransactionDto {
  ReconciliationTransaction toEntity() {
    return ReconciliationTransaction(
      transactionId: transactionId,
      providerTransactionId: providerTransactionId,
      bankAccountId: bankAccountId,
      feeId: feeId,
      referenceCode: referenceCode,
      amountReceived: amountReceived,
      transferContent: transferContent,
      transactionTime: transactionTime,
      status: status,
      reasonCode: reasonCode,
      reconciledBy: reconciledBy,
      reconciledAt: reconciledAt,
      note: note,
    );
  }
}

extension ReconciliationPageDtoMapper on ReconciliationPageDto {
  ReconciliationPage toEntity() {
    return ReconciliationPage(
      items: items.map((e) => e.toEntity()).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }
}
