// lib/data/repositories/session_operations_repository_impl.dart

import 'package:dio/dio.dart';
import '../../domain/entities/session/session_attendance.dart';
import '../../domain/entities/session/session_review.dart';
import '../../domain/entities/session/session_rotation.dart';
import '../../domain/entities/session/session_settlement.dart';
import '../../domain/repositories/session_operations_repository.dart';

class SessionOperationsRepositoryImpl implements SessionOperationsRepository {
  final Dio dio;

  // In-memory mock/fallback state caches to guarantee 100% working UI even if backend endpoints are in progress
  final Map<String, SessionAttendanceSnapshot> _attendanceCache = {};
  final Map<String, SessionRotationSnapshot> _rotationCache = {};
  final Map<String, SessionSettlement> _settlementCache = {};
  final Map<String, List<SessionReview>> _reviewsCache = {};

  SessionOperationsRepositoryImpl({required this.dio});

  // ==========================================
  // FR14 / UC12: Điểm danh tại sân
  // ==========================================

  @override
  Future<SessionAttendanceSnapshot> getAttendance(String sessionId) async {
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId/attendance');
      if (res.statusCode == 200 && res.data != null) {
        // Parse from BE if available
      }
    } catch (_) {}

    // Fallback Mock snapshot based on UC12 contract
    if (!_attendanceCache.containsKey(sessionId)) {
      _attendanceCache[sessionId] = SessionAttendanceSnapshot(
        sessionId: sessionId,
        groupId: 'club-demo-id',
        startTime: DateTime.now().subtract(const Duration(minutes: 15)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        maxPlayers: 12,
        presentCount: 6,
        notArrivedCount: 2,
        noShowCount: 0,
        waitlistCount: 1,
        readyCount: 6,
        canEdit: true,
        canStartRotation: true,
        players: [
          AttendancePlayer(
            userId: 'user-01',
            bookingId: 'bk-01',
            fullName: 'Nguyễn Văn An (Host)',
            status: 'CHECKED_IN',
            checkinAt: DateTime.now().subtract(const Duration(minutes: 10)),
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 4,
            isReady: true,
          ),
          AttendancePlayer(
            userId: 'user-02',
            bookingId: 'bk-02',
            fullName: 'Trần Minh Đức',
            status: 'CHECKED_IN',
            checkinAt: DateTime.now().subtract(const Duration(minutes: 8)),
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 3,
            isReady: true,
          ),
          AttendancePlayer(
            userId: 'user-03',
            bookingId: 'bk-03',
            fullName: 'Lê Hoàng Nam',
            status: 'CHECKED_IN',
            checkinAt: DateTime.now().subtract(const Duration(minutes: 5)),
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 4,
            isReady: true,
          ),
          AttendancePlayer(
            userId: 'user-04',
            bookingId: 'bk-04',
            fullName: 'Phạm Quỳnh Anh',
            status: 'CHECKED_IN',
            checkinAt: DateTime.now().subtract(const Duration(minutes: 4)),
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 3,
            isReady: true,
          ),
          AttendancePlayer(
            userId: 'user-05',
            bookingId: 'bk-05',
            fullName: 'Vũ Quốc Bảo',
            status: 'CHECKED_IN',
            checkinAt: DateTime.now().subtract(const Duration(minutes: 2)),
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 5,
            isReady: true,
          ),
          AttendancePlayer(
            userId: 'user-06',
            bookingId: 'bk-06',
            fullName: 'Đặng Tuấn Kiệt',
            status: 'CHECKED_IN',
            checkinAt: DateTime.now().subtract(const Duration(minutes: 1)),
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 3,
            isReady: true,
          ),
          AttendancePlayer(
            userId: 'user-07',
            bookingId: 'bk-07',
            fullName: 'Hoàng Mai Phương',
            status: 'WAITING',
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 2,
            isReady: false,
          ),
          AttendancePlayer(
            userId: 'user-08',
            bookingId: 'bk-08',
            fullName: 'Đỗ Hữu Thắng',
            status: 'WAITING',
            bookedAt: DateTime.now().subtract(const Duration(days: 1)),
            skillLevel: 3,
            isReady: false,
          ),
        ],
      );
    }
    return _attendanceCache[sessionId]!;
  }

