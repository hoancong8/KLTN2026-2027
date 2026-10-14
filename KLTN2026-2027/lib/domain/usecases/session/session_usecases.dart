// lib/domain/usecases/session/session_usecases.dart

import '../../entities/session/guest_recruitment.dart';
import '../../entities/session/session.dart';
import '../../entities/session/session_booking.dart';
import '../../entities/session/session_detail.dart';
import '../../repositories/session_repository.dart';

class CreateSessionParams {
  final String clubId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String courtLocation;
  final int courtCount;
  final int targetPlayerPerCourt;
  final int? maxPlayers;
  final DateTime? deadlineBooking;
  final double courtRentalCost;

  const CreateSessionParams({
    required this.clubId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    this.courtCount = 1,
    this.targetPlayerPerCourt = 6,
    this.maxPlayers,
    this.deadlineBooking,
    this.courtRentalCost = 0.0,
  });
}

class CreateSessionUseCase {
  final SessionRepository repository;
  CreateSessionUseCase(this.repository);

  Future<String> execute(CreateSessionParams params) {
    return repository.createSession(
      clubId: params.clubId,
      title: params.title,
      startTime: params.startTime,
      endTime: params.endTime,
      courtLocation: params.courtLocation,
      courtCount: params.courtCount,
      targetPlayerPerCourt: params.targetPlayerPerCourt,
      maxPlayers: params.maxPlayers,
      deadlineBooking: params.deadlineBooking,
      courtRentalCost: params.courtRentalCost,
    );
  }
}

class GetClubSessionsUseCase {
  final SessionRepository repository;
  GetClubSessionsUseCase(this.repository);

  Future<List<Session>> execute(String clubId) => repository.getClubSessions(clubId);
}

class GetSessionDetailUseCase {
  final SessionRepository repository;
  GetSessionDetailUseCase(this.repository);

  Future<SessionDetail> execute(String sessionId) => repository.getSessionDetail(sessionId);
}

class UpdateSessionParams {
  final String sessionId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String courtLocation;
  final int courtCount;
  final int maxPlayers;
  final DateTime deadlineBooking;

  const UpdateSessionParams({
    required this.sessionId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    required this.courtCount,
    required this.maxPlayers,
    required this.deadlineBooking,
  });
}

class UpdateSessionUseCase {
  final SessionRepository repository;
  UpdateSessionUseCase(this.repository);

  Future<void> execute(UpdateSessionParams params) {
    return repository.updateSession(
      sessionId: params.sessionId,
      title: params.title,
      startTime: params.startTime,
      endTime: params.endTime,
      courtLocation: params.courtLocation,
      courtCount: params.courtCount,
      maxPlayers: params.maxPlayers,
      deadlineBooking: params.deadlineBooking,
    );
  }
}

class UpdateSessionStatusUseCase {
  final SessionRepository repository;
  UpdateSessionStatusUseCase(this.repository);

  Future<void> execute(String sessionId, String status) =>
      repository.updateSessionStatus(sessionId, status);
}

class DeleteSessionUseCase {
  final SessionRepository repository;
  DeleteSessionUseCase(this.repository);

  Future<void> execute(String sessionId) => repository.deleteSession(sessionId);
}

class VoteBookingUseCase {
  final SessionRepository repository;
  VoteBookingUseCase(this.repository);

  Future<SessionBooking> execute(String sessionId) => repository.voteBooking(sessionId);
}

class CancelBookingUseCase {
  final SessionRepository repository;
  CancelBookingUseCase(this.repository);

  Future<void> execute(String sessionId) => repository.cancelBooking(sessionId);
}

class GetSessionBookingsUseCase {
  final SessionRepository repository;
  GetSessionBookingsUseCase(this.repository);

  Future<List<SessionBooking>> execute(String sessionId) =>
      repository.getSessionBookings(sessionId);
}

class GetMyBookingUseCase {
  final SessionRepository repository;
  GetMyBookingUseCase(this.repository);

  Future<SessionBooking?> execute(String sessionId) => repository.getMyBooking(sessionId);
}

class CreateRecruitmentParams {
  final String sessionId;
  final int slotsNeeded;
  final String minSkillLevel;
  final double sharedCost;
  final double scanRadiusKm;

  const CreateRecruitmentParams({
    required this.sessionId,
    required this.slotsNeeded,
    this.minSkillLevel = 'NB',
    this.sharedCost = 0.0,
    this.scanRadiusKm = 5.0,
  });
}

class CreateRecruitmentUseCase {
  final SessionRepository repository;
  CreateRecruitmentUseCase(this.repository);

  Future<String> execute(CreateRecruitmentParams params) {
    return repository.createRecruitment(
      sessionId: params.sessionId,
      slotsNeeded: params.slotsNeeded,
      minSkillLevel: params.minSkillLevel,
      sharedCost: params.sharedCost,
      scanRadiusKm: params.scanRadiusKm,
    );
  }
}

class GetSessionRecruitmentUseCase {
  final SessionRepository repository;
  GetSessionRecruitmentUseCase(this.repository);

  Future<GuestRecruitment?> execute(String sessionId) =>
      repository.getSessionRecruitment(sessionId);
}

class DeleteRecruitmentUseCase {
  final SessionRepository repository;
  DeleteRecruitmentUseCase(this.repository);

  Future<void> execute(String sessionId) => repository.deleteRecruitment(sessionId);
}

class ExploreRecruitmentsUseCase {
  final SessionRepository repository;
  ExploreRecruitmentsUseCase(this.repository);

  Future<List<GuestRecruitment>> execute({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? minSkillLevel,
  }) =>
      repository.exploreRecruitments(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        minSkillLevel: minSkillLevel,
      );
}

class JoinRecruitmentUseCase {
  final SessionRepository repository;
  JoinRecruitmentUseCase(this.repository);

  Future<SessionBooking> execute(String recruitmentId) =>
      repository.joinRecruitment(recruitmentId);
}

class CancelRecruitmentBookingUseCase {
  final SessionRepository repository;
  CancelRecruitmentBookingUseCase(this.repository);

  Future<void> execute(String recruitmentId) =>
      repository.cancelRecruitmentBooking(recruitmentId);
}
