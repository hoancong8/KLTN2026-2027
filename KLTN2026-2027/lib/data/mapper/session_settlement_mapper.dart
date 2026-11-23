// lib/data/mapper/session_settlement_mapper.dart

import '../../domain/entities/session/session_settlement.dart';
import '../../domain/utils/gender_helper.dart';
import '../dto/session/session_settlement_dto.dart';
import 'payment_mapper.dart';

extension MemberSettlementFeeDtoMapper on MemberSettlementFeeDto {
  MemberSettlementFee toEntity() {
    final isFem = GenderHelper.isFemale(genderString: gender, fullName: fullName);
    return MemberSettlementFee(
      feeId: feeId,
      userId: userId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      roleName: roleName,
      gender: isFem ? 'FEMALE' : (gender.isNotEmpty ? gender : 'MALE'),
      baseFee: baseFee,
      discount: discount,
      finalFee: finalFee,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      paymentProgress: paymentProgress,
      vietQrUrl: vietQrUrl,
      paymentCode: paymentCode,
      paidAmount: paidAmount,
    );
  }
}

extension SessionSettlementDtoMapper on SessionSettlementDto {
  SessionSettlement toEntity() {
    return SessionSettlement(
      sessionId: sessionId,
      shuttlecockUsed: shuttlecockUsed,
      shuttlecockPrice: shuttlecockPrice,
      courtFee: courtFee,
      extraFee: extraFee,
      totalCost: totalCost,
      totalCollected: totalCollected,
      memberFees: memberFees.map((f) => f.toEntity()).toList(),
      isSettled: isSettled,
      bankAccount: bankAccount != null ? PaymentMapper.toBankAccount(bankAccount!) : null,
    );
  }
}
