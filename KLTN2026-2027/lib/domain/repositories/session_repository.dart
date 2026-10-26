// lib/domain/repositories/session_repository.dart

import '../entities/session/guest_recruitment.dart';
import '../entities/session/my_booking_item.dart';
import '../entities/session/session.dart';
import '../entities/session/session_booking.dart';
import '../entities/session/session_detail.dart';

abstract class SessionRepository {
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
  });

  Future<List<Session>> getClubSessions(String clubId);

  Future<SessionDetail> getSessionDetail(String sessionId);

  Future<void> updateSession({
    required String sessionId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String courtLocation,
    required int courtCount,
    required int maxPlayers,
    required DateTime deadlineBooking,
  });

  Future<void> updateSessionStatus(String sessionId, String status);

  Future<void> deleteSession(String sessionId);

  Future<SessionBooking> voteBooking(String sessionId);

  Future<void> cancelBooking(String sessionId);

  Future<void> confirmBooking(String sessionId, String bookingId);

  Future<List<SessionBooking>> getSessionBookings(String sessionId);

  Future<SessionBooking?> getMyBooking(String sessionId);

  Future<List<MyBookingItem>> getMyBookings();

  Future<String> createRecruitment({
    required String sessionId,
    required int slotsNeeded,
    String minSkillLevel = 'NB',
    double sharedCost = 0.0,
    double scanRadiusKm = 5.0,
    bool hidePlayerList = false,
    double? femaleDiscount,
    double? femaleSharedCost,
  });

  Future<GuestRecruitment?> getSessionRecruitment(String sessionId);

  Future<void> deleteRecruitment(String sessionId);

  Future<List<GuestRecruitment>> exploreRecruitments({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? minSkillLevel,
  });

  Future<SessionBooking> joinRecruitment(String recruitmentId);

  Future<void> cancelRecruitmentBooking(String recruitmentId);
}
