// test/session_operations_screens_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/entities/session/session_attendance.dart';
import 'package:kltn2026_2027/domain/entities/session/session_review.dart';
import 'package:kltn2026_2027/domain/entities/session/session_rotation.dart';
import 'package:kltn2026_2027/domain/entities/session/session_settlement.dart';
import 'package:kltn2026_2027/domain/repositories/session_operations_repository.dart';
import 'package:kltn2026_2027/ui/screen/club/session_operations/session_attendance_screen.dart';
import 'package:kltn2026_2027/ui/screen/club/session_operations/session_reviews_screen.dart';
import 'package:kltn2026_2027/ui/screen/club/session_operations/session_rotation_screen.dart';
import 'package:kltn2026_2027/ui/screen/club/session_operations/session_settlement_screen.dart';

class FakeSessionOperationsRepository implements SessionOperationsRepository {
  @override
  Future<SessionAttendanceSnapshot> getAttendance(String sessionId) async {
    return SessionAttendanceSnapshot(
      sessionId: sessionId,
      groupId: 'club-1',
      startTime: DateTime(2026, 10, 24, 18, 0),
      endTime: DateTime(2026, 10, 24, 20, 0),
      maxPlayers: 12,
      presentCount: 6,
      notArrivedCount: 2,
      noShowCount: 0,
      waitlistCount: 0,
      readyCount: 6,
      canEdit: true,
      canStartRotation: true,
      players: [
        AttendancePlayer(
          userId: 'u1',
          bookingId: 'b1',
          fullName: 'Nguyễn Văn An',
          status: 'CHECKED_IN',
          bookedAt: DateTime(2026, 10, 23),
          skillLevel: 4,
          isReady: true,
        ),
      ],
    );
  }

  @override
  Future<SessionAttendanceSnapshot> updateAttendanceStatus({
    required String sessionId,
    required String userId,
    required String status,
  }) async => getAttendance(sessionId);

  @override
  Future<SessionAttendanceSnapshot> addWalkIn({
    required String sessionId,
    required String fullName,
    String? phoneNumber,
  }) async => getAttendance(sessionId);

  @override
  Future<SessionAttendanceSnapshot> completeAttendance(String sessionId) async => getAttendance(sessionId);

  @override
  Future<SessionRotationSnapshot> getRotation(String sessionId) async {
    return SessionRotationSnapshot(
      sessionId: sessionId,
      sessionStatus: 'PLAYING',
      rotationVersion: 1,
      serverTime: DateTime(2026, 10, 24, 18, 30),
      canInitialize: false,
      canGenerateProposals: true,
      readyCandidateCount: 2,
      coolingDownCount: 0,
      courts: [
        const CourtMatch(
          matchId: 'm1',
          courtNumber: 1,
          state: 'Playing',
          teamA: [RotationPlayer(userId: 'u1', fullName: 'An', skillLevel: 4)],
          teamB: [RotationPlayer(userId: 'u2', fullName: 'Bình', skillLevel: 3)],
        ),
      ],
    );
  }

  @override
  Future<SessionRotationSnapshot> initializeRotation(String sessionId) async => getRotation(sessionId);
  @override
  Future<SessionRotationSnapshot> generateProposals(String sessionId) async => getRotation(sessionId);
  @override
  Future<SessionRotationSnapshot> startMatch({required String sessionId, required String matchId}) async => getRotation(sessionId);
  @override
  Future<SessionRotationSnapshot> finishMatch({required String sessionId, required String matchId}) async => getRotation(sessionId);

  @override
  Future<SessionRotationSnapshot> pausePlayer({
    required String sessionId,
    required String userId,
    required bool isPaused,
  }) async => getRotation(sessionId);

  @override
  Future<SessionRotationSnapshot> restoreProposal({
    required String sessionId,
    required String matchId,
  }) async => getRotation(sessionId);

