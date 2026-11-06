// lib/data/repositories/session_operations_repository_impl.dart

import 'package:dio/dio.dart';
import '../../domain/entities/session/session_attendance.dart';
import '../../domain/entities/session/session_review.dart';
import '../../domain/entities/session/session_rotation.dart';
import '../../domain/entities/session/session_settlement.dart';
import '../../domain/enums/session_enums.dart';
import '../../domain/repositories/session_operations_repository.dart';
import '../../domain/utils/session_fee_calculator.dart';
import '../dto/session/session_detail_dto.dart';
import '../dto/session/session_settlement_dto.dart';
import '../mapper/session_settlement_mapper.dart';

class SessionOperationsRepositoryImpl implements SessionOperationsRepository {
  final Dio dio;

  final Map<String, SessionAttendanceSnapshot> _attendanceCache = {};
  final Map<String, SessionRotationSnapshot> _rotationCache = {};
  final Map<String, SessionSettlement> _settlementCache = {};
  final Map<String, List<SessionReview>> _reviewsCache = {};

  SessionOperationsRepositoryImpl({required this.dio});

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    return DateTime.tryParse(str)?.toLocal();
  }

  static Map<String, dynamic>? _extractMapPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw['result'] is Map) {
        return Map<String, dynamic>.from(raw['result'] as Map);
      }
      if (raw['data'] is Map) {
        return Map<String, dynamic>.from(raw['data'] as Map);
      }
      return raw;
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map['result'] is Map) {
        return Map<String, dynamic>.from(map['result'] as Map);
      }
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }
    return null;
  }

  static String _normalizeAttendanceStatus(dynamic rawStatus, {bool hasCheckinAt = false}) {
    final normalized = rawStatus?.toString().trim().toUpperCase() ?? '';
    if (normalized == '4' || normalized == 'CHECKED_IN') {
      return 'CHECKED_IN';
    }
    if (normalized == '5' || normalized == 'NO_SHOW') {
      return 'NO_SHOW';
    }
    if (normalized == '2' || normalized == 'WAITING') {
      return 'WAITING';
    }
    if (normalized == '3' || normalized == 'ABSENT') {
      return 'ABSENT';
    }
    if (hasCheckinAt) {
      return 'CHECKED_IN';
    }
    return 'CONFIRMED';
  }

  static bool _isConfirmedParticipantStatus(String normalizedStatus) {
    return normalizedStatus == 'CONFIRMED' ||
        normalizedStatus == 'CHECKED_IN' ||
        normalizedStatus == 'NO_SHOW';
  }

  SessionAttendanceSnapshot _parseAttendanceSnapshot(
    Map<String, dynamic> payload, {
    required String fallbackSessionId,
  }) {
    final existingCache = _attendanceCache[fallbackSessionId];
    final localWalkIns = existingCache?.players.where((p) => p.isWalkIn).toList() ?? const <AttendancePlayer>[];

    final rawPlayers = payload['players'];
    final parsedPlayers = <AttendancePlayer>[];
    final seenUserIds = <String>{};

    if (rawPlayers is List) {
      for (final item in rawPlayers) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final checkinAt = _parseDateTime(map['checkinAt']);
        final status = _normalizeAttendanceStatus(map['status'], hasCheckinAt: checkinAt != null);
        if (!_isConfirmedParticipantStatus(status)) {
          continue;
        }
        final userId = map['userId']?.toString() ?? '';
        if (userId.isEmpty) continue;
        seenUserIds.add(userId);
        final skill = SkillLevel.fromString(map['skillLevel']);
        parsedPlayers.add(
          AttendancePlayer(
            userId: userId,
            bookingId: map['bookingId']?.toString() ?? '',
            fullName: map['fullName']?.toString() ?? '',
            avatarUrl: map['avatarUrl']?.toString(),
            status: status,
            checkinAt: status == 'CHECKED_IN' ? checkinAt : null,
            bookedAt: _parseDateTime(map['bookedAt']) ??
                _parseDateTime(map['attendanceMarkedAt']) ??
                DateTime.now(),
            skillLevel: skill.level,
            isReady: _parseBool(map['isReady'], defaultValue: status == 'CHECKED_IN'),
          ),
        );
      }
    }

    for (final walkIn in localWalkIns) {
      if (!seenUserIds.contains(walkIn.userId)) {
        parsedPlayers.add(walkIn);
      }
    }

    final startTime = _parseDateTime(payload['startTime']) ??
        existingCache?.startTime ??
        DateTime.now().subtract(const Duration(minutes: 15));
    final endTime = _parseDateTime(payload['endTime']) ??
        existingCache?.endTime ??
        DateTime.now().add(const Duration(hours: 2));
    final presentCount = parsedPlayers.where((p) => p.isCheckedIn).length;
    final noShowCount = parsedPlayers.where((p) => p.isNoShow).length;
    final notArrivedCount = parsedPlayers.where((p) => p.isNotArrived).length;
    final readyCount = parsedPlayers.where((p) => p.isCheckedIn && p.isReady).length;
    final now = DateTime.now();
    final defaultCanEdit =
        now.isAfter(startTime.subtract(const Duration(hours: 1))) && now.isBefore(endTime);
    final canEdit = payload.containsKey('canEdit')
        ? _parseBool(payload['canEdit'], defaultValue: defaultCanEdit)
        : defaultCanEdit;
    final canStartRotation = payload.containsKey('canStartRotation')
        ? (_parseBool(payload['canStartRotation']) || presentCount >= 4)
        : presentCount >= 4;

    return SessionAttendanceSnapshot(
      sessionId: payload['sessionId']?.toString() ?? fallbackSessionId,
      groupId: payload['groupId']?.toString() ?? existingCache?.groupId ?? '',
      startTime: startTime,
      endTime: endTime,
      maxPlayers: _parseInt(payload['maxPlayers'], defaultValue: existingCache?.maxPlayers ?? 12),
      presentCount: presentCount,
      notArrivedCount: notArrivedCount,
      noShowCount: noShowCount,
      waitlistCount: _parseInt(payload['waitlistCount'], defaultValue: existingCache?.waitlistCount ?? 0),
      readyCount: readyCount,
      canEdit: canEdit,
      canStartRotation: canStartRotation,
      attendanceCompletedAt:
          _parseDateTime(payload['attendanceCompletedAt']) ?? existingCache?.attendanceCompletedAt,
      attendanceCompletedBy:
          payload['attendanceCompletedBy']?.toString() ?? existingCache?.attendanceCompletedBy,
      players: parsedPlayers,
    );
  }

  Future<SessionAttendanceSnapshot?> _buildAttendanceFromSessionDetail(String sessionId) async {
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId');
      if (res.statusCode != 200 || res.data == null) return null;
      final payload = _extractMapPayload(res.data);
      if (payload == null) return null;

      final detailDto = SessionDetailDto.fromJson(payload);
      final existingCache = _attendanceCache[sessionId];
      final cachedByUser = <String, AttendancePlayer>{
        if (existingCache != null)
          for (final p in existingCache.players) p.userId: p,
      };

      final players = <AttendancePlayer>[];
      final seenUserIds = <String>{};

      for (final booking in detailDto.confirmedPlayers) {
        final checkinAt = _parseDateTime(booking.checkinAt);
        final statusFromDetail = _normalizeAttendanceStatus(
          booking.status,
          hasCheckinAt: checkinAt != null,
        );
        if (!_isConfirmedParticipantStatus(statusFromDetail)) {
          continue;
        }
        seenUserIds.add(booking.userId);
        final cached = cachedByUser[booking.userId];
        final effectiveStatus = cached != null && (cached.isCheckedIn || cached.isNoShow)
            ? cached.status
            : statusFromDetail;
        final effectiveCheckinAt = effectiveStatus == 'CHECKED_IN'
            ? (checkinAt ?? cached?.checkinAt)
            : null;
        final skill = SkillLevel.fromString(booking.skillLevel);

        players.add(
          AttendancePlayer(
            userId: booking.userId,
            bookingId: booking.bookingId,
            fullName: booking.fullName,
            avatarUrl: booking.avatarUrl,
            status: effectiveStatus,
            checkinAt: effectiveCheckinAt,
            bookedAt: _parseDateTime(booking.bookedAt) ?? DateTime.now(),
            skillLevel: skill.level,
            isReady: effectiveStatus == 'CHECKED_IN',
          ),
        );
      }

      if (existingCache != null) {
        for (final walkIn in existingCache.players.where((p) => p.isWalkIn)) {
          if (!seenUserIds.contains(walkIn.userId)) {
            players.add(walkIn);
          }
        }
      }

      final startTime = _parseDateTime(detailDto.session.startTime) ??
          DateTime.now().subtract(const Duration(minutes: 15));
      final endTime = _parseDateTime(detailDto.session.endTime) ??
          DateTime.now().add(const Duration(hours: 2));
      final sessionStatus = SessionStatus.fromString(detailDto.session.status);
      final now = DateTime.now();
      final isEditableStatus = sessionStatus == SessionStatus.open ||
          sessionStatus == SessionStatus.locked ||
          sessionStatus == SessionStatus.playing;
      final isWithinWindow =
          now.isAfter(startTime.subtract(const Duration(hours: 1))) && now.isBefore(endTime);
      final canEdit = isEditableStatus && (isWithinWindow || sessionStatus == SessionStatus.playing);

      final presentCount = players.where((p) => p.isCheckedIn).length;
      final noShowCount = players.where((p) => p.isNoShow).length;
      final notArrivedCount = players.where((p) => p.isNotArrived).length;

      return SessionAttendanceSnapshot(
        sessionId: detailDto.session.id.isNotEmpty ? detailDto.session.id : sessionId,
        groupId: detailDto.session.groupId,
        startTime: startTime,
        endTime: endTime,
        maxPlayers: detailDto.session.maxPlayers > 0 ? detailDto.session.maxPlayers : 12,
        presentCount: presentCount,
        notArrivedCount: notArrivedCount,
        noShowCount: noShowCount,
        waitlistCount: detailDto.waitingQueue.isNotEmpty
            ? detailDto.waitingQueue.length
            : detailDto.session.waitingCount,
        readyCount: presentCount,
        canEdit: canEdit,
        canStartRotation: presentCount >= 4,
        attendanceCompletedAt: existingCache?.attendanceCompletedAt,
        attendanceCompletedBy: existingCache?.attendanceCompletedBy,
        players: players,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SessionAttendanceSnapshot> getAttendance(String sessionId) async {
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId/attendance');
      if (res.statusCode == 200 && res.data != null) {
        final payload = _extractMapPayload(res.data);
        if (payload != null) {
          final snapshot = _parseAttendanceSnapshot(payload, fallbackSessionId: sessionId);
          _attendanceCache[sessionId] = snapshot;
          return snapshot;
        }
      }
    } catch (_) {}

    final fromDetail = await _buildAttendanceFromSessionDetail(sessionId);
    if (fromDetail != null) {
      _attendanceCache[sessionId] = fromDetail;
      return fromDetail;
    }

    if (_attendanceCache.containsKey(sessionId)) {
      return _attendanceCache[sessionId]!;
    }

    final emptySnapshot = SessionAttendanceSnapshot(
      sessionId: sessionId,
      groupId: '',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      maxPlayers: 12,
      presentCount: 0,
      notArrivedCount: 0,
      noShowCount: 0,
      waitlistCount: 0,
      readyCount: 0,
      canEdit: true,
      canStartRotation: false,
      players: const [],
    );
    _attendanceCache[sessionId] = emptySnapshot;
    return emptySnapshot;
  }

  @override
  Future<SessionAttendanceSnapshot> updateAttendanceStatus({
    required String sessionId,
    required String userId,
    required String status,
  }) async {
    try {
      final res = await dio.put(
        '/api/v1/sessions/$sessionId/attendance/$userId',
        data: {'status': status},
      );
      if (res.statusCode == 200 && res.data != null) {
        final payload = _extractMapPayload(res.data);
        if (payload != null) {
          final snapshot = _parseAttendanceSnapshot(payload, fallbackSessionId: sessionId);
          _attendanceCache[sessionId] = snapshot;
          _syncRotationWithAttendance(sessionId);
          return snapshot;
        }
      }
    } catch (_) {}

    final current = _attendanceCache[sessionId] ?? await getAttendance(sessionId);
    final updatedPlayers = current.players.map((p) {
      if (p.userId == userId) {
        final isCheckIn = status == 'CHECKED_IN';
        return p.copyWith(
          status: status,
          checkinAt: isCheckIn ? DateTime.now() : null,
          clearCheckinAt: !isCheckIn,
          isReady: isCheckIn,
        );
      }
      return p;
    }).toList();

    final present = updatedPlayers.where((p) => p.isCheckedIn).length;
    final noShow = updatedPlayers.where((p) => p.isNoShow).length;
    final notArrived = updatedPlayers.where((p) => p.isNotArrived).length;

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
      final res = await dio.post('/api/v1/sessions/$sessionId/attendance/walk-ins', data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      });
      if (res.statusCode == 200 && res.data != null) {
        final payload = _extractMapPayload(res.data);
        if (payload != null) {
          final snapshot = _parseAttendanceSnapshot(payload, fallbackSessionId: sessionId);
          _attendanceCache[sessionId] = snapshot;
          _syncRotationWithAttendance(sessionId);
          return snapshot;
        }
      }
    } catch (_) {}

    final current = _attendanceCache[sessionId] ?? await getAttendance(sessionId);
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
    final notArrived = updatedPlayers.where((p) => p.isNotArrived).length;

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
      final res = await dio.post('/api/v1/sessions/$sessionId/attendance/complete');
      if (res.statusCode == 200 && res.data != null) {
        final payload = _extractMapPayload(res.data);
        if (payload != null) {
          final snapshot = _parseAttendanceSnapshot(payload, fallbackSessionId: sessionId);
          _attendanceCache[sessionId] = snapshot;
          return snapshot;
        }
      }
    } catch (_) {}

    final current = _attendanceCache[sessionId] ?? await getAttendance(sessionId);
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
      canEdit: current.canEdit,
      canStartRotation: current.presentCount >= 4,
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

  @override
  Future<SessionRotationSnapshot> pausePlayer({
    required String sessionId,
    required String userId,
    required bool isPaused,
  }) async {
    try {
      await dio.put('/api/v1/sessions/$sessionId/rotation/players/$userId/pause', data: {'isPaused': isPaused});
    } catch (_) {}

    final current = await getRotation(sessionId);
    final updatedQueue = current.queuePlayers.map((p) {
      if (p.userId == userId) {
        return RotationPlayer(
          userId: p.userId,
          fullName: p.fullName,
          avatarUrl: p.avatarUrl,
          skillLevel: p.skillLevel,
          lastFinishedAt: p.lastFinishedAt,
          restSecondsLeft: p.restSecondsLeft,
          isPaused: isPaused,
        );
      }
      return p;
    }).toList();

    final updated = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: current.sessionStatus,
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: current.canInitialize,
      canGenerateProposals: current.canGenerateProposals,
      readyCandidateCount: updatedQueue.where((p) => !p.isResting && !p.isPaused).length,
      coolingDownCount: updatedQueue.where((p) => p.isResting || p.isPaused).length,
      courts: current.courts,
      queuePlayers: updatedQueue,
    );
    _rotationCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionRotationSnapshot> restoreProposal({
    required String sessionId,
    required String matchId,
  }) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/matches/$matchId/restore-proposal');
    } catch (_) {}

    return getRotation(sessionId);
  }

  @override
  Future<SessionRotationSnapshot> swapMatchPlayers({
    required String sessionId,
    required String matchId,
    required List<String> teamAUserIds,
    required List<String> teamBUserIds,
  }) async {
    try {
      await dio.put(
        '/api/v1/sessions/$sessionId/matches/$matchId/manual-lineup',
        data: {
          'teamA': teamAUserIds,
          'teamB': teamBUserIds,
        },
      );
    } catch (_) {}

    final current = await getRotation(sessionId);
    final allPlayersMap = {
      for (final c in current.courts) ...{
        for (final p in [...c.teamA, ...c.teamB]) p.userId: p
      },
      for (final p in current.queuePlayers) p.userId: p,
    };

    final newTeamA = teamAUserIds.map((id) => allPlayersMap[id]).whereType<RotationPlayer>().toList();
    final newTeamB = teamBUserIds.map((id) => allPlayersMap[id]).whereType<RotationPlayer>().toList();

    final updatedCourts = current.courts.map((c) {
      if (c.matchId == matchId) {
        return CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: c.state,
          startedAt: c.startedAt,
          teamA: newTeamA,
          teamB: newTeamB,
          isManualSwapped: true,
        );
      }
      return c;
    }).toList();

    final usedUserIds = <String>{
      for (final c in updatedCourts) ...{
        for (final p in [...c.teamA, ...c.teamB]) p.userId
      }
    };

    final updatedQueue = current.queuePlayers.where((p) => !usedUserIds.contains(p.userId)).toList();

    final updated = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: current.sessionStatus,
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: current.canInitialize,
      canGenerateProposals: current.canGenerateProposals,
      readyCandidateCount: updatedQueue.where((p) => !p.isResting && !p.isPaused).length,
      coolingDownCount: updatedQueue.where((p) => p.isResting || p.isPaused).length,
      courts: updatedCourts,
      queuePlayers: updatedQueue,
    );
    _rotationCache[sessionId] = updated;
    return updated;
  }

  // ==========================================
  // FR18 - FR21: Hạch toán vật tư & Chia tiền VietQR
  // ==========================================

  @override
  Future<SessionSettlement> getSettlement(String sessionId) async {
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId/settlement');
      if (res.statusCode == 200 && res.data != null) {
        final payload = res.data is Map<String, dynamic> && res.data.containsKey('result') ? res.data['result'] : res.data;
        if (payload is Map<String, dynamic>) {
          final entity = SessionSettlementDto.fromJson(payload).toEntity();
          _settlementCache[sessionId] = entity;
          return entity;
        }
      }
    } catch (_) {
      // Fallback local cache
    }

    if (!_settlementCache.containsKey(sessionId)) {
      final attendance = await getAttendance(sessionId);
      final activePlayers = attendance.players.where((p) => !p.isNoShow).toList();
      final totalCost = 300000;
      final feePerPlayer = activePlayers.isNotEmpty
          ? ((totalCost / activePlayers.length) / 1000).ceil() * 1000
          : 0;
      _settlementCache[sessionId] = SessionSettlement(
        sessionId: sessionId,
        shuttlecockUsed: 0,
        shuttlecockPrice: 25000,
        courtFee: totalCost,
        extraFee: 0,
        totalCost: totalCost,
        totalCollected: 0,
        isSettled: false,
        memberFees: activePlayers
            .map(
              (p) => MemberSettlementFee(
                userId: p.userId,
                fullName: p.fullName,
                avatarUrl: p.avatarUrl,
                roleName: p.isWalkIn ? 'Khách vãng lai' : 'Hội viên',
                gender: 'MALE',
                baseFee: feePerPlayer,
                discount: 0,
                finalFee: feePerPlayer,
                paymentStatus: 'PENDING',
                vietQrUrl: '',
                paymentCode: 'PAY_${p.userId}',
              ),
            )
            .toList(),
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
    try {
      final res = await dio.post(
        '/api/v1/sessions/$sessionId/settlement',
        data: {
          'shuttlecockUsed': shuttlecockUsed,
          'shuttlecockPrice': 25000,
          'extraFee': extraFee,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final payload = res.data is Map<String, dynamic> && res.data.containsKey('result') ? res.data['result'] : res.data;
        if (payload is Map<String, dynamic>) {
          final entity = SessionSettlementDto.fromJson(payload).toEntity();
          _settlementCache[sessionId] = entity;
          return entity;
        }
      }
    } catch (_) {
      // Fallback local engine calculation
    }

    final current = await getSettlement(sessionId);
    final totalShuttle = shuttlecockUsed * current.shuttlecockPrice;
    final total = current.courtFee + totalShuttle + extraFee;

    final femaleCount = current.memberFees.where((m) => m.gender.toUpperCase() == 'FEMALE' || m.gender == '2').length;
    final feeResult = SessionFeeCalculator.calculate(
      totalCost: total,
      totalPlayers: current.memberFees.isNotEmpty ? current.memberFees.length : 1,
      femaleCount: femaleCount,
      femaleDiscount: 10000,
      roundRule: 1000,
    );

    final recalculatedFees = current.memberFees.map((m) {
      final isMonthly = m.roleName.contains('tháng') || m.roleName.contains('Monthly');
      if (isMonthly) {
        return m.copyWith(finalFee: 0, discount: m.baseFee);
      }
      final isFemale = m.gender.toUpperCase() == 'FEMALE' || m.gender == '2';
      return m.copyWith(
        baseFee: feeResult.maleFee,
        discount: isFemale ? (feeResult.maleFee - feeResult.femaleFee) : 0,
        finalFee: isFemale ? feeResult.femaleFee : feeResult.maleFee,
      );
    }).toList();

    final updated = SessionSettlement(
      sessionId: sessionId,
      shuttlecockUsed: shuttlecockUsed,
      shuttlecockPrice: current.shuttlecockPrice,
      courtFee: current.courtFee,
      extraFee: extraFee,
      totalCost: total,
      totalCollected: recalculatedFees.where((m) => m.isPaid).fold(0, (sum, m) => sum + m.finalFee),
      memberFees: recalculatedFees,
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
    try {
      final res = await dio.post('/api/v1/sessions/$sessionId/settlement/members/$userId/pay');
      if (res.statusCode == 200 && res.data != null) {
        final payload = res.data is Map<String, dynamic> && res.data.containsKey('result') ? res.data['result'] : res.data;
        if (payload is Map<String, dynamic>) {
          final entity = SessionSettlementDto.fromJson(payload).toEntity();
          _settlementCache[sessionId] = entity;
          return entity;
        }
      }
    } catch (_) {
      // Fallback local update
    }

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
