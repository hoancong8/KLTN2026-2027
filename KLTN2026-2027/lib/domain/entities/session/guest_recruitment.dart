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
  });

  bool get isActive => status == RecruitmentStatus.active;
  bool get isFilled => status == RecruitmentStatus.filled;
}
