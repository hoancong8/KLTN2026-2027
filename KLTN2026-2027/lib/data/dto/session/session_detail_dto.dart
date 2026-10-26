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

  factory SessionDetailDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return SessionDetailDto(
        session: SessionDto.fromJson(null),
        confirmedPlayers: const [],
        waitingQueue: const [],
        activeRecruitment: null,
      );
    }
    final json = rawJson;
    final sessionMap = json['session'] is Map
        ? json['session']
        : json;

    final rawConfirmed = json['confirmedPlayers'];
    final confirmedList = (rawConfirmed is List)
        ? rawConfirmed.map((item) => SessionBookingDto.fromJson(item)).toList()
        : <SessionBookingDto>[];

    final rawWaiting = json['waitingQueue'];
    final waitingList = (rawWaiting is List)
        ? rawWaiting.map((item) => SessionBookingDto.fromJson(item)).toList()
        : <SessionBookingDto>[];

    final rawRecruitment = json['activeRecruitment'];
    final recruitment = (rawRecruitment is Map)
        ? GuestRecruitmentDto.fromJson(rawRecruitment)
        : null;

    return SessionDetailDto(
      session: SessionDto.fromJson(sessionMap),
      confirmedPlayers: confirmedList,
      waitingQueue: waitingList,
      activeRecruitment: recruitment,
    );
  }
}
