// lib/data/mapper/club_fee_rule_mapper.dart

import '../../domain/entities/club/club_fee_rule.dart';
import '../dto/club/club_fee_rule_dto.dart';

class ClubFeeRuleMapper {
  static ClubFeeRule toEntity(ClubFeeRuleResponseDto dto) {
    return ClubFeeRule(
      id: dto.id,
      clubId: dto.clubId,
      feeMode: dto.feeMode,
      monthlyFee: dto.monthlyFee,
      dailyMemberFee: dto.dailyMemberFee,
      guestFee: dto.guestFee,
      femaleDiscountMonthly: dto.femaleDiscountMonthly,
      femaleDiscountDaily: dto.femaleDiscountDaily,
      femaleDiscountGuest: dto.femaleDiscountGuest,
      roundRule: dto.roundRule,
      appliedAt: dto.appliedAt,
    );
  }
}
