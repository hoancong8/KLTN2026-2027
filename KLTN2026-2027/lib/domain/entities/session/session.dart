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
  final String? address;
  final double? lat;
  final double? lng;
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
    this.address,
    this.lat,
    this.lng,
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

  bool get isCourtPass =>
      title.toUpperCase().contains('[PASS SÂN]') ||
      title.toUpperCase().contains('PASS SÂN') ||
      courtLocation.toUpperCase().contains('PASS SÂN') ||
      courtLocation.toUpperCase().contains('[PASS');

  String get cleanCourtLocation {
    var loc = courtLocation;
    loc = loc.replaceAll(RegExp(r'\(LH:\s*[^\)]+\)'), '').trim();
    if (loc.toUpperCase().startsWith('[PASS SÂN]')) {
      loc = loc.substring('[PASS SÂN]'.length).trim();
    }
    return loc.isEmpty ? courtLocation : loc;
  }

  String? get contactPhone {
    final match = RegExp(r'\(LH:\s*([^\)]+)\)').firstMatch(courtLocation);
    if (match != null) return match.group(1)?.trim();
    return null;
  }
}
