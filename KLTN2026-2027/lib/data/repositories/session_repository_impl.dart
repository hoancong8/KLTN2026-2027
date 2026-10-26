// lib/data/repositories/session_repository_impl.dart

import '../../domain/entities/session/guest_recruitment.dart';
import '../../domain/entities/session/my_booking_item.dart';
import '../../domain/entities/session/session.dart';
import '../../domain/entities/session/session_booking.dart';
import '../../domain/entities/session/session_detail.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasource/remote/abstract/session_remote_datasource.dart';
import '../dto/session/create_recruitment_request_dto.dart';
import '../dto/session/create_session_request_dto.dart';
import '../dto/session/update_session_request_dto.dart';
import '../mapper/my_booking_mapper.dart';
import '../mapper/session_mapper.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remote;

  SessionRepositoryImpl(this.remote);

  @override
  Future<String> createSession({
    required String clubId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String courtLocation,
    int courtCount = 1,
    int targetPlayerPerCourt = 6,
    int? maxPlayers,
    DateTime? deadlineBooking,
    double courtRentalCost = 0.0,
  }) async {
    final request = CreateSessionRequestDto(
      title: title,
      startTime: startTime.toUtc().toIso8601String(),
      endTime: endTime.toUtc().toIso8601String(),
      courtLocation: courtLocation,
      courtCount: courtCount,
      targetPlayerPerCourt: targetPlayerPerCourt,
      maxPlayers: maxPlayers,
      deadlineBooking: deadlineBooking?.toUtc().toIso8601String(),
      courtRentalCost: courtRentalCost,
    );
    return await remote.createSession(clubId, request);
  }

  @override
  Future<List<Session>> getClubSessions(String clubId) async {
    final dtos = await remote.getClubSessions(clubId);
    return dtos.map(SessionMapper.toEntity).toList();
  }

  @override
  Future<SessionDetail> getSessionDetail(String sessionId) async {
    final dto = await remote.getSessionDetail(sessionId);
    return SessionMapper.toDetailEntity(dto);
  }

  @override
  Future<void> updateSession({
    required String sessionId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String courtLocation,
    required int courtCount,
    required int maxPlayers,
    required DateTime deadlineBooking,
  }) async {
    final request = UpdateSessionRequestDto(
      title: title,
      startTime: startTime.toUtc().toIso8601String(),
      endTime: endTime.toUtc().toIso8601String(),
      courtLocation: courtLocation,
      courtCount: courtCount,
      maxPlayers: maxPlayers,
      deadlineBooking: deadlineBooking.toUtc().toIso8601String(),
    );
    await remote.updateSession(sessionId, request);
  }

  @override
  Future<void> updateSessionStatus(String sessionId, String status) async {
    await remote.updateSessionStatus(sessionId, status);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await remote.deleteSession(sessionId);
  }

  @override
  Future<SessionBooking> voteBooking(String sessionId) async {
    final dto = await remote.voteBooking(sessionId);
    return SessionMapper.toBookingEntity(dto);
  }

  @override
  Future<void> cancelBooking(String sessionId) async {
    await remote.cancelBooking(sessionId);
  }

  @override
  Future<void> confirmBooking(String sessionId, String bookingId) async {
    await remote.confirmBooking(sessionId, bookingId);
  }

  @override
  Future<List<SessionBooking>> getSessionBookings(String sessionId) async {
    final dtos = await remote.getSessionBookings(sessionId);
    return dtos.map(SessionMapper.toBookingEntity).toList();
  }

  @override
  Future<SessionBooking?> getMyBooking(String sessionId) async {
    final dto = await remote.getMyBooking(sessionId);
    return dto != null ? SessionMapper.toBookingEntity(dto) : null;
  }

  @override
  Future<List<MyBookingItem>> getMyBookings() async {
    final dtos = await remote.getMyBookings();
    return dtos.map(MyBookingMapper.toEntity).toList();
  }

  @override
  Future<String> createRecruitment({
    required String sessionId,
    required int slotsNeeded,
    String minSkillLevel = 'NB',
    double sharedCost = 0.0,
    double scanRadiusKm = 5.0,
    bool hidePlayerList = false,
    double? femaleDiscount,
    double? femaleSharedCost,
  }) async {
    final request = CreateRecruitmentRequestDto(
      slotsNeeded: slotsNeeded,
      minSkillLevel: minSkillLevel,
      sharedCost: sharedCost,
      scanRadiusKm: scanRadiusKm,
      hidePlayerList: hidePlayerList,
      femaleDiscount: femaleDiscount,
      femaleSharedCost: femaleSharedCost,
    );
    return await remote.createRecruitment(sessionId, request);
  }

  @override
  Future<GuestRecruitment?> getSessionRecruitment(String sessionId) async {
    final dto = await remote.getSessionRecruitment(sessionId);
    return dto != null ? SessionMapper.toRecruitmentEntity(dto) : null;
  }

  @override
  Future<void> deleteRecruitment(String sessionId) async {
    await remote.deleteRecruitment(sessionId);
  }

  @override
  Future<List<GuestRecruitment>> exploreRecruitments({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? minSkillLevel,
  }) async {
    final dtos = await remote.exploreRecruitments(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      minSkillLevel: minSkillLevel,
    );
    return dtos.map(SessionMapper.toRecruitmentEntity).toList();
  }

  @override
  Future<SessionBooking> joinRecruitment(String recruitmentId) async {
    final dto = await remote.joinRecruitment(recruitmentId);
    return SessionMapper.toBookingEntity(dto);
  }

  @override
  Future<void> cancelRecruitmentBooking(String recruitmentId) async {
    await remote.cancelRecruitmentBooking(recruitmentId);
  }
}