  @override
  Future<SessionRotationSnapshot> swapMatchPlayers({
    required String sessionId,
    required String matchId,
    required List<String> teamAUserIds,
    required List<String> teamBUserIds,
  }) async => getRotation(sessionId);

  @override
  Future<SessionSettlement> getSettlement(String sessionId) async {
    return const SessionSettlement(
      sessionId: 's1',
      shuttlecockUsed: 4,
      shuttlecockPrice: 25000,
      courtFee: 300000,
      extraFee: 40000,
      totalCost: 440000,
      totalCollected: 220000,
      isSettled: false,
      memberFees: [
        MemberSettlementFee(
          userId: 'u1',
          fullName: 'Nguyễn Văn An',
          roleName: 'Hội viên ngày',
          gender: 'MALE',
          baseFee: 55000,
          discount: 0,
          finalFee: 55000,
          paymentStatus: 'PAID',
          vietQrUrl: '',
          paymentCode: 'PAY_AN_55K',
        ),
      ],
    );
  }

  @override
  Future<SessionSettlement> calculateSettlement({
    required String sessionId,
    required int shuttlecockUsed,
    required int extraFee,
  }) async => getSettlement(sessionId);

  @override
  Future<SessionSettlement> markMemberPaid({required String sessionId, required String userId}) async => getSettlement(sessionId);

  @override
  Future<List<SessionReview>> getSessionReviews(String sessionId) async {
    return [
      SessionReview(
        id: 'r1',
        sessionId: sessionId,
        reviewerId: 'u1',
        reviewerName: 'Trần Minh Đức',
        rating: 5.0,
        comment: 'Sân đẹp, xoay tua sân 5 phút rất đều!',
        createdAt: DateTime(2026, 10, 24),
      ),
    ];
  }

  @override
  Future<void> submitReview(SessionReview review) async {}
}

void main() {
  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        sessionOperationsRepositoryProvider.overrideWithValue(FakeSessionOperationsRepository()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: child,
      ),
    );
  }

  testWidgets('SessionAttendanceScreen renders FR14 attendance metrics and player cards', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const SessionAttendanceScreen(sessionId: 'session-1')));
    await tester.pumpAndSettle();

    expect(find.text('Điểm Danh Tại Sân'), findsOneWidget);
    expect(find.text('Có mặt'), findsWidgets);
    expect(find.text('Chưa đến'), findsWidgets);
    expect(find.text('Báo vắng'), findsWidgets);
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
  });

  testWidgets('SessionRotationScreen renders FR15 rotation status and court match', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const SessionRotationScreen(sessionId: 'session-1')));
    await tester.pumpAndSettle();

    expect(find.text('Điều Phối Xoay Tua Sân'), findsOneWidget);
    expect(find.text('Hệ Thống Xoay Tua Đang Chạy'), findsOneWidget);
    expect(find.text('SÂN SỐ 1'), findsOneWidget);
  });

  testWidgets('SessionSettlementScreen renders FR18-FR21 fee calculations and breakdown', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const SessionSettlementScreen(sessionId: 'session-1')));
    await tester.pumpAndSettle();

    expect(find.text('Tính Tiền Cầu & Sân'), findsOneWidget);
    expect(find.text('Tổng Chi Phí Buổi Chơi'), findsOneWidget);
    expect(find.text('440,000 đ'), findsOneWidget);
    expect(find.text('ĐÃ ĐÓNG TIỀN'), findsOneWidget);
  });

  testWidgets('SessionReviewsScreen renders FR23 reviews and rating score', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const SessionReviewsScreen(sessionId: 'session-1')));
    await tester.pumpAndSettle();

    expect(find.text('Đánh Giá & Tín Nhiệm'), findsOneWidget);
    expect(find.text('4.9 / 5.0 Điểm Tín Nhiệm'), findsOneWidget);
    expect(find.text('Trần Minh Đức'), findsOneWidget);
  });
}
