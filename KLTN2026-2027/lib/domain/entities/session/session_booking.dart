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

  SessionBooking copyWith({
    String? bookingId,
    String? sessionId,
    String? userId,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    String? skillLevel,
    BookingStatus? status,
    int? queueOrder,
    DateTime? bookedAt,
    DateTime? checkinAt,
    String? recruitmentId,
    int? gender,
  }) {
    return SessionBooking(
      bookingId: bookingId ?? this.bookingId,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      skillLevel: skillLevel ?? this.skillLevel,
      status: status ?? this.status,
      queueOrder: queueOrder ?? this.queueOrder,
      bookedAt: bookedAt ?? this.bookedAt,
      checkinAt: checkinAt ?? this.checkinAt,
      recruitmentId: recruitmentId ?? this.recruitmentId,
      gender: gender ?? this.gender,
    );
  }
}
