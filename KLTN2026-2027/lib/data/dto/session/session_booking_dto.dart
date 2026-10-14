// lib/data/dto/session/session_booking_dto.dart

class SessionBookingDto {
  final String bookingId;
  final String sessionId;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String skillLevel;
  final String status;
  final int queueOrder;
  final String bookedAt;
  final String? checkinAt;
  final String? recruitmentId;

  SessionBookingDto({
    required this.bookingId,
    required this.sessionId,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    required this.skillLevel,
    required this.status,
    required this.queueOrder,
    required this.bookedAt,
    this.checkinAt,
    this.recruitmentId,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory SessionBookingDto.fromJson(Map<String, dynamic> json) {
    return SessionBookingDto(
      bookingId: json['bookingId']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      skillLevel: json['skillLevel']?.toString() ?? '1',
      status: json['status']?.toString() ?? '1',
      queueOrder: _parseInt(json['queueOrder']),
      bookedAt: json['bookedAt']?.toString() ?? '',
      checkinAt: json['checkinAt']?.toString(),
      recruitmentId: json['recruitmentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'sessionId': sessionId,
    'userId': userId,
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'phoneNumber': phoneNumber,
    'skillLevel': skillLevel,
    'status': status,
    'queueOrder': queueOrder,
    'bookedAt': bookedAt,
    'checkinAt': checkinAt,
    'recruitmentId': recruitmentId,
  };
}
