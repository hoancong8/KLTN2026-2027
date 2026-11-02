// lib/domain/entities/session/session_settlement.dart

class MemberSettlementFee {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String roleName; // 'MEMBER_MONTHLY' | 'MEMBER_DAILY' | 'GUEST'
  final String gender; // 'MALE' | 'FEMALE'
  final int baseFee;
  final int discount;
  final int finalFee;
  final String paymentStatus; // 'PENDING' | 'PAID'
  final String vietQrUrl;
  final String paymentCode;

  const MemberSettlementFee({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.roleName,
    required this.gender,
    required this.baseFee,
    required this.discount,
    required this.finalFee,
    required this.paymentStatus,
    required this.vietQrUrl,
    required this.paymentCode,
  });

  bool get isPaid => paymentStatus == 'PAID';

  MemberSettlementFee copyWith({
    String? userId,
    String? fullName,
    String? avatarUrl,
    String? roleName,
    String? gender,
    int? baseFee,
    int? discount,
    int? finalFee,
    String? paymentStatus,
    String? vietQrUrl,
    String? paymentCode,
  }) {
    return MemberSettlementFee(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleName: roleName ?? this.roleName,
      gender: gender ?? this.gender,
      baseFee: baseFee ?? this.baseFee,
      discount: discount ?? this.discount,
      finalFee: finalFee ?? this.finalFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      vietQrUrl: vietQrUrl ?? this.vietQrUrl,
      paymentCode: paymentCode ?? this.paymentCode,
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
  final List<MemberSettlementFee> memberFees;
  final bool isSettled;

  const SessionSettlement({
    required this.sessionId,
    required this.shuttlecockUsed,
    required this.shuttlecockPrice,
    required this.courtFee,
    required this.extraFee,
    required this.totalCost,
    required this.totalCollected,
    required this.memberFees,
    required this.isSettled,
  });
}
