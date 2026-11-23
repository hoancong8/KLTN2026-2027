// lib/domain/entities/session/session_settlement.dart

import '../payment/personal_fee.dart';

class MemberSettlementFee {
  final String feeId;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String roleName; // 'MEMBER_MONTHLY' | 'MEMBER_DAILY' | 'GUEST'
  final String gender; // 'MALE' | 'FEMALE'
  final int baseFee;
  final int discount;
  final int finalFee;
  final String paymentStatus; // 'PENDING' | 'PAID' | 'UNPAID' | 'EXEMPT'
  final String? paymentMethod;
  final String? paymentProgress;
  final String vietQrUrl;
  final String paymentCode;
  final int paidAmount;

  const MemberSettlementFee({
    required this.feeId,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.roleName,
    required this.gender,
    required this.baseFee,
    required this.discount,
    required this.finalFee,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentProgress,
    required this.vietQrUrl,
    required this.paymentCode,
    this.paidAmount = 0,
  });

  bool get isPaid => paymentStatus == 'PAID';
  bool get isExempt => paymentStatus == 'EXEMPT';
  bool get isCashRequested =>
      paymentProgress == 'CASH_CONFIRMATION_REQUESTED' ||
      (paymentMethod == 'CASH' && !isPaid);
  bool get isPendingCashConfirmation => !isPaid && isCashRequested;
  int get remainingFee => isPaid ? 0 : (finalFee - paidAmount).clamp(0, finalFee);
  bool get isPartiallyPaid => !isPaid && paidAmount > 0 && remainingFee > 0;
  bool get isCashEligible =>
      !isPaid &&
      !isExempt &&
      (paymentMethod == null || paymentMethod == 'CASH');

  MemberSettlementFee copyWith({
    String? feeId,
    String? userId,
    String? fullName,
    String? avatarUrl,
    String? roleName,
    String? gender,
    int? baseFee,
    int? discount,
    int? finalFee,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentProgress,
    String? vietQrUrl,
    String? paymentCode,
    int? paidAmount,
  }) {
    return MemberSettlementFee(
      feeId: feeId ?? this.feeId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleName: roleName ?? this.roleName,
      gender: gender ?? this.gender,
      baseFee: baseFee ?? this.baseFee,
      discount: discount ?? this.discount,
      finalFee: finalFee ?? this.finalFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProgress: paymentProgress ?? this.paymentProgress,
      vietQrUrl: vietQrUrl ?? this.vietQrUrl,
      paymentCode: paymentCode ?? this.paymentCode,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}

class SessionSettlement {
  final String sessionId;
  final int shuttlecockUsed; // Số quả cầu đã bóc mới (FR18)
  final int shuttlecockPrice;
  final int courtFee;
  final int extraFee; // Phụ phí nước uống, phát sinh
  final int totalCost;
  final int totalCollected;
  final int totalReceivable;
  final int monthlyFundCovered;
  final List<MemberSettlementFee> memberFees;
  final bool isSettled;
  final PaymentBankAccount? bankAccount;

  const SessionSettlement({
    required this.sessionId,
    required this.shuttlecockUsed,
    required this.shuttlecockPrice,
    required this.courtFee,
    required this.extraFee,
    required this.totalCost,
    required this.totalCollected,
    this.totalReceivable = 0,
    this.monthlyFundCovered = 0,
    required this.memberFees,
    required this.isSettled,
    this.bankAccount,
  });
}
