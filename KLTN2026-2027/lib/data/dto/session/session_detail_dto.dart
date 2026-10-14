// lib/data/dto/session/session_detail_dto.dart

import 'guest_recruitment_dto.dart';
import 'session_booking_dto.dart';
import 'session_dto.dart';

class SessionDetailDto {
  final SessionDto session;
  final List<SessionBookingDto> confirmedPlayers;
  final List<SessionBookingDto> waitingQueue;
  final GuestRecruitmentDto? activeRecruitment;

  SessionDetailDto({
    required this.session,
    required this.confirmedPlayers,
    required this.waitingQueue,
    this.activeRecruitment,
  });

  factory SessionDetailDto.fromJson(Map<String, dynamic> json) {
    final sessionMap = json['session'] is Map<String, dynamic>
        ? json['session'] as Map<String, dynamic>
        : json;

    final confirmedList = (json['confirmedPlayers'] as List<dynamic>?)
            ?.map((item) => SessionBookingDto.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final waitingList = (json['waitingQueue'] as List<dynamic>?)
            ?.map((item) => SessionBookingDto.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final recruitmentMap = json['activeRecruitment'] is Map<String, dynamic>
        ? json['activeRecruitment'] as Map<String, dynamic>
        : null;

    return SessionDetailDto(
      session: SessionDto.fromJson(sessionMap),
      confirmedPlayers: confirmedList,
      waitingQueue: waitingList,
      activeRecruitment: recruitmentMap != null
          ? GuestRecruitmentDto.fromJson(recruitmentMap)
          : null,
    );
  }
}
