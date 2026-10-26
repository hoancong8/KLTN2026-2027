// lib/data/dto/session/session_settlement_dto.dart

class MemberSettlementFeeDto {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String roleName;
  final String gender;
  final int baseFee;
  final int discount;
  final int finalFee;
  final String paymentStatus;
  final String vietQrUrl;
  final String paymentCode;

  const MemberSettlementFeeDto({
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

  factory MemberSettlementFeeDto.fromJson(Map<String, dynamic> json) {
    return MemberSettlementFeeDto(
      userId: _parseString(json['userId'] ?? json['UserId']),
      fullName: _parseString(json['fullName'] ?? json['FullName']),
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'] as String?,
      roleName: _parseString(json['roleName'] ?? json['RoleName']),
      gender: _parseString(json['gender'] ?? json['Gender']),
      baseFee: _parseInt(json['baseFee'] ?? json['BaseFee']),
      discount: _parseInt(json['discount'] ?? json['Discount']),
      finalFee: _parseInt(json['finalFee'] ?? json['FinalFee']),
      paymentStatus: _parseString(json['paymentStatus'] ?? json['PaymentStatus']),
      vietQrUrl: _parseString(json['vietQrUrl'] ?? json['VietQrUrl']),
      paymentCode: _parseString(json['paymentCode'] ?? json['PaymentCode']),
    );
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
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

    return SessionSettlementDto(
      sessionId: _parseString(json['sessionId'] ?? json['SessionId']),
      shuttlecockUsed: _parseInt(json['shuttlecockUsed'] ?? json['ShuttlecockUsed']),
      shuttlecockPrice: _parseInt(json['shuttlecockPrice'] ?? json['ShuttlecockPrice']),
      courtFee: _parseInt(json['courtFee'] ?? json['CourtFee']),
      extraFee: _parseInt(json['extraFee'] ?? json['ExtraFee']),
      totalCost: _parseInt(json['totalCost'] ?? json['TotalCost']),
      totalCollected: _parseInt(json['totalCollected'] ?? json['TotalCollected']),
      memberFees: fees,
      isSettled: _parseBool(json['isSettled'] ?? json['IsSettled']),
    );
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';
  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    if (v is num) return v == 1;
    return false;
  }
}