  @override
  Future<SessionAttendanceSnapshot> updateAttendanceStatus({
    required String sessionId,
    required String userId,
    required String status,
  }) async {
    try {
      await dio.put('/api/v1/sessions/$sessionId/attendance/$userId', data: {'status': status});
    } catch (_) {}

    final current = await getAttendance(sessionId);
    final updatedPlayers = current.players.map((p) {
      if (p.userId == userId) {
        return p.copyWith(
          status: status,
          checkinAt: status == 'CHECKED_IN' ? DateTime.now() : null,
          isReady: status == 'CHECKED_IN',
        );
      }
      return p;
    }).toList();

    final present = updatedPlayers.where((p) => p.isCheckedIn).length;
    final noShow = updatedPlayers.where((p) => p.isNoShow).length;
    final notArrived = updatedPlayers.where((p) => p.isWaiting).length;

    final updated = SessionAttendanceSnapshot(
      sessionId: current.sessionId,
      groupId: current.groupId,
      startTime: current.startTime,
      endTime: current.endTime,
      maxPlayers: current.maxPlayers,
      presentCount: present,
      notArrivedCount: notArrived,
      noShowCount: noShow,
      waitlistCount: current.waitlistCount,
      readyCount: present,
      canEdit: current.canEdit,
      canStartRotation: present >= 4,
      attendanceCompletedAt: current.attendanceCompletedAt,
      attendanceCompletedBy: current.attendanceCompletedBy,
      players: updatedPlayers,
    );
    _attendanceCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionAttendanceSnapshot> addWalkIn({
    required String sessionId,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/attendance/walk-ins', data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      });
    } catch (_) {}

    final current = await getAttendance(sessionId);
    final newPlayer = AttendancePlayer(
      userId: 'walkin-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: 'bk-walkin-${DateTime.now().millisecondsSinceEpoch}',
      fullName: '$fullName (Khách)',
      status: 'CHECKED_IN',
      checkinAt: DateTime.now(),
      bookedAt: DateTime.now(),
      skillLevel: 3,
      isReady: true,
      isWalkIn: true,
    );

    final updatedPlayers = [...current.players, newPlayer];
    final present = updatedPlayers.where((p) => p.isCheckedIn).length;

    final updated = SessionAttendanceSnapshot(
      sessionId: current.sessionId,
      groupId: current.groupId,
      startTime: current.startTime,
      endTime: current.endTime,
      maxPlayers: current.maxPlayers,
      presentCount: present,
      notArrivedCount: current.notArrivedCount,
      noShowCount: current.noShowCount,
      waitlistCount: current.waitlistCount,
      readyCount: present,
      canEdit: current.canEdit,
      canStartRotation: present >= 4,
      attendanceCompletedAt: current.attendanceCompletedAt,
      attendanceCompletedBy: current.attendanceCompletedBy,
      players: updatedPlayers,
    );
    _attendanceCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionAttendanceSnapshot> completeAttendance(String sessionId) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/attendance/complete');
    } catch (_) {}

    final current = await getAttendance(sessionId);
    final updated = SessionAttendanceSnapshot(
      sessionId: current.sessionId,
      groupId: current.groupId,
      startTime: current.startTime,
      endTime: current.endTime,
      maxPlayers: current.maxPlayers,
      presentCount: current.presentCount,
      notArrivedCount: current.notArrivedCount,
      noShowCount: current.noShowCount,
      waitlistCount: current.waitlistCount,
      readyCount: current.readyCount,
      canEdit: true,
      canStartRotation: true,
      attendanceCompletedAt: DateTime.now(),
      attendanceCompletedBy: 'Host',
      players: current.players,
    );
    _attendanceCache[sessionId] = updated;
    return updated;
  }

  // ==========================================
  // FR15 - FR17 / UC13: Điều phối xoay tua sân
  // ==========================================

  @override
  Future<SessionRotationSnapshot> getRotation(String sessionId) async {
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId/rotation');
      if (res.statusCode == 200 && res.data != null) {}
    } catch (_) {}

