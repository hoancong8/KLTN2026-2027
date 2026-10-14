// lib/data/mapper/session_mapper.dart

import '../../domain/entities/session/guest_recruitment.dart';
import '../../domain/entities/session/session.dart';
import '../../domain/entities/session/session_booking.dart';
import '../../domain/entities/session/session_detail.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/session/guest_recruitment_dto.dart';
import '../dto/session/session_booking_dto.dart';
import '../dto/session/session_detail_dto.dart';
import '../dto/session/session_dto.dart';

class SessionMapper {
  static Session toEntity(SessionDto dto) {
    return Session(
      id: dto.id,
      groupId: dto.groupId,
      clubName: dto.clubName,
      title: dto.title,
      startTime: DateTime.tryParse(dto.startTime) ?? DateTime.now(),
      endTime: DateTime.tryParse(dto.endTime) ?? DateTime.now().add(const Duration(hours: 2)),
      courtLocation: dto.courtLocation,
      courtCount: dto.courtCount,
      targetPlayerPerCourt: dto.targetPlayerPerCourt,
      maxPlayers: dto.maxPlayers,
      deadlineBooking: DateTime.tryParse(dto.deadlineBooking) ?? DateTime.now(),
      courtRentalCost: dto.courtRentalCost,
      status: SessionStatus.fromString(dto.status),
      confirmedCount: dto.confirmedCount,
      waitingCount: dto.waitingCount,
      isBookedByCurrentUser: dto.isBookedByCurrentUser,
      currentUserBookingStatus: dto.currentUserBookingStatus != null
          ? BookingStatus.fromString(dto.currentUserBookingStatus)
          : null,
      currentUserQueueOrder: dto.currentUserQueueOrder,
    );
  }

  static SessionBooking toBookingEntity(SessionBookingDto dto) {
    return SessionBooking(
      bookingId: dto.bookingId,
      sessionId: dto.sessionId,
      userId: dto.userId,
      fullName: dto.fullName,
      avatarUrl: dto.avatarUrl,
      phoneNumber: dto.phoneNumber,
      skillLevel: dto.skillLevel,
      status: BookingStatus.fromString(dto.status),
      queueOrder: dto.queueOrder,
      bookedAt: DateTime.tryParse(dto.bookedAt) ?? DateTime.now(),
      checkinAt: dto.checkinAt != null ? DateTime.tryParse(dto.checkinAt!) : null,
      recruitmentId: dto.recruitmentId,
    );
  }

  static GuestRecruitment toRecruitmentEntity(GuestRecruitmentDto dto) {
    return GuestRecruitment(
      id: dto.id,
      sessionId: dto.sessionId,
      clubName: dto.clubName,
      courtLocation: dto.courtLocation,
      startTime: DateTime.tryParse(dto.startTime) ?? DateTime.now(),
      endTime: DateTime.tryParse(dto.endTime) ?? DateTime.now().add(const Duration(hours: 2)),
      slotsNeeded: dto.slotsNeeded,
      slotsRemaining: dto.slotsRemaining,
      minSkillLevel: SkillLevel.fromString(dto.minSkillLevel),
      sharedCost: dto.sharedCost,
      scanRadiusKm: dto.scanRadiusKm,
      status: RecruitmentStatus.fromString(dto.status),
      broadcastAt: DateTime.tryParse(dto.broadcastAt) ?? DateTime.now(),
      distanceKm: dto.distanceKm,
    );
  }

  static SessionDetail toDetailEntity(SessionDetailDto dto) {
    return SessionDetail(
      session: toEntity(dto.session),
      confirmedPlayers: dto.confirmedPlayers.map(toBookingEntity).toList(),
      waitingQueue: dto.waitingQueue.map(toBookingEntity).toList(),
      activeRecruitment: dto.activeRecruitment != null
          ? toRecruitmentEntity(dto.activeRecruitment!)
          : null,
    );
  }
}
