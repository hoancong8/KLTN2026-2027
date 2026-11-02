// lib/domain/entities/club/club_fee_rule.dart

class ClubFeeRule {
  final String id;
  final String clubId;
  final String feeMode;
  final double monthlyFee;
  final double dailyMemberFee;
  final double guestFee;
  final double femaleDiscountMonthly;
  final double femaleDiscountDaily;
  final double femaleDiscountGuest;
  final int roundRule;
  final DateTime? appliedAt;

  const ClubFeeRule({
    required this.id,
    required this.clubId,
    required this.feeMode,
    required this.monthlyFee,
    required this.dailyMemberFee,
    required this.guestFee,
    required this.femaleDiscountMonthly,
    required this.femaleDiscountDaily,
    required this.femaleDiscountGuest,
    required this.roundRule,
    this.appliedAt,
  });

  bool get isDynamic => feeMode.toUpperCase() == 'DYNAMIC';
}
