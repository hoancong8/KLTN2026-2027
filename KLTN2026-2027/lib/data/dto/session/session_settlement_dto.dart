// lib/data/dto/session/session_settlement_dto.dart

import '../payment/payment_dto.dart';

class MemberSettlementFeeDto {
  final String feeId;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String roleName;
  final String gender;
  final int baseFee;
  final int discount;
  final int finalFee;
  final String paymentStatus;
  final String? paymentMethod;
  final String? paymentProgress;
  final String vietQrUrl;
  final String paymentCode;
  final int paidAmount;

  const MemberSettlementFeeDto({
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

  factory MemberSettlementFeeDto.fromJson(Map<String, dynamic> json) {
    final status = _parseString(json['paymentStatus'] ?? json['PaymentStatus']);
    final finalFee = _parseInt(json['finalFee'] ?? json['FinalFee']);
    final paid = _parseInt(
      json['paidAmount'] ??
          json['PaidAmount'] ??
          (status == 'PAID' ? finalFee : 0),
    );
    return MemberSettlementFeeDto(
      feeId: _parseString(json['feeId'] ?? json['FeeId']),
      userId: _parseString(json['userId'] ?? json['UserId']),
      fullName: _parseString(json['fullName'] ?? json['FullName']),
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'] as String?,
      roleName: _parseString(json['roleName'] ?? json['RoleName'] ?? json['priceType'] ?? json['PriceType']),
      gender: _parseString(json['gender'] ?? json['Gender']),
      baseFee: _parseInt(json['baseFee'] ?? json['BaseFee'] ?? json['finalFee'] ?? json['FinalFee']),
      discount: _parseInt(json['discount'] ?? json['Discount']),
      finalFee: finalFee,
      paymentStatus: status,
      paymentMethod: _parseNullableString(json['paymentMethod'] ?? json['PaymentMethod']),
      paymentProgress: _parseNullableString(json['paymentProgress'] ?? json['PaymentProgress']),
      vietQrUrl: _parseString(json['vietQrUrl'] ?? json['VietQrUrl'] ?? json['qrCodePayload'] ?? json['QrCodePayload']),
      paymentCode: _parseString(json['paymentCode'] ?? json['PaymentCode']),
      paidAmount: paid,
    );
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';
  static String? _parseNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
  static int _parseInt(dynamic v, {int defaultValue = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }
}

class SessionSettlementDto {
  final String sessionId;
  final int shuttlecockUsed;
  final int shuttlecockPrice;
  final int courtFee;
  final int extraFee;
  final int totalCost;
  final int totalCollected;
  final List<MemberSettlementFeeDto> memberFees;
  final bool isSettled;
  final PaymentBankAccountDto? bankAccount;

  const SessionSettlementDto({
    required this.sessionId,
    required this.shuttlecockUsed,
    required this.shuttlecockPrice,
    required this.courtFee,
    required this.extraFee,
    required this.totalCost,
    required this.totalCollected,
    required this.memberFees,
    required this.isSettled,
    this.bankAccount,
  });

  factory SessionSettlementDto.fromJson(Map<String, dynamic> json) {
    final rawFees = json['memberFees'] ?? json['MemberFees'];
    final fees = <MemberSettlementFeeDto>[];
    if (rawFees is List) {
      for (final item in rawFees) {
        if (item is Map<String, dynamic>) {
          fees.add(MemberSettlementFeeDto.fromJson(item));
        }
      }
    }

    final bankRaw = json['bankAccount'] ?? json['BankAccount'];
    PaymentBankAccountDto? bankAccount;
    if (bankRaw is Map<String, dynamic>) {
      try {
        bankAccount = PaymentBankAccountDto.fromJson(bankRaw);
      } catch (_) {}
    }

    return SessionSettlementDto(
      sessionId: _parseString(json['sessionId'] ?? json['SessionId']),
      shuttlecockUsed: _parseInt(json['shuttlecockUsed'] ?? json['ShuttlecockUsed']),
      shuttlecockPrice: _parseInt(json['shuttlecockPrice'] ?? json['ShuttlecockPrice'], defaultValue: 25000),
      courtFee: _parseInt(json['courtFee'] ?? json['CourtFee'] ?? json['courtRentalCost'] ?? json['CourtRentalCost']),
      extraFee: _parseInt(json['extraFee'] ?? json['ExtraFee'] ?? json['extraExpense'] ?? json['ExtraExpense']),
      totalCost: _parseInt(json['totalCost'] ?? json['TotalCost']),
      totalCollected: _parseInt(json['totalCollected'] ?? json['TotalCollected']),
      memberFees: fees,
      isSettled: _parseBool(json['isSettled'] ?? json['IsSettled']) ||
          (json['state'] ?? json['State'])?.toString().toUpperCase() == 'PUBLISHED' ||
          json['publishedAt'] != null ||
          json['PublishedAt'] != null,
      bankAccount: bankAccount,
    );
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';
  static int _parseInt(dynamic v, {int defaultValue = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    if (v is num) return v == 1;
    return false;
  }
}
