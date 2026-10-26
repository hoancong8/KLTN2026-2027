// lib/data/dto/session/my_booking_item_dto.dart

class MyBookingItemDto {
  final String bookingId;
  final String sessionId;
  final String sessionTitle;
  final String clubId;
  final String clubName;
  final String? clubAvatarUrl;
  final String startTime;
  final String endTime;
  final String courtLocation;
  final dynamic sessionStatus;
  final dynamic bookingStatus;
  final int queueOrder;
  final double feePerMember;
  final String bookedAt;
  final String? checkinAt;
  final bool isGuest;
  final String memberType;

  MyBookingItemDto({
    required this.bookingId,
    required this.sessionId,
    required this.sessionTitle,
    required this.clubId,
    required this.clubName,
    this.clubAvatarUrl,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    required this.sessionStatus,
    required this.bookingStatus,
    required this.queueOrder,
    required this.feePerMember,
    required this.bookedAt,
    this.checkinAt,
    this.isGuest = false,
    this.memberType = 'MONTHLY',
  });

  factory MyBookingItemDto.fromJson(Map<String, dynamic> json) {
    return MyBookingItemDto(
      bookingId: json['bookingId']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      sessionTitle: json['sessionTitle']?.toString() ?? 'Buổi chơi cầu lông',
      clubId: json['clubId']?.toString() ?? '',
      clubName: json['clubName']?.toString() ?? 'CLB Cầu lông',
      clubAvatarUrl: json['clubAvatarUrl']?.toString(),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      courtLocation: json['courtLocation']?.toString() ?? '',
      sessionStatus: json['sessionStatus'] ?? 1,
      bookingStatus: json['bookingStatus'] ?? 1,
      queueOrder: _parseInt(json['queueOrder']),
      feePerMember: _parseDouble(json['feePerMember']),
      bookedAt: json['bookedAt']?.toString() ?? '',
      checkinAt: json['checkinAt']?.toString(),
      isGuest: _parseBool(json['isGuest'] ?? json['idRecruitment'] != null || json['recruitmentId'] != null),
      memberType: json['memberType']?.toString() ?? 'MONTHLY',
    );
  }

  static bool _parseBool(dynamic val) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.toLowerCase().trim();
      return s == 'true' || s == '1';
    }
    return false;
  }

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}
