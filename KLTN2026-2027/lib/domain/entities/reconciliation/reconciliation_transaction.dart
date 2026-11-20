import 'package:equatable/equatable.dart';

class ReconciliationTransaction extends Equatable {
  final String transactionId;
  final int? providerTransactionId;
  final String? bankAccountId;
  final String? feeId;
  final String? referenceCode;
  final num amountReceived;
  final String transferContent;
  final DateTime transactionTime;
  final String status;
  final String? reasonCode;
  final String? reconciledBy;
  final DateTime? reconciledAt;
  final String? note;

  const ReconciliationTransaction({
    required this.transactionId,
    this.providerTransactionId,
    this.bankAccountId,
    this.feeId,
    this.referenceCode,
    required this.amountReceived,
    required this.transferContent,
    required this.transactionTime,
    required this.status,
    this.reasonCode,
    this.reconciledBy,
    this.reconciledAt,
    this.note,
  });

  bool get isMatched => status == 'MATCHED';
  bool get isManualCheck => status == 'MANUAL_CHECK';

  ReconciliationTransaction copyWith({
    String? transactionId,
    int? providerTransactionId,
    String? bankAccountId,
    String? feeId,
    String? referenceCode,
    num? amountReceived,
    String? transferContent,
    DateTime? transactionTime,
    String? status,
    String? reasonCode,
    String? reconciledBy,
    DateTime? reconciledAt,
    String? note,
  }) {
    return ReconciliationTransaction(
      transactionId: transactionId ?? this.transactionId,
      providerTransactionId: providerTransactionId ?? this.providerTransactionId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      feeId: feeId ?? this.feeId,
      referenceCode: referenceCode ?? this.referenceCode,
      amountReceived: amountReceived ?? this.amountReceived,
      transferContent: transferContent ?? this.transferContent,
      transactionTime: transactionTime ?? this.transactionTime,
      status: status ?? this.status,
      reasonCode: reasonCode ?? this.reasonCode,
      reconciledBy: reconciledBy ?? this.reconciledBy,
      reconciledAt: reconciledAt ?? this.reconciledAt,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        providerTransactionId,
        bankAccountId,
        feeId,
        referenceCode,
        amountReceived,
        transferContent,
        transactionTime,
        status,
        reasonCode,
        reconciledBy,
        reconciledAt,
        note,
      ];
}
