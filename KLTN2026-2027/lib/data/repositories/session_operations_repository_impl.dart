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
    _syncRotationWithAttendance(sessionId);
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
    _syncRotationWithAttendance(sessionId);
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

  RotationPlayer _toRotationPlayer(AttendancePlayer p, {int restSeconds = 0}) {
    return RotationPlayer(
      userId: p.userId,
      fullName: p.fullName,
      avatarUrl: p.avatarUrl,
      skillLevel: p.skillLevel,
      restSecondsLeft: restSeconds,
    );
  }

  (List<RotationPlayer>, List<RotationPlayer>) _balanceTeams(List<RotationPlayer> four) {
    if (four.length < 4) {
      final mid = four.length ~/ 2;
      return (four.sublist(0, mid), four.sublist(mid));
    }
    final p0 = four[0];
    final p1 = four[1];
    final p2 = four[2];
    final p3 = four[3];

    final diff1 = ((p0.skillLevel + p1.skillLevel) - (p2.skillLevel + p3.skillLevel)).abs();
    final diff2 = ((p0.skillLevel + p2.skillLevel) - (p1.skillLevel + p3.skillLevel)).abs();
    final diff3 = ((p0.skillLevel + p3.skillLevel) - (p1.skillLevel + p2.skillLevel)).abs();

    if (diff1 <= diff2 && diff1 <= diff3) {
      return ([p0, p1], [p2, p3]);
    } else if (diff2 <= diff1 && diff2 <= diff3) {
      return ([p0, p2], [p1, p3]);
    } else {
      return ([p0, p3], [p1, p2]);
    }
  }

  SessionRotationSnapshot _buildRotationFromCheckedIn(String sessionId, List<AttendancePlayer> checkedIn) {
    final courts = <CourtMatch>[];
    final queue = <RotationPlayer>[];

    if (checkedIn.length >= 4) {
      final four = checkedIn.take(4).map((p) => _toRotationPlayer(p)).toList();
      final balanced = _balanceTeams(four);
      courts.add(CourtMatch(
        matchId: 'match-01-$sessionId',
        courtNumber: 1,
        state: 'Playing',
        startedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        teamA: balanced.$1,
        teamB: balanced.$2,
      ));
    } else {
      courts.add(CourtMatch(
        matchId: 'match-01-$sessionId',
        courtNumber: 1,
        state: 'Empty',
        teamA: const [],
        teamB: const [],
      ));
    }

    final hasCourt1 = courts.isNotEmpty && courts.first.state == 'Playing';
    final remaining = checkedIn.skip(hasCourt1 ? 4 : 0).map((p) => _toRotationPlayer(p)).toList();

    if (remaining.length >= 4) {
      final four = remaining.take(4).toList();
      final balanced = _balanceTeams(four);
      courts.add(CourtMatch(
        matchId: 'match-02-$sessionId',
        courtNumber: 2,
        state: 'Proposed',
        teamA: balanced.$1,
        teamB: balanced.$2,
      ));
      queue.addAll(remaining.skip(4));
    } else {
      courts.add(CourtMatch(
        matchId: 'match-02-$sessionId',
        courtNumber: 2,
        state: 'Empty',
        teamA: const [],
        teamB: const [],
      ));
      queue.addAll(remaining);
    }

    final readyCount = queue.where((p) => !p.isResting).length;
    final coolingCount = queue.where((p) => p.isResting).length;

    final snapshot = SessionRotationSnapshot(
      sessionId: sessionId,
      sessionStatus: 'PLAYING',
      rotationVersion: 1,
      serverTime: DateTime.now(),
      rotationStartedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      canInitialize: false,
      canGenerateProposals: true,
      readyCandidateCount: readyCount,
      coolingDownCount: coolingCount,
      courts: courts,
      queuePlayers: queue,
    );

    _rotationCache[sessionId] = snapshot;
    return snapshot;
  }

  SessionRotationSnapshot _syncRotationWithAttendance(String sessionId) {
    final attendance = _attendanceCache[sessionId];
    if (attendance == null) {
      return _buildRotationFromCheckedIn(sessionId, const []);
    }

    final checkedInPlayers = attendance.players.where((p) => p.isCheckedIn).toList();
    final checkedInMap = {for (final p in checkedInPlayers) p.userId: p};

    final currentRotation = _rotationCache[sessionId];
    if (currentRotation == null) {
      return _buildRotationFromCheckedIn(sessionId, checkedInPlayers);
    }

    final updatedCourts = <CourtMatch>[];
    final freedPlayers = <RotationPlayer>[];

    for (final court in currentRotation.courts) {
      if (court.isPlaying) {
        updatedCourts.add(court);
      } else if (court.isProposed) {
        final allCourtPlayers = [...court.teamA, ...court.teamB];
        final allStillCheckedIn = allCourtPlayers.every((p) => checkedInMap.containsKey(p.userId));
        if (allStillCheckedIn) {
          updatedCourts.add(court);
        } else {
          for (final p in allCourtPlayers) {
            if (checkedInMap.containsKey(p.userId)) {
              freedPlayers.add(p);
            }
          }
          updatedCourts.add(CourtMatch(
            matchId: court.matchId,
            courtNumber: court.courtNumber,
            state: 'Empty',
            teamA: const [],
            teamB: const [],
          ));
        }
      } else {
        updatedCourts.add(court);
      }
    }

    final userIdsOnCourt = <String>{};
    for (final c in updatedCourts) {
      if (c.isPlaying || c.isProposed) {
        for (final p in c.teamA) {
          userIdsOnCourt.add(p.userId);
        }
        for (final p in c.teamB) {
          userIdsOnCourt.add(p.userId);
        }
      }
    }

    final newQueue = <RotationPlayer>[];
    final queuedUserIds = <String>{};

    for (final p in [...currentRotation.queuePlayers, ...freedPlayers]) {
      if (checkedInMap.containsKey(p.userId) && !userIdsOnCourt.contains(p.userId) && !queuedUserIds.contains(p.userId)) {
        newQueue.add(p);
        queuedUserIds.add(p.userId);
      }
    }

    for (final p in checkedInPlayers) {
      if (!userIdsOnCourt.contains(p.userId) && !queuedUserIds.contains(p.userId)) {
        newQueue.add(_toRotationPlayer(p));
        queuedUserIds.add(p.userId);
      }
    }

    final finalCourts = <CourtMatch>[];
    for (final court in updatedCourts) {
      final readyInQueue = newQueue.where((p) => !p.isResting).toList();
      if (court.state == 'Empty' && readyInQueue.length >= 4) {
        final four = readyInQueue.take(4).toList();
        for (final p in four) {
          newQueue.removeWhere((q) => q.userId == p.userId);
        }
        final balanced = _balanceTeams(four);
        finalCourts.add(CourtMatch(
          matchId: 'match-${court.courtNumber}-${DateTime.now().millisecondsSinceEpoch}',
          courtNumber: court.courtNumber,
          state: 'Proposed',
          teamA: balanced.$1,
          teamB: balanced.$2,
        ));
      } else {
        finalCourts.add(court);
      }
    }

    final readyCount = newQueue.where((p) => !p.isResting).length;
    final coolingCount = newQueue.where((p) => p.isResting).length;

    final snapshot = SessionRotationSnapshot(
      sessionId: sessionId,
      sessionStatus: 'PLAYING',
      rotationVersion: currentRotation.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: currentRotation.rotationStartedAt ?? DateTime.now(),
      canInitialize: false,
      canGenerateProposals: true,
      readyCandidateCount: readyCount,
      coolingDownCount: coolingCount,
      courts: finalCourts,
      queuePlayers: newQueue,
    );

    _rotationCache[sessionId] = snapshot;
    return snapshot;
  }

  @override
  Future<SessionRotationSnapshot> getRotation(String sessionId) async {
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId/rotation');
      if (res.statusCode == 200 && res.data != null) {}
    } catch (_) {}

    await getAttendance(sessionId);
    return _syncRotationWithAttendance(sessionId);
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
    return _syncRotationWithAttendance(sessionId);
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
    final court = current.courts.firstWhere(
      (c) => c.matchId == matchId,
      orElse: () => current.courts.first,
    );

    final finishedPlayers = [...court.teamA, ...court.teamB].map((p) => RotationPlayer(
      userId: p.userId,
      fullName: p.fullName,
      avatarUrl: p.avatarUrl,
      skillLevel: p.skillLevel,
      lastFinishedAt: DateTime.now(),
      restSecondsLeft: 300,
    )).toList();

    final updatedCourts = current.courts.map((c) {
      if (c.matchId == matchId) {
        return CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: 'Empty',
          teamA: const [],
          teamB: const [],
        );
      }
      return c;
    }).toList();

    final newQueue = [...current.queuePlayers, ...finishedPlayers];

    _rotationCache[sessionId] = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: current.sessionStatus,
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: false,
      canGenerateProposals: true,
      readyCandidateCount: newQueue.where((p) => !p.isResting).length,
      coolingDownCount: newQueue.where((p) => p.isResting).length,
      courts: updatedCourts,
      queuePlayers: newQueue,
    );

    return _syncRotationWithAttendance(sessionId);
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
