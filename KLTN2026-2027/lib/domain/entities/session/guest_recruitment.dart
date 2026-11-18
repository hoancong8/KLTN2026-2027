// lib/domain/entities/session/guest_recruitment.dart

import '../../enums/session_enums.dart';

class GuestRecruitment {
  final String id;
  final String sessionId;
  final String clubName;
  final String courtLocation;
  final DateTime startTime;
  final DateTime endTime;
  final int slotsNeeded;
  final int slotsRemaining;
  final SkillLevel minSkillLevel;
  final double sharedCost;
  final double scanRadiusKm;
  final RecruitmentStatus status;
  final DateTime broadcastAt;
  final double? distanceKm;
  final bool hidePlayerList;
  final double? femaleDiscount;
  final double? femaleSharedCost;
  final String? myBookingStatus;
  final double? clubQualityScore;

  const GuestRecruitment({
    required this.id,
    required this.sessionId,
    required this.clubName,
    required this.courtLocation,
    required this.startTime,
    required this.endTime,
    required this.slotsNeeded,
    required this.slotsRemaining,
    required this.minSkillLevel,
    required this.sharedCost,
    required this.scanRadiusKm,
    required this.status,
    required this.broadcastAt,
    this.distanceKm,
    this.hidePlayerList = false,
    this.femaleDiscount,
    this.femaleSharedCost,
    this.myBookingStatus,
    this.clubQualityScore,
  });

  bool get isActive => status == RecruitmentStatus.active;
  bool get isFilled => status == RecruitmentStatus.filled;
  bool get isWaitingApproval => myBookingStatus?.toUpperCase() == 'WAITING';
  bool get isConfirmedParticipant =>
      myBookingStatus?.toUpperCase() == 'CONFIRMED' ||
      myBookingStatus?.toUpperCase() == 'CHECKED_IN';

  double get maleCost => sharedCost;
  double get femaleCost {
    if (femaleSharedCost != null && femaleSharedCost! > 0) {
      return femaleSharedCost!;
    }
    final discount = femaleDiscount ?? 10000.0;
    return (sharedCost - discount).clamp(0.0, sharedCost);
  }

  bool get isPassCourt =>
      courtLocation.toUpperCase().contains('PASS SÂN') ||
      courtLocation.toUpperCase().contains('[PASS') ||
      courtLocation.toUpperCase().contains('PASS') ||
      courtLocation.contains('(LH:') ||
      courtLocation.contains('LH:') ||
      clubName.toUpperCase().contains('PASS SÂN');

  String get cleanCourtLocation {
    var loc = courtLocation.replaceAll(RegExp(r'\(LH:\s*[^\)]+\)'), '').trim();
    if (loc.toUpperCase().startsWith('[PASS SÂN]')) {
      loc = loc.substring('[PASS SÂN]'.length).trim();
    }
    return loc.isEmpty ? courtLocation : loc;
  }

  double get passCourtPrice {
    if (slotsNeeded > 1 && sharedCost > 0 && sharedCost < 30000) {
      return (sharedCost * slotsNeeded).roundToDouble();
    }
    return sharedCost;
  }
}
