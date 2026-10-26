// lib/data/dto/club/club_fee_rule_dto.dart

class ClubFeeRuleResponseDto {
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

  ClubFeeRuleResponseDto({
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

  factory ClubFeeRuleResponseDto.fromJson(Map<String, dynamic> json) {
    return ClubFeeRuleResponseDto(
      id: _parseString(json['id']),
      clubId: _parseString(json['clubId']),
      feeMode: _parseFeeMode(json['feeMode']),
      monthlyFee: _parseDouble(json['monthlyFee'], defaultValue: 0.0),
      dailyMemberFee: _parseDouble(json['dailyMemberFee'], defaultValue: 0.0),
      guestFee: _parseDouble(json['guestFee'], defaultValue: 0.0),
      femaleDiscountMonthly: _parseDouble(json['femaleDiscountMonthly'], defaultValue: 0.0),
      femaleDiscountDaily: _parseDouble(json['femaleDiscountDaily'], defaultValue: 0.0),
      femaleDiscountGuest: _parseDouble(json['femaleDiscountGuest'], defaultValue: 0.0),
      roundRule: _parseInt(json['roundRule'], defaultValue: 1000),
      appliedAt: _parseDateTime(json['appliedAt']),
    );
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static String _parseFeeMode(dynamic value) {
    if (value == null) return 'DYNAMIC';
    if (value is int) {
      return value == 1 ? 'FIXED' : 'DYNAMIC';
    }
    final str = value.toString().toUpperCase();
    if (str == 'FIXED' || str == '1') return 'FIXED';
    return 'DYNAMIC';
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class UpdateClubFeeRuleRequestDto {
  final int feeMode; // 0 = DYNAMIC, 1 = FIXED
  final double monthlyFee;
  final double dailyMemberFee;
  final double guestFee;
  final double femaleDiscountMonthly;
  final double femaleDiscountDaily;
  final double femaleDiscountGuest;
  final int roundRule;

  UpdateClubFeeRuleRequestDto({
    required this.feeMode,
    required this.monthlyFee,
    required this.dailyMemberFee,
    required this.guestFee,
    required this.femaleDiscountMonthly,
    required this.femaleDiscountDaily,
    required this.femaleDiscountGuest,
    required this.roundRule,
  });

  Map<String, dynamic> toJson() {
    return {
      'feeMode': feeMode,
      'monthlyFee': monthlyFee,
      'dailyMemberFee': dailyMemberFee,
      'guestFee': guestFee,
      'femaleDiscountMonthly': femaleDiscountMonthly,
      'femaleDiscountDaily': femaleDiscountDaily,
      'femaleDiscountGuest': femaleDiscountGuest,
      'roundRule': roundRule,
    };
  }
}
