import '../../domain/entities/club/club_detail.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/club/club_detail_dto.dart';
import '../dto/club/update_club_info_request_dto.dart';
import '../dto/club/update_club_schedules_request_dto.dart';

class ClubDetailMapper {
  static ClubDetail toEntity(ClubDetailDto dto) {
    return ClubDetail(
      id: dto.id,
      groupName: dto.groupName,
      code: dto.code,
      description: dto.description,
      avatarUrl: dto.avatarUrl,
      fixedVenueName: dto.fixedVenueName,
      fixedAddress: dto.fixedAddress,
      lat: dto.lat,
      lng: dto.lng,
      minSkillLevel: dto.minSkillLevel != null ? SkillLevel.fromString(dto.minSkillLevel) : null,
      maxSkillLevel: dto.maxSkillLevel != null ? SkillLevel.fromString(dto.maxSkillLevel) : null,
      qualityScore: dto.qualityScore,
      isRecruiting: dto.isRecruiting,
      memberCount: dto.memberCount,
      host: ClubHostEntity(
        userId: dto.host.userId,
        fullName: dto.host.fullName,
        avatarUrl: dto.host.avatarUrl,
        phoneNumber: dto.host.phoneNumber,
      ),
      schedules: dto.schedules
          .map((s) => ClubScheduleEntity(
                id: s.id,
                dayOfWeek: s.dayOfWeek,
                dayName: s.dayName,
                startTime: s.startTime,
                endTime: s.endTime,
                isActive: s.isActive,
              ))
          .toList(),
      schedulesSummary: dto.schedulesSummary,
      currentUserStatus: ClubUserStatusEntity(
        isMember: dto.currentUserStatus.isMember,
        roleName: dto.currentUserStatus.roleName,
        status: dto.currentUserStatus.status,
        hasPendingJoinRequest: dto.currentUserStatus.hasPendingJoinRequest,
        pendingRequestId: dto.currentUserStatus.pendingRequestId,
      ),
    );
  }

  static UpdateClubInfoRequestDto toUpdateInfoDto({
    required String groupName,
    String? description,
    String? avatarUrl,
    String? fixedVenueName,
    String? fixedAddress,
    double? lat,
    double? lng,
    SkillLevel? minSkillLevel,
    SkillLevel? maxSkillLevel,
    required bool isRecruiting,
  }) {
    return UpdateClubInfoRequestDto(
      groupName: groupName,
      description: description,
      avatarUrl: avatarUrl,
      fixedVenueName: fixedVenueName,
      fixedAddress: fixedAddress,
      lat: lat,
      lng: lng,
      minSkillLevel: minSkillLevel?.code,
      maxSkillLevel: maxSkillLevel?.code,
      isRecruiting: isRecruiting,
    );
  }

  static UpdateClubSchedulesRequestDto toUpdateSchedulesDto(List<ClubScheduleInput> schedules) {
    return UpdateClubSchedulesRequestDto(
      schedules: schedules
          .map((s) => ClubScheduleItemRequestDto(
                dayOfWeek: s.dayOfWeek,
                startTime: s.startTime,
                endTime: s.endTime,
              ))
          .toList(),
    );
  }
}
