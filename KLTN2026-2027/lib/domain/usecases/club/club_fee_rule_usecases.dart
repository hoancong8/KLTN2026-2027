// lib/domain/usecases/club/club_fee_rule_usecases.dart

import '../../entities/club/club_fee_rule.dart';
import '../../repositories/club_repository.dart';

class GetClubFeeRuleUseCase {
  final ClubRepository repository;

  GetClubFeeRuleUseCase(this.repository);

  Future<ClubFeeRule> execute(String clubId) {
    return repository.getClubFeeRule(clubId);
  }
}

class UpdateClubFeeRuleUseCase {
  final ClubRepository repository;

  UpdateClubFeeRuleUseCase(this.repository);

  Future<ClubFeeRule> execute(
    String clubId, {
    required int feeMode,
    required double monthlyFee,
    required double dailyMemberFee,
    required double guestFee,
    required double femaleDiscountMonthly,
    required double femaleDiscountDaily,
    required double femaleDiscountGuest,
    required int roundRule,
  }) {
    return repository.updateClubFeeRule(
      clubId,
      feeMode: feeMode,
      monthlyFee: monthlyFee,
      dailyMemberFee: dailyMemberFee,
      guestFee: guestFee,
      femaleDiscountMonthly: femaleDiscountMonthly,
      femaleDiscountDaily: femaleDiscountDaily,
      femaleDiscountGuest: femaleDiscountGuest,
      roundRule: roundRule,
    );
  }
}
