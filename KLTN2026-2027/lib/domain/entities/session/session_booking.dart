// lib/domain/entities/session/session_booking.dart

import '../../enums/session_enums.dart';

class SessionBooking {
  final String bookingId;
  final String sessionId;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String skillLevel;
  final BookingStatus status;
  final int queueOrder;
  final DateTime bookedAt;
  final DateTime? checkinAt;
  final String? recruitmentId;
  final int? gender;

  const SessionBooking({
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
    this.gender,
  });

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isWaiting => status == BookingStatus.waiting;
}
