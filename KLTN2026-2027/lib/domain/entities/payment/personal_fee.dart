import 'package:equatable/equatable.dart';

class PersonalFee extends Equatable {
  final String feeId;
  final String sessionId;
  final String groupId;
  final String groupName;
  final DateTime? sessionStart;
  final String publicationState;
  final num? amount;
  final String currency;
  final String paymentCode;
  final String paymentStatus;
  final String? paymentProgress;
  final String? paymentMethod;
  final DateTime? paymentRequestedAt;
  final DateTime? transferReportedAt;
  final PersonalFeeBreakdown? breakdown;
  final List<String> availableActions;
  final PaymentInstructions? paymentInstructions;
  final PaymentReceipt? receipt;

  const PersonalFee({
    required this.feeId,
    required this.sessionId,
    required this.groupId,
    required this.groupName,
    required this.sessionStart,
    required this.publicationState,
    required this.amount,
    required this.currency,
    required this.paymentCode,
    required this.paymentStatus,
    required this.paymentProgress,
    required this.paymentMethod,
    required this.paymentRequestedAt,
    required this.transferReportedAt,
    required this.breakdown,
    required this.availableActions,
    required this.paymentInstructions,
    required this.receipt,
  });

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';
  bool get isExempt => paymentStatus.toUpperCase() == 'EXEMPT';
  bool get canRequestCash =>
      availableActions.contains('CASH_REQUEST') &&
      paymentMethod?.toUpperCase() != 'CASH' &&
      paymentProgress?.toUpperCase() != 'CASH_CONFIRMATION_REQUESTED';
  bool get canRequestBankTransfer => availableActions.contains('BANK_TRANSFER');
  bool get canReportTransfer => availableActions.contains('TRANSFER_NOTICE');
  bool get hasValidQrAmount =>
      amount != null &&
      amount! > 0 &&
      amount! <= 9999999999999 &&
      amount! % 1 == 0;

  PersonalFee copyWith({
    PaymentInstructions? paymentInstructions,
    bool clearPaymentInstructions = false,
  }) => PersonalFee(
    feeId: feeId,
    sessionId: sessionId,
    groupId: groupId,
    groupName: groupName,
    sessionStart: sessionStart,
    publicationState: publicationState,
    amount: amount,
    currency: currency,
    paymentCode: paymentCode,
    paymentStatus: paymentStatus,
    paymentProgress: paymentProgress,
    paymentMethod: paymentMethod,
    paymentRequestedAt: paymentRequestedAt,
    transferReportedAt: transferReportedAt,
    breakdown: breakdown,
    availableActions: availableActions,
    paymentInstructions: clearPaymentInstructions
        ? null
        : paymentInstructions ?? this.paymentInstructions,
    receipt: receipt,
  );

  @override
  List<Object?> get props => [
    feeId,
    sessionId,
    groupId,
    groupName,
    sessionStart,
    publicationState,
    amount,
    currency,
    paymentCode,
    paymentStatus,
    paymentProgress,
    paymentMethod,
    paymentRequestedAt,
    transferReportedAt,
    breakdown,
    availableActions,
    paymentInstructions,
    receipt,
  ];
}

class PersonalFeeBreakdown extends Equatable {
  final num? courtShare;
  final num? shuttleShare;
  final num? extraShare;
  final num? discountApplied;
  final num? monthlyFundCovered;
  final num? baseAmount;
  final num? calculatedAmount;
  final num? roundingDelta;
  final num? adjustmentDelta;
  final String? adjustmentReason;

  const PersonalFeeBreakdown({
    required this.courtShare,
    required this.shuttleShare,
    required this.extraShare,
    required this.discountApplied,
    required this.monthlyFundCovered,
    required this.baseAmount,
    required this.calculatedAmount,
    required this.roundingDelta,
    required this.adjustmentDelta,
    required this.adjustmentReason,
  });

  @override
  List<Object?> get props => [
    courtShare,
    shuttleShare,
    extraShare,
    discountApplied,
    monthlyFundCovered,
    baseAmount,
    calculatedAmount,
    roundingDelta,
    adjustmentDelta,
    adjustmentReason,
  ];
}

class PaymentInstructions extends Equatable {
  final String payload;
  final PaymentBankSnapshot bank;
  final String imagePath;

  const PaymentInstructions({
    required this.payload,
    required this.bank,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [payload, bank, imagePath];
}

class PaymentBankSnapshot extends Equatable {
  final String? bankBin;
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  const PaymentBankSnapshot({
    required this.bankBin,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  @override
  List<Object?> get props => [bankBin, bankName, accountNumber, accountHolder];
}

class PaymentReceipt extends Equatable {
  final String receiptId;
  final num? amount;
  final String paymentCode;
  final DateTime? paidAt;
  final String? method;
  final String? cashCollectedBy;
  final bool metadataIncomplete;

  const PaymentReceipt({
    required this.receiptId,
    required this.amount,
    required this.paymentCode,
    required this.paidAt,
    required this.method,
    required this.cashCollectedBy,
    required this.metadataIncomplete,
  });

  @override
  List<Object?> get props => [
    receiptId,
    amount,
    paymentCode,
    paidAt,
    method,
    cashCollectedBy,
    metadataIncomplete,
  ];
}

class PersonalFeePage extends Equatable {
  final List<PersonalFee> items;
  final int total;
  final int page;
  final int pageSize;

  const PersonalFeePage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [items, total, page, pageSize];
}

class PaymentBankAccount extends Equatable {
  final String? bankBin;
  final String bankName;
  final String accountNumber;
  final String accountHolder;

  const PaymentBankAccount({
    required this.bankBin,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
  });

  @override
  List<Object?> get props => [bankBin, bankName, accountNumber, accountHolder];
}
