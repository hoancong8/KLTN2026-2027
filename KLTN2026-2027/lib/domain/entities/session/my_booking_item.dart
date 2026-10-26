// lib/domain/entities/session/my_booking_item.dart

import '../../enums/session_enums.dart';

class MyBookingItem {
  final String bookingId;
  final String sessionId;
  final String sessionTitle;
  final String clubId;
  final String clubName;
  final String? clubAvatarUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String courtLocation;
  final SessionStatus sessionStatus;
  final BookingStatus bookingStatus;
  final int queueOrder;
  final double feePerMember;
  final DateTime bookedAt;
  final DateTime? checkinAt;
  final bool isGuest;
  final String memberType;

  const MyBookingItem({
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

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing => startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
  bool get isUpcomingOrOngoing => endTime.isAfter(DateTime.now());
  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isConfirmed => bookingStatus == BookingStatus.confirmed;
  bool get isWaiting => bookingStatus == BookingStatus.waiting;
  bool get isCheckedIn => bookingStatus == BookingStatus.checkedIn;
  bool get isMonthlyMember => !isGuest && memberType.toUpperCase() == 'MONTHLY';
  bool get isDailyMember => !isGuest && memberType.toUpperCase() == 'DAILY';
}
