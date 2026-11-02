// lib/data/mapper/session_settlement_mapper.dart

import '../../domain/entities/session/session_settlement.dart';
import '../dto/session/session_settlement_dto.dart';

extension MemberSettlementFeeDtoMapper on MemberSettlementFeeDto {
  MemberSettlementFee toEntity() {
    return MemberSettlementFee(
      userId: userId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      roleName: roleName,
      gender: gender,
      baseFee: baseFee,
      discount: discount,
      finalFee: finalFee,
      paymentStatus: paymentStatus,
      vietQrUrl: vietQrUrl,
      paymentCode: paymentCode,
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
    );
  }
}