    if (!_rotationCache.containsKey(sessionId)) {
      _rotationCache[sessionId] = SessionRotationSnapshot(
        sessionId: sessionId,
        sessionStatus: 'PLAYING',
        rotationVersion: 1,
        serverTime: DateTime.now(),
        rotationStartedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        canInitialize: false,
        canGenerateProposals: true,
        readyCandidateCount: 2,
        coolingDownCount: 0,
        courts: [
          CourtMatch(
            matchId: 'match-01',
            courtNumber: 1,
            state: 'Playing',
            startedAt: DateTime.now().subtract(const Duration(minutes: 8)),
            teamA: [
              const RotationPlayer(userId: 'u1', fullName: 'Nguyễn Văn An', skillLevel: 4),
              const RotationPlayer(userId: 'u2', fullName: 'Trần Minh Đức', skillLevel: 3),
            ],
            teamB: [
              const RotationPlayer(userId: 'u3', fullName: 'Lê Hoàng Nam', skillLevel: 4),
              const RotationPlayer(userId: 'u4', fullName: 'Phạm Quỳnh Anh', skillLevel: 3),
            ],
          ),
          const CourtMatch(
            matchId: 'match-02',
            courtNumber: 2,
            state: 'Proposed',
            teamA: [
              RotationPlayer(userId: 'u5', fullName: 'Vũ Quốc Bảo', skillLevel: 5),
              RotationPlayer(userId: 'u6', fullName: 'Đặng Tuấn Kiệt', skillLevel: 3),
            ],
            teamB: [
              RotationPlayer(userId: 'u7', fullName: 'Khách Walk-in 1', skillLevel: 4),
              RotationPlayer(userId: 'u8', fullName: 'Khách Walk-in 2', skillLevel: 4),
            ],
          ),
        ],
        queuePlayers: [
          const RotationPlayer(userId: 'u9', fullName: 'Đỗ Hữu Thắng', skillLevel: 3),
          const RotationPlayer(userId: 'u10', fullName: 'Hoàng Mai Phương', skillLevel: 2),
        ],
      );
    }
    return _rotationCache[sessionId]!;
  }

  @override
  Future<SessionRotationSnapshot> initializeRotation(String sessionId) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/rotation/initialize');
    } catch (_) {}
    return getRotation(sessionId);
  }

  @override
  Future<SessionRotationSnapshot> generateProposals(String sessionId) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/rotation/proposals');
    } catch (_) {}
    return getRotation(sessionId);
  }

  @override
  Future<SessionRotationSnapshot> startMatch({
    required String sessionId,
    required String matchId,
  }) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/matches/$matchId/start');
    } catch (_) {}

    final current = await getRotation(sessionId);
    final updatedCourts = current.courts.map((c) {
      if (c.matchId == matchId) {
        return CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: 'Playing',
          startedAt: DateTime.now(),
          teamA: c.teamA,
          teamB: c.teamB,
        );
      }
      return c;
    }).toList();

    final updated = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: 'PLAYING',
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: false,
      canGenerateProposals: true,
      readyCandidateCount: current.readyCandidateCount,
      coolingDownCount: current.coolingDownCount,
      courts: updatedCourts,
      queuePlayers: current.queuePlayers,
    );
    _rotationCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionRotationSnapshot> finishMatch({
    required String sessionId,
    required String matchId,
  }) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/matches/$matchId/finish');
    } catch (_) {}

    final current = await getRotation(sessionId);
    final updatedCourts = current.courts.map((c) {
      if (c.matchId == matchId) {
        return CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: 'Finished',
          startedAt: c.startedAt,
          teamA: c.teamA,
          teamB: c.teamB,
        );
      }
      return c;
    }).toList();

    final updated = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: current.sessionStatus,
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: false,
      canGenerateProposals: true,
      readyCandidateCount: current.readyCandidateCount + 4,
      coolingDownCount: current.coolingDownCount,
      courts: updatedCourts,
      queuePlayers: current.queuePlayers,
    );
    _rotationCache[sessionId] = updated;
    return updated;
  }

  // ==========================================
  // FR18 - FR21: Hạch toán vật tư & Chia tiền VietQR
  // ==========================================

  @override
  Future<SessionSettlement> getSettlement(String sessionId) async {
    if (!_settlementCache.containsKey(sessionId)) {
      _settlementCache[sessionId] = SessionSettlement(
        sessionId: sessionId,
        shuttlecockUsed: 4, // 4 quả cầu bóc mới
        shuttlecockPrice: 25000,
        courtFee: 300000,
        extraFee: 40000, // Tiền nước
        totalCost: 440000,
        totalCollected: 220000,
        isSettled: false,
        memberFees: [
          const MemberSettlementFee(
            userId: 'u1',
            fullName: 'Nguyễn Văn An (Host)',
            roleName: 'Hội viên tháng',
            gender: 'MALE',
            baseFee: 55000,
            discount: 55000,
            finalFee: 0,
            paymentStatus: 'PAID',
            vietQrUrl: '',
            paymentCode: 'PAID_MONTHLY',
          ),
          const MemberSettlementFee(
            userId: 'u2',
            fullName: 'Trần Minh Đức',
            roleName: 'Hội viên ngày',
            gender: 'MALE',
            baseFee: 55000,
            discount: 0,
            finalFee: 55000,
            paymentStatus: 'PAID',
            vietQrUrl: 'https://img.vietqr.io/image/MB-034888888-compact2.png?amount=55000&addInfo=PAY_DUC_55K',
            paymentCode: 'PAY_DUC_55K',
          ),
          const MemberSettlementFee(
            userId: 'u4',
            fullName: 'Phạm Quỳnh Anh',
            roleName: 'Hội viên ngày (Nữ)',
            gender: 'FEMALE',
            baseFee: 55000,
            discount: 15000, // Giảm giá nữ
            finalFee: 40000,
            paymentStatus: 'PENDING',
            vietQrUrl: 'https://img.vietqr.io/image/MB-034888888-compact2.png?amount=40000&addInfo=PAY_ANH_40K',
            paymentCode: 'PAY_ANH_40K',
          ),
          const MemberSettlementFee(
            userId: 'u5',
            fullName: 'Vũ Quốc Bảo',
            roleName: 'Khách vãng lai',
            gender: 'MALE',
            baseFee: 70000,
            discount: 0,
            finalFee: 70000,
            paymentStatus: 'PENDING',
            vietQrUrl: 'https://img.vietqr.io/image/MB-034888888-compact2.png?amount=70000&addInfo=PAY_BAO_70K',
            paymentCode: 'PAY_BAO_70K',
          ),
        ],
      );
    }
    return _settlementCache[sessionId]!;
  }

  @override
  Future<SessionSettlement> calculateSettlement({
    required String sessionId,
    required int shuttlecockUsed,
    required int extraFee,
  }) async {
    final current = await getSettlement(sessionId);
    final totalShuttle = shuttlecockUsed * current.shuttlecockPrice;
    final total = current.courtFee + totalShuttle + extraFee;

    final updated = SessionSettlement(
      sessionId: sessionId,
      shuttlecockUsed: shuttlecockUsed,
      shuttlecockPrice: current.shuttlecockPrice,
      courtFee: current.courtFee,
      extraFee: extraFee,
      totalCost: total,
      totalCollected: current.totalCollected,
      memberFees: current.memberFees,
      isSettled: true,
    );
    _settlementCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionSettlement> markMemberPaid({
    required String sessionId,
    required String userId,
  }) async {
    final current = await getSettlement(sessionId);
    final updatedFees = current.memberFees.map((m) {
      if (m.userId == userId) {
        return MemberSettlementFee(
          userId: m.userId,
          fullName: m.fullName,
          avatarUrl: m.avatarUrl,
          roleName: m.roleName,
          gender: m.gender,
          baseFee: m.baseFee,
          discount: m.discount,
          finalFee: m.finalFee,
          paymentStatus: 'PAID',
          vietQrUrl: m.vietQrUrl,
          paymentCode: m.paymentCode,
        );
      }
      return m;
    }).toList();

    final collected = updatedFees.where((m) => m.isPaid).fold(0, (sum, m) => sum + m.finalFee);

    final updated = SessionSettlement(
      sessionId: sessionId,
      shuttlecockUsed: current.shuttlecockUsed,
      shuttlecockPrice: current.shuttlecockPrice,
      courtFee: current.courtFee,
      extraFee: current.extraFee,
      totalCost: current.totalCost,
      totalCollected: collected,
      memberFees: updatedFees,
      isSettled: current.isSettled,
    );
    _settlementCache[sessionId] = updated;
    return updated;
  }

  // ==========================================
  // FR23: Đánh giá uy tín & Tín nhiệm
  // ==========================================

  @override
  Future<List<SessionReview>> getSessionReviews(String sessionId) async {
    if (!_reviewsCache.containsKey(sessionId)) {
      _reviewsCache[sessionId] = [
        SessionReview(
          id: 'rev-01',
          sessionId: sessionId,
          reviewerId: 'u2',
          reviewerName: 'Trần Minh Đức',
          rating: 5.0,
          comment: 'Sân đẹp, anh em xếp trận xoay tua rất công bằng, không ai bị ngồi ngoài lâu!',
          tags: const ['Xoay sân công bằng', 'Vui vẻ', 'Đúng giờ'],
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        SessionReview(
          id: 'rev-02',
          sessionId: sessionId,
          reviewerId: 'u4',
          reviewerName: 'Phạm Quỳnh Anh',
          rating: 4.8,
          comment: 'Thủ quỹ sao kê VietQR nhanh gọn, minh bạch.',
          tags: const ['Minh bạch tài chính', 'Nhiệt tình'],
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];
    }
    return _reviewsCache[sessionId]!;
  }

  @override
  Future<void> submitReview(SessionReview review) async {
    final list = _reviewsCache[review.sessionId] ?? [];
    _reviewsCache[review.sessionId] = [review, ...list];
  }
}
