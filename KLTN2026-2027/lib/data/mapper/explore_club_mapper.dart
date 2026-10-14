import '../../domain/entities/club/explore_club.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/club/explore_club_dto.dart';

class ExploreClubMapper {
  static ExploreClub toEntity(ExploreClubDto dto) {
    return ExploreClub(
      id: dto.id,
      groupName: dto.groupName,
      code: dto.code,
      description: dto.description,
      avatarUrl: dto.avatarUrl,
      fixedVenueName: dto.fixedVenueName,
      fixedAddress: dto.fixedAddress,
      distanceKm: dto.distanceKm,
      minSkillLevel: dto.minSkillLevel != null ? SkillLevel.fromString(dto.minSkillLevel) : null,
      maxSkillLevel: dto.maxSkillLevel != null ? SkillLevel.fromString(dto.maxSkillLevel) : null,
      memberCount: dto.memberCount,
      isRecruiting: dto.isRecruiting,
      qualityScore: dto.qualityScore,
      schedulesSummary: dto.schedulesSummary,
    );
  }
}
