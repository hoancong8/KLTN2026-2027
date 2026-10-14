// lib/domain/entities/session/session.dart

import '../../enums/session_enums.dart';

class Session {
  final String id;
  final String groupId;
  final String clubName;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String courtLocation;
  final int courtCount;
  final int targetPlayerPerCourt;
  final int maxPlayers;
  final DateTime deadlineBooking;
  final double courtRentalCost;
  final SessionStatus status;
  final int confirmedCount;
  final int waitingCount;
  final bool isBookedByCurrentUser;
  final BookingStatus? currentUserBookingStatus;
  final int currentUserQueueOrder;

  const Session({
    required this.id,
    required this.groupId,
    required this.clubName,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    required this.courtCount,
    required this.targetPlayerPerCourt,
    required this.maxPlayers,
    required this.deadlineBooking,
    required this.courtRentalCost,
    required this.status,
    required this.confirmedCount,
    required this.waitingCount,
    this.isBookedByCurrentUser = false,
    this.currentUserBookingStatus,
    this.currentUserQueueOrder = 0,
  });

  bool get isFull => confirmedCount >= maxPlayers;
  int get slotsRemaining => (maxPlayers - confirmedCount).clamp(0, maxPlayers);
  bool get isExpired => DateTime.now().toUtc().isAfter(deadlineBooking);
}
