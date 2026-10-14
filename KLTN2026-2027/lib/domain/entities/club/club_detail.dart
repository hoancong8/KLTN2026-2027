import '../../enums/session_enums.dart';

class ClubHostEntity {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;

  const ClubHostEntity({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
  });
}

class ClubScheduleEntity {
  final String id;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isActive;

  const ClubScheduleEntity({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });
}

class ClubUserStatusEntity {
  final bool isMember;
  final String? roleName;
  final bool hasPendingJoinRequest;
  final String? pendingRequestId;

  const ClubUserStatusEntity({
    required this.isMember,
    this.roleName,
    required this.hasPendingJoinRequest,
    this.pendingRequestId,
  });
}

class ClubDetail {
  final String id;
  final String groupName;
  final String code;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? lat;
  final double? lng;
  final SkillLevel? minSkillLevel;
  final SkillLevel? maxSkillLevel;
  final double qualityScore;
  final bool isRecruiting;
  final int memberCount;
  final ClubHostEntity host;
  final List<ClubScheduleEntity> schedules;
  final ClubUserStatusEntity currentUserStatus;

  const ClubDetail({
    required this.id,
    required this.groupName,
    required this.code,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.lat,
    this.lng,
    this.minSkillLevel,
    this.maxSkillLevel,
    required this.qualityScore,
    required this.isRecruiting,
    required this.memberCount,
    required this.host,
    required this.schedules,
    required this.currentUserStatus,
  });
}

class ClubScheduleInput {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const ClubScheduleInput({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}
