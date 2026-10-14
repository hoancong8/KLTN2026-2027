import '../../enums/session_enums.dart';

class ExploreClub {
  final String id;
  final String groupName;
  final String code;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? distanceKm;
  final SkillLevel? minSkillLevel;
  final SkillLevel? maxSkillLevel;
  final int memberCount;
  final bool isRecruiting;
  final double qualityScore;
  final String? schedulesSummary;

  const ExploreClub({
    required this.id,
    required this.groupName,
    required this.code,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.distanceKm,
    this.minSkillLevel,
    this.maxSkillLevel,
    required this.memberCount,
    required this.isRecruiting,
    required this.qualityScore,
    this.schedulesSummary,
  });
}
