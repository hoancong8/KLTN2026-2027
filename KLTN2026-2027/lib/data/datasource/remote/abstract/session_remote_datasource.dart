// lib/data/datasource/remote/abstract/session_remote_datasource.dart

import '../../../dto/session/create_recruitment_request_dto.dart';
import '../../../dto/session/create_session_request_dto.dart';
import '../../../dto/session/guest_recruitment_dto.dart';
import '../../../dto/session/my_booking_item_dto.dart';
import '../../../dto/session/session_booking_dto.dart';
import '../../../dto/session/session_detail_dto.dart';
import '../../../dto/session/session_dto.dart';
import '../../../dto/session/session_settlement_dto.dart';
import '../../../dto/session/update_session_request_dto.dart';

abstract class SessionRemoteDataSource {
  Future<String> createSession(String clubId, CreateSessionRequestDto request);

  Future<List<SessionDto>> getClubSessions(String clubId);

  Future<SessionDetailDto> getSessionDetail(String sessionId);

  Future<void> updateSession(String sessionId, UpdateSessionRequestDto request);

  Future<void> updateSessionStatus(String sessionId, String status);

  Future<void> deleteSession(String sessionId);

  Future<SessionBookingDto> voteBooking(String sessionId);

  Future<void> cancelBooking(String sessionId);

  Future<void> confirmBooking(String sessionId, String bookingId);

  Future<List<SessionBookingDto>> getSessionBookings(String sessionId);

  Future<SessionBookingDto?> getMyBooking(String sessionId);

  Future<List<MyBookingItemDto>> getMyBookings();

  Future<String> createRecruitment(String sessionId, CreateRecruitmentRequestDto request);

  Future<GuestRecruitmentDto?> getSessionRecruitment(String sessionId);

  Future<void> deleteRecruitment(String sessionId);

  Future<List<GuestRecruitmentDto>> exploreRecruitments({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? minSkillLevel,
  });

  Future<SessionBookingDto> joinRecruitment(String recruitmentId);

  Future<void> cancelRecruitmentBooking(String recruitmentId);

  Future<SessionSettlementDto> getSettlement(String sessionId);

  Future<SessionSettlementDto> calculateSettlement({
    required String sessionId,
    required int shuttlecockUsed,
    required int shuttlecockPrice,
    required int extraFee,
    int? courtFee,
  });

  Future<SessionSettlementDto> markMemberPaid({
    required String sessionId,
    required String userId,
  });
}
