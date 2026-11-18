// test/court_pass_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/session/create_court_pass_request_dto.dart';
import 'package:kltn2026_2027/domain/entities/session/create_court_pass_params.dart';
import 'package:kltn2026_2027/domain/usecases/session/session_usecases.dart';
import 'package:kltn2026_2027/domain/repositories/session_repository.dart';
import 'package:kltn2026_2027/domain/entities/session/guest_recruitment.dart';
import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';
import 'package:kltn2026_2027/domain/entities/session/session.dart';
import 'package:kltn2026_2027/domain/entities/session/session_booking.dart';
import 'package:kltn2026_2027/domain/entities/session/session_detail.dart';

class _FakeSessionRepository implements SessionRepository {
  CreateCourtPassParams? lastParams;

  @override
  Future<String> createCourtPass(CreateCourtPassParams params) async {
    lastParams = params;
    return 'fake-session-id-123';
  }

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
    String? address,
    double? lat,
    double? lng,
  }) async => 'session-id';

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
  }) async => 'recruitment-id';

  @override
  Future<void> cancelBooking(String sessionId) async {}
  @override
  Future<void> cancelRecruitmentBooking(String recruitmentId) async {}
  @override
  Future<void> confirmBooking(String sessionId, String bookingId) async {}
  @override
  Future<void> deleteRecruitment(String sessionId) async {}
  @override
  Future<void> deleteSession(String sessionId) async {}
  @override
  Future<List<GuestRecruitment>> exploreRecruitments({double? latitude, double? longitude, double? radiusKm, String? minSkillLevel}) async => [];
  @override
  Future<List<Session>> getClubSessions(String clubId) async => [];
  @override
  Future<SessionBooking?> getMyBooking(String sessionId) async => null;
  @override
  Future<List<MyBookingItem>> getMyBookings() async => [];
  @override
  Future<List<SessionBooking>> getSessionBookings(String sessionId) async => [];
  @override
  Future<SessionDetail> getSessionDetail(String sessionId) async => throw UnimplementedError();
  @override
  Future<GuestRecruitment?> getSessionRecruitment(String sessionId) async => null;
  @override
  Future<SessionBooking> joinRecruitment(String recruitmentId) async => throw UnimplementedError();
  @override
  Future<void> updateSession({required String sessionId, required String title, required DateTime startTime, required DateTime endTime, required String courtLocation, required int courtCount, required int maxPlayers, required DateTime deadlineBooking}) async {}
  @override
  Future<void> updateSessionStatus(String sessionId, String status) async {}
  @override
  Future<SessionBooking> voteBooking(String sessionId) async => throw UnimplementedError();
}

void main() {
  group('CreateCourtPass Tests', () {
    test('CreateCourtPassRequestDto converts to JSON correctly', () {
      final dto = CreateCourtPassRequestDto(
        clubId: 'club-1',
        courtLocation: 'Sân Cầu Lông Kỳ Hòa',
        address: '238 Đường 3/2',
        startTime: '2026-11-18T18:00:00Z',
        endTime: '2026-11-18T20:00:00Z',
        courtCount: 2,
        passPrice: 160000,
        contactPhone: '0901234567',
        note: 'Pass gấp 2 sân',
        minSkillLevel: 'NB',
      );

      final json = dto.toJson();
      expect(json['clubId'], 'club-1');
      expect(json['courtLocation'], 'Sân Cầu Lông Kỳ Hòa');
      expect(json['courtCount'], 2);
      expect(json['passPrice'], 160000.0);
      expect(json['contactPhone'], '0901234567');
      expect(json['minSkillLevel'], 'NB');
    });

    test('CreateCourtPassUseCase executes and passes params to repository', () async {
      final fakeRepo = _FakeSessionRepository();
      final useCase = CreateCourtPassUseCase(fakeRepo);

      final now = DateTime.now();
      final params = CreateCourtPassParams(
        courtLocation: 'Sân Cầu Lông Tia Chớp',
        startTime: now,
        endTime: now.add(const Duration(hours: 2)),
        courtCount: 1,
        passPrice: 150000,
        contactPhone: '0988776655',
        note: 'Bận việc cần pass',
      );

      final result = await useCase.execute(params);

      expect(result, 'fake-session-id-123');
      expect(fakeRepo.lastParams?.courtLocation, 'Sân Cầu Lông Tia Chớp');
      expect(fakeRepo.lastParams?.passPrice, 150000.0);
      expect(fakeRepo.lastParams?.contactPhone, '0988776655');
    });
  });
}
