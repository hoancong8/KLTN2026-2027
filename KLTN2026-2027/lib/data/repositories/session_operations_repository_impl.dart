// lib/data/repositories/session_operations_repository_impl.dart

import 'package:dio/dio.dart';
import '../../domain/entities/payment/personal_fee.dart';
import '../../domain/entities/session/session_attendance.dart';
import '../../domain/entities/session/session_review.dart';
import '../../domain/entities/session/session_rotation.dart';
import '../../domain/entities/session/session_settlement.dart';
import '../../domain/enums/session_enums.dart';
import '../../domain/repositories/session_operations_repository.dart';
import '../../domain/utils/gender_helper.dart';
import '../../domain/utils/session_fee_calculator.dart';
import '../datasource/local/club_schedule_local_datasource.dart';
import '../dto/club/club_detail_dto.dart';
import '../dto/payment/payment_dto.dart';
import '../dto/session/session_detail_dto.dart';
import '../dto/session/session_settlement_dto.dart';
import '../mapper/payment_mapper.dart';
import '../mapper/session_settlement_mapper.dart';

class SessionOperationsRepositoryImpl implements SessionOperationsRepository {
  final Dio dio;

  final Map<String, SessionAttendanceSnapshot> _attendanceCache = {};
  final Map<String, SessionRotationSnapshot> _rotationCache = {};
  final Map<String, SessionSettlement> _settlementCache = {};
  final Map<String, List<SessionReview>> _reviewsCache = {};
  final Map<String, int> _sessionCourtCountCache = {};
  final Map<String, String> _sessionGroupIdCache = {};
  final Map<String, ThreePlayerMatchMode> _threePlayerModeCache = {};

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
        final fullName = map['fullName']?.toString() ?? '';
        final rawGender = map['gender']?.toString();
        final isFemale = GenderHelper.isFemale(genderString: rawGender, fullName: fullName);
        final gender = isFemale ? 'FEMALE' : 'MALE';
        final rawRole = map['roleName']?.toString() ?? map['role']?.toString() ?? map['priceType']?.toString() ?? '';
        final role = rawRole.isNotEmpty ? rawRole : 'MEMBER_DAILY';
        parsedPlayers.add(
          AttendancePlayer(
            userId: userId,
            bookingId: map['bookingId']?.toString() ?? '',
            fullName: fullName,
            avatarUrl: map['avatarUrl']?.toString(),
            status: status,
            checkinAt: status == 'CHECKED_IN' ? checkinAt : null,
            bookedAt: _parseDateTime(map['bookedAt']) ??
                _parseDateTime(map['attendanceMarkedAt']) ??
                DateTime.now(),
            skillLevel: skill.level,
            isReady: _parseBool(map['isReady'], defaultValue: status == 'CHECKED_IN'),
            gender: gender,
            roleName: role,
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
        ? (_parseBool(payload['canStartRotation']) || presentCount >= 2)
        : presentCount >= 2;

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
        final isFemale = GenderHelper.isFemale(explicitGender: booking.gender, fullName: booking.fullName);
        final gender = isFemale ? 'FEMALE' : 'MALE';

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
            gender: gender,
            roleName: 'MEMBER_DAILY',
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

      final groupId = detailDto.session.groupId;
      _sessionGroupIdCache[sessionId] = groupId;
      final rawCourtCount = detailDto.session.courtCount;
      final defaults = ClubScheduleLocalDatasource.getDefaultsSync(groupId);
      final effectiveCourtCount = rawCourtCount > 0
          ? rawCourtCount
          : (defaults.courtCount > 0 ? defaults.courtCount : 1);
      _sessionCourtCountCache[sessionId] = effectiveCourtCount;

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
        canStartRotation: presentCount >= 2,
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
      canStartRotation: present >= 2,
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
      canStartRotation: present >= 2,
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
      canStartRotation: current.presentCount >= 2,
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
    if (four.length == 2) {
      return ([four[0]], [four[1]]);
    }
    if (four.length == 3) {
      final p0 = four[0];
      final p1 = four[1];
      final p2 = four[2];
      final d0 = ((p1.skillLevel + p2.skillLevel) - p0.skillLevel).abs();
      final d1 = ((p0.skillLevel + p2.skillLevel) - p1.skillLevel).abs();
      final d2 = ((p0.skillLevel + p1.skillLevel) - p2.skillLevel).abs();

      if (d0 <= d1 && d0 <= d2) {
        return ([p1, p2], [p0]);
      } else if (d1 <= d0 && d1 <= d2) {
        return ([p0, p2], [p1]);
      } else {
        return ([p0, p1], [p2]);
      }
    }
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

  int _getCourtCountSync(String sessionId) {
    if (_sessionCourtCountCache.containsKey(sessionId) && _sessionCourtCountCache[sessionId]! > 0) {
      return _sessionCourtCountCache[sessionId]!;
    }
    final attendance = _attendanceCache[sessionId];
    final groupId = attendance?.groupId ?? _sessionGroupIdCache[sessionId] ?? '';
    if (groupId.isNotEmpty) {
      final defaults = ClubScheduleLocalDatasource.getDefaultsSync(groupId);
      if (defaults.courtCount > 0) {
        _sessionCourtCountCache[sessionId] = defaults.courtCount;
        return defaults.courtCount;
      }
    }
    return 1;
  }

  Future<int> _resolveCourtCount(String sessionId) async {
    final cached = _getCourtCountSync(sessionId);
    if (_sessionCourtCountCache.containsKey(sessionId) && _sessionCourtCountCache[sessionId]! > 0) {
      return _sessionCourtCountCache[sessionId]!;
    }
    final attendance = _attendanceCache[sessionId];
    final groupId = attendance?.groupId ?? _sessionGroupIdCache[sessionId] ?? '';
    if (groupId.isNotEmpty) {
      final defaults = ClubScheduleLocalDatasource.getDefaultsSync(groupId);
      if (defaults.courtCount > 0) {
        _sessionCourtCountCache[sessionId] = defaults.courtCount;
        return defaults.courtCount;
      }
    }
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId');
      if (res.statusCode == 200 && res.data != null) {
        final payload = _extractMapPayload(res.data);
        if (payload != null) {
          final detailDto = SessionDetailDto.fromJson(payload);
          final rawCount = detailDto.session.courtCount;
          final clubId = detailDto.session.groupId;
          _sessionGroupIdCache[sessionId] = clubId;
          int resolvedCount = rawCount;
          if (resolvedCount <= 0 && clubId.isNotEmpty) {
            try {
              final clubRes = await dio.get('/api/v1/clubs/$clubId');
              final cData = _extractMapPayload(clubRes.data);
              if (cData != null) {
                final clubDetail = ClubDetailDto.fromJson(cData);
                if (clubDetail.courtCount > 0) {
                  resolvedCount = clubDetail.courtCount;
                }
              }
            } catch (_) {}
          }
          final defaults = ClubScheduleLocalDatasource.getDefaultsSync(clubId);
          final effective = resolvedCount > 0 ? resolvedCount : (defaults.courtCount > 0 ? defaults.courtCount : 1);
          _sessionCourtCountCache[sessionId] = effective;
          return effective;
        }
      }
    } catch (_) {}
    return cached;
  }

  SessionRotationSnapshot _buildRotationFromCheckedIn(
    String sessionId,
    List<AttendancePlayer> checkedIn, {
    int? courtCount,
    ThreePlayerMatchMode? threePlayerMode,
  }) {
    final mode = threePlayerMode ?? _threePlayerModeCache[sessionId] ?? ThreePlayerMatchMode.twoVsOne;
    final courts = <CourtMatch>[];
    final queue = <RotationPlayer>[];
    final totalCourts = (courtCount != null && courtCount > 0) ? courtCount : _getCourtCountSync(sessionId);

    int assignedPlayerIndex = 0;
    for (int courtIndex = 1; courtIndex <= totalCourts; courtIndex++) {
      final remaining = checkedIn.skip(assignedPlayerIndex).toList();
      List<RotationPlayer>? selected;
      if (remaining.length >= 4) {
        selected = remaining.take(4).map((p) => _toRotationPlayer(p)).toList();
        assignedPlayerIndex += 4;
      } else if (remaining.length == 3) {
        if (mode == ThreePlayerMatchMode.twoVsOne) {
          selected = remaining.take(3).map((p) => _toRotationPlayer(p)).toList();
          assignedPlayerIndex += 3;
        } else {
          selected = remaining.take(2).map((p) => _toRotationPlayer(p)).toList();
          assignedPlayerIndex += 2;
        }
      } else if (remaining.length == 2) {
        selected = remaining.take(2).map((p) => _toRotationPlayer(p)).toList();
        assignedPlayerIndex += 2;
      }

      if (selected != null && selected.isNotEmpty) {
        final balanced = _balanceTeams(selected);
        courts.add(CourtMatch(
          matchId: 'match-0$courtIndex-$sessionId',
          courtNumber: courtIndex,
          state: courtIndex == 1 ? 'Playing' : 'Proposed',
          startedAt: courtIndex == 1 ? DateTime.now().subtract(const Duration(minutes: 8)) : null,
          teamA: balanced.$1,
          teamB: balanced.$2,
        ));
      } else {
        courts.add(CourtMatch(
          matchId: 'match-0$courtIndex-$sessionId',
          courtNumber: courtIndex,
          state: 'Empty',
          teamA: const [],
          teamB: const [],
        ));
      }
    }

    if (assignedPlayerIndex < checkedIn.length) {
      queue.addAll(checkedIn.skip(assignedPlayerIndex).map((p) => _toRotationPlayer(p)));
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
      threePlayerMode: mode,
    );

    _rotationCache[sessionId] = snapshot;
    return snapshot;
  }

  SessionRotationSnapshot _syncRotationWithAttendance(
    String sessionId, {
    int? courtCount,
    ThreePlayerMatchMode? threePlayerMode,
  }) {
    final mode = threePlayerMode ?? _threePlayerModeCache[sessionId] ?? ThreePlayerMatchMode.twoVsOne;
    final totalCourts = (courtCount != null && courtCount > 0) ? courtCount : _getCourtCountSync(sessionId);
    final attendance = _attendanceCache[sessionId];
    if (attendance == null) {
      return _buildRotationFromCheckedIn(sessionId, const [], courtCount: totalCourts, threePlayerMode: mode);
    }

    final checkedInPlayers = attendance.players.where((p) => p.isCheckedIn).toList();
    final checkedInMap = {for (final p in checkedInPlayers) p.userId: p};

    final currentRotation = _rotationCache[sessionId];
    if (currentRotation == null) {
      return _buildRotationFromCheckedIn(sessionId, checkedInPlayers, courtCount: totalCourts, threePlayerMode: mode);
    }

    final updatedCourts = <CourtMatch>[];
    final freedPlayers = <RotationPlayer>[];

    for (final court in currentRotation.courts) {
      if (court.courtNumber > totalCourts) {
        for (final p in [...court.teamA, ...court.teamB]) {
          if (checkedInMap.containsKey(p.userId)) {
            freedPlayers.add(p);
          }
        }
        continue;
      }
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

    final existingCourtNumbers = updatedCourts.map((c) => c.courtNumber).toSet();
    for (int i = 1; i <= totalCourts; i++) {
      if (!existingCourtNumbers.contains(i)) {
        updatedCourts.add(CourtMatch(
          matchId: 'match-0$i-$sessionId',
          courtNumber: i,
          state: 'Empty',
          teamA: const [],
          teamB: const [],
        ));
      }
    }
    updatedCourts.sort((a, b) => a.courtNumber.compareTo(b.courtNumber));

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
      var candidateQueue = newQueue.where((p) => !p.isResting && !p.isPaused).toList();
      if (candidateQueue.length < 2 && newQueue.where((p) => !p.isPaused).length >= 2) {
        candidateQueue = newQueue.where((p) => !p.isPaused).toList()
          ..sort((a, b) => a.restSecondsLeft.compareTo(b.restSecondsLeft));
      }

      if (court.state == 'Empty') {
        List<RotationPlayer>? selected;
        if (candidateQueue.length >= 4) {
          selected = candidateQueue.take(4).toList();
        } else if (candidateQueue.length == 3) {
          if (mode == ThreePlayerMatchMode.twoVsOne) {
            selected = candidateQueue.take(3).toList();
          } else {
            selected = candidateQueue.take(2).toList();
          }
        } else if (candidateQueue.length == 2) {
          selected = candidateQueue.take(2).toList();
        }

        if (selected != null && selected.isNotEmpty) {
          for (final p in selected) {
            newQueue.removeWhere((q) => q.userId == p.userId);
          }
          final balanced = _balanceTeams(selected);
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
      threePlayerMode: mode,
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
    final courtCount = await _resolveCourtCount(sessionId);
    return _syncRotationWithAttendance(sessionId, courtCount: courtCount);
  }

  @override
  Future<SessionRotationSnapshot> initializeRotation(String sessionId) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/rotation/initialize');
    } catch (_) {}
    _rotationCache.remove(sessionId);
    return getRotation(sessionId);
  }

  @override
  Future<SessionRotationSnapshot> generateProposals(String sessionId) async {
    try {
      await dio.post('/api/v1/sessions/$sessionId/rotation/proposals');
    } catch (_) {}
    final courtCount = await _resolveCourtCount(sessionId);
    return _syncRotationWithAttendance(sessionId, courtCount: courtCount);
  }

  @override
  Future<SessionRotationSnapshot> setThreePlayerMode({
    required String sessionId,
    required ThreePlayerMatchMode mode,
  }) async {
    _threePlayerModeCache[sessionId] = mode;
    final courtCount = await _resolveCourtCount(sessionId);
    final current = _rotationCache[sessionId];
    if (current != null) {
      final resetCourts = current.courts.map((c) {
        if (c.isProposed) {
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
      _rotationCache[sessionId] = SessionRotationSnapshot(
        sessionId: current.sessionId,
        sessionStatus: current.sessionStatus,
        rotationVersion: current.rotationVersion + 1,
        serverTime: DateTime.now(),
        rotationStartedAt: current.rotationStartedAt,
        canInitialize: current.canInitialize,
        canGenerateProposals: current.canGenerateProposals,
        readyCandidateCount: current.readyCandidateCount,
        coolingDownCount: current.coolingDownCount,
        courts: resetCourts,
        queuePlayers: current.queuePlayers,
        threePlayerMode: mode,
      );
    }
    return _syncRotationWithAttendance(sessionId, courtCount: courtCount, threePlayerMode: mode);
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
    final current = await getRotation(sessionId);
    try {
      if (teamAUserIds.length == 2 && teamBUserIds.length == 2) {
        await dio.put(
          '/api/v1/sessions/$sessionId/matches/$matchId/manual-lineup',
          data: {
            'teamA': teamAUserIds,
            'teamB': teamBUserIds,
            'expectedRotationVersion': current.rotationVersion,
          },
        );
      }
    } catch (_) {}

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
        final newState = (newTeamA.isNotEmpty || newTeamB.isNotEmpty)
            ? (c.isPlaying ? 'Playing' : 'Proposed')
            : 'Empty';
        return CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: newState,
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

    final allKnownPlayers = allPlayersMap.values.toList();
    final updatedQueue = allKnownPlayers.where((p) => !usedUserIds.contains(p.userId)).toList();

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
      threePlayerMode: current.threePlayerMode,
    );
    _rotationCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionRotationSnapshot> movePlayer({
    required String sessionId,
    required DraggingPlayerPayload payload,
    String? targetCourtMatchId,
    String? targetTeam,
    int? targetSpotIndex,
  }) async {
    final current = await getRotation(sessionId);
    final movedPlayer = payload.player;

    final allPlayersMap = {
      for (final c in current.courts) ...{
        for (final p in [...c.teamA, ...c.teamB]) p.userId: p
      },
      for (final p in current.queuePlayers) p.userId: p,
      movedPlayer.userId: movedPlayer,
    };

    final courtList = current.courts.map((c) {
      return CourtMatch(
        matchId: c.matchId,
        courtNumber: c.courtNumber,
        state: c.state,
        startedAt: c.startedAt,
        teamA: List<RotationPlayer>.from(c.teamA),
        teamB: List<RotationPlayer>.from(c.teamB),
        isManualSwapped: c.isManualSwapped,
      );
    }).toList();

    for (int i = 0; i < courtList.length; i++) {
      final c = courtList[i];
      final newTeamA = c.teamA.where((p) => p.userId != movedPlayer.userId).toList();
      final newTeamB = c.teamB.where((p) => p.userId != movedPlayer.userId).toList();
      if (newTeamA.length != c.teamA.length || newTeamB.length != c.teamB.length) {
        final newState = (newTeamA.isNotEmpty || newTeamB.isNotEmpty)
            ? (c.isPlaying ? 'Playing' : 'Proposed')
            : 'Empty';
        courtList[i] = CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: newState,
          startedAt: c.startedAt,
          teamA: newTeamA,
          teamB: newTeamB,
          isManualSwapped: true,
        );
      }
    }

    if (targetCourtMatchId != null && targetTeam != null) {
      final targetIdx = courtList.indexWhere((c) => c.matchId == targetCourtMatchId);
      if (targetIdx != -1) {
        final target = courtList[targetIdx];
        final isTeamA = targetTeam == 'A';
        final targetTeamPlayers = List<RotationPlayer>.from(isTeamA ? target.teamA : target.teamB);
        final otherTeamPlayers = List<RotationPlayer>.from(isTeamA ? target.teamB : target.teamA);

        if (targetSpotIndex != null && targetSpotIndex < targetTeamPlayers.length) {
          targetTeamPlayers[targetSpotIndex] = movedPlayer;
        } else if (targetTeamPlayers.length < 2) {
          targetTeamPlayers.add(movedPlayer);
        } else {
          targetTeamPlayers[1] = movedPlayer;
        }

        final finalTeamA = isTeamA ? targetTeamPlayers : otherTeamPlayers;
        final finalTeamB = isTeamA ? otherTeamPlayers : targetTeamPlayers;
        final newState = target.isPlaying ? 'Playing' : 'Proposed';

        courtList[targetIdx] = CourtMatch(
          matchId: target.matchId,
          courtNumber: target.courtNumber,
          state: newState,
          startedAt: target.startedAt,
          teamA: finalTeamA,
          teamB: finalTeamB,
          isManualSwapped: true,
        );

        if (finalTeamA.length == 2 && finalTeamB.length == 2) {
          try {
            await dio.put(
              '/api/v1/sessions/$sessionId/matches/${target.matchId}/manual-lineup',
              data: {
                'teamA': finalTeamA.map((p) => p.userId).toList(),
                'teamB': finalTeamB.map((p) => p.userId).toList(),
                'expectedRotationVersion': current.rotationVersion,
              },
            );
          } catch (_) {}
        }
      }
    }

    final userIdsOnCourts = <String>{
      for (final c in courtList) ...{
        for (final p in [...c.teamA, ...c.teamB]) p.userId
      }
    };

    final newQueue = allPlayersMap.values.where((p) => !userIdsOnCourts.contains(p.userId)).toList();

    final updated = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: current.sessionStatus,
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: current.canInitialize,
      canGenerateProposals: current.canGenerateProposals,
      readyCandidateCount: newQueue.where((p) => !p.isResting && !p.isPaused).length,
      coolingDownCount: newQueue.where((p) => p.isResting || p.isPaused).length,
      courts: courtList,
      queuePlayers: newQueue,
      threePlayerMode: current.threePlayerMode,
    );

    _rotationCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionRotationSnapshot> clearCourt({
    required String sessionId,
    required String matchId,
  }) async {
    final current = await getRotation(sessionId);
    final allPlayersMap = {
      for (final c in current.courts) ...{
        for (final p in [...c.teamA, ...c.teamB]) p.userId: p
      },
      for (final p in current.queuePlayers) p.userId: p,
    };

    final courtList = current.courts.map((c) {
      if (c.matchId == matchId) {
        return CourtMatch(
          matchId: c.matchId,
          courtNumber: c.courtNumber,
          state: 'Empty',
          startedAt: null,
          teamA: const [],
          teamB: const [],
          isManualSwapped: false,
        );
      }
      return c;
    }).toList();

    final userIdsOnCourts = <String>{
      for (final c in courtList) ...{
        for (final p in [...c.teamA, ...c.teamB]) p.userId
      }
    };

    final newQueue = allPlayersMap.values.where((p) => !userIdsOnCourts.contains(p.userId)).toList();

    final updated = SessionRotationSnapshot(
      sessionId: current.sessionId,
      sessionStatus: current.sessionStatus,
      rotationVersion: current.rotationVersion + 1,
      serverTime: DateTime.now(),
      rotationStartedAt: current.rotationStartedAt,
      canInitialize: current.canInitialize,
      canGenerateProposals: current.canGenerateProposals,
      readyCandidateCount: newQueue.where((p) => !p.isResting && !p.isPaused).length,
      coolingDownCount: newQueue.where((p) => p.isResting || p.isPaused).length,
      courts: courtList,
      queuePlayers: newQueue,
      threePlayerMode: current.threePlayerMode,
    );

    _rotationCache[sessionId] = updated;
    return updated;
  }

  // ==========================================
  // FR18 - FR21: Hạch toán vật tư & Chia tiền VietQR
  // ==========================================

  @override
  Future<SessionSettlement> getSettlement(String sessionId) async {
    PaymentBankAccount? fetchedBank;
    try {
      final res = await dio.get('/api/v1/sessions/$sessionId/settlement');
      if (res.statusCode == 200 && res.data != null) {
        final payload = res.data is Map<String, dynamic> && res.data.containsKey('result') ? res.data['result'] : res.data;
        if (payload is Map<String, dynamic>) {
          final entity = SessionSettlementDto.fromJson(payload).toEntity();
          if (entity.bankAccount != null) {
            fetchedBank = entity.bankAccount;
          }
          if (entity.memberFees.isNotEmpty || entity.isSettled) {
            _settlementCache[sessionId] = entity;
            return entity;
          }
        }
      }
    } catch (_) {
      // Fallback local cache
    }

    if (!_settlementCache.containsKey(sessionId) || _settlementCache[sessionId]!.memberFees.isEmpty) {
      final attendance = await getAttendance(sessionId);
      final activePlayers = attendance.players.where((p) => !p.isNoShow).toList();

      int totalCost = 0;
      String groupId = '';
      try {
        final sessionRes = await dio.get('/api/v1/sessions/$sessionId');
        if (sessionRes.statusCode == 200 && sessionRes.data != null) {
          final payload = sessionRes.data is Map<String, dynamic> && sessionRes.data.containsKey('result')
              ? sessionRes.data['result']
              : sessionRes.data;
          if (payload is Map<String, dynamic>) {
            final detailDto = SessionDetailDto.fromJson(payload);
            totalCost = detailDto.session.courtRentalCost.round();
            groupId = detailDto.session.groupId;
          }
        }
      } catch (_) {}

      if (fetchedBank == null && groupId.isNotEmpty) {
        try {
          final bankRes = await dio.get('/api/v1/clubs/$groupId/payment-bank-account');
          if (bankRes.statusCode == 200 && bankRes.data != null) {
            final bData = bankRes.data is Map<String, dynamic> && bankRes.data.containsKey('result')
                ? bankRes.data['result']
                : bankRes.data;
            if (bData is Map<String, dynamic>) {
              final bankDto = PaymentBankAccountDto.fromJson(bData);
              fetchedBank = PaymentMapper.toBankAccount(bankDto);
            }
          }
        } catch (_) {}
      }

      if (totalCost == 0 && groupId.isNotEmpty) {
        try {
          final clubRes = await dio.get('/api/v1/clubs/$groupId');
          if (clubRes.statusCode == 200 && clubRes.data != null) {
            final cData = clubRes.data is Map<String, dynamic> && clubRes.data.containsKey('result')
                ? clubRes.data['result']
                : clubRes.data;
            if (cData is Map<String, dynamic>) {
              final clubDetail = ClubDetailDto.fromJson(cData);
              if (clubDetail.courtRentalCost > 0) {
                totalCost = clubDetail.courtRentalCost.round();
              }
            }
          }
        } catch (_) {}
        if (totalCost == 0) {
          final defaults = ClubScheduleLocalDatasource.getDefaultsSync(groupId);
          if (defaults.courtRentalCost > 0) {
            totalCost = defaults.courtRentalCost.round();
          }
        }
      }

      final femaleCount = activePlayers.where((p) => GenderHelper.isFemale(genderString: p.gender, fullName: p.fullName)).length;
      final feeResult = totalCost > 0
          ? SessionFeeCalculator.calculate(
              totalCost: totalCost,
              totalPlayers: activePlayers.isNotEmpty ? activePlayers.length : 1,
              femaleCount: femaleCount,
              femaleDiscount: 10000,
              roundRule: 1000,
            )
          : null;

      _settlementCache[sessionId] = SessionSettlement(
        sessionId: sessionId,
        shuttlecockUsed: 0,
        shuttlecockPrice: 25000,
        courtFee: totalCost,
        extraFee: 0,
        totalCost: totalCost,
        totalCollected: 0,
        isSettled: false,
        bankAccount: fetchedBank ?? _settlementCache[sessionId]?.bankAccount,
        memberFees: activePlayers
            .map(
              (p) {
                final isFemale = GenderHelper.isFemale(genderString: p.gender, fullName: p.fullName);
                final role = p.isWalkIn ? 'GUEST' : (p.roleName.isNotEmpty ? p.roleName : 'MEMBER_DAILY');
                final base = feeResult?.maleFee ?? 0;
                final discount = (feeResult != null && isFemale) ? (feeResult.maleFee - feeResult.femaleFee) : 0;
                final finalFee = isFemale ? (feeResult?.femaleFee ?? 0) : (feeResult?.maleFee ?? 0);
                return MemberSettlementFee(
                  feeId: '',
                  userId: p.userId,
                  fullName: p.fullName,
                  avatarUrl: p.avatarUrl,
                  roleName: role,
                  gender: isFemale ? 'FEMALE' : 'MALE',
                  baseFee: base,
                  discount: discount,
                  finalFee: finalFee,
                  paymentStatus: 'PENDING',
                  vietQrUrl: '',
                  paymentCode: 'PAY_${p.userId}',
                  paidAmount: 0,
                );
              },
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
    int? courtRentalCost,
  }) async {
    final current = await getSettlement(sessionId);
    final courtCost = courtRentalCost ?? current.courtFee;
    final shuttlePrice = current.shuttlecockPrice > 0 ? current.shuttlecockPrice : 25000;

    try {
      final previewRes = await dio.post(
        '/api/v1/sessions/$sessionId/settlement/preview',
        data: {
          'shuttlecockUsed': shuttlecockUsed,
          'shuttlecockPrice': shuttlePrice,
          'courtRentalCost': courtCost,
          'extraExpense': extraFee,
          'overrides': [],
          'confirmRemainingNoShows': true,
        },
      );
      if (previewRes.statusCode == 200 && previewRes.data != null) {
        final pData = previewRes.data is Map<String, dynamic> && previewRes.data.containsKey('result')
            ? previewRes.data['result']
            : previewRes.data;
        final previewToken = pData is Map<String, dynamic>
            ? (pData['previewToken'] ?? pData['PreviewToken'])
            : null;
        if (previewToken is String) {
          final approveRes = await dio.post(
            '/api/v1/sessions/$sessionId/settlement/approve',
            data: {
              'input': {
                'shuttlecockUsed': shuttlecockUsed,
                'shuttlecockPrice': shuttlePrice,
                'courtRentalCost': courtCost,
                'extraExpense': extraFee,
                'overrides': [],
                'confirmRemainingNoShows': true,
              },
              'previewToken': previewToken,
            },
          );
          if (approveRes.statusCode == 200 && approveRes.data != null) {
            final payload = approveRes.data is Map<String, dynamic> && approveRes.data.containsKey('result')
                ? approveRes.data['result']
                : approveRes.data;
            if (payload is Map<String, dynamic>) {
              final entity = SessionSettlementDto.fromJson(payload).toEntity();
              _settlementCache[sessionId] = entity;
              return entity;
            }
          }
        }
      }
    } catch (_) {
      // Fallback local engine calculation
    }

    final totalShuttle = shuttlecockUsed * current.shuttlecockPrice;
    final total = courtCost + totalShuttle + extraFee;

    final femaleCount = current.memberFees.where((m) => GenderHelper.isFemale(genderString: m.gender, fullName: m.fullName)).length;
    final feeResult = total > 0
        ? SessionFeeCalculator.calculate(
            totalCost: total,
            totalPlayers: current.memberFees.isNotEmpty ? current.memberFees.length : 1,
            femaleCount: femaleCount,
            femaleDiscount: 10000,
            roundRule: 1000,
          )
        : null;

    final recalculatedFees = current.memberFees.map((m) {
      final isMonthly = m.roleName.contains('tháng') || m.roleName.contains('Monthly');
      if (isMonthly) {
        return m.copyWith(finalFee: 0, discount: m.baseFee, paidAmount: 0, paymentStatus: 'PAID');
      }
      final isFemale = GenderHelper.isFemale(genderString: m.gender, fullName: m.fullName);
      final maleFee = feeResult?.maleFee ?? 0;
      final femaleFee = feeResult?.femaleFee ?? 0;
      final newFinalFee = isFemale ? femaleFee : maleFee;
      final previouslyPaid = m.paidAmount > 0 ? m.paidAmount : (m.isPaid ? m.finalFee : 0);

      String newPaymentStatus;
      int newPaidAmount;
      if (newFinalFee > 0 && previouslyPaid >= newFinalFee) {
        newPaymentStatus = 'PAID';
        newPaidAmount = newFinalFee;
      } else if (previouslyPaid > 0) {
        newPaymentStatus = 'PARTIAL';
        newPaidAmount = previouslyPaid;
      } else {
        newPaymentStatus = 'PENDING';
        newPaidAmount = 0;
      }

      return m.copyWith(
        baseFee: maleFee,
        discount: isFemale ? (maleFee - femaleFee) : 0,
        finalFee: newFinalFee,
        paidAmount: newPaidAmount,
        paymentStatus: newPaymentStatus,
        gender: isFemale ? 'FEMALE' : 'MALE',
      );
    }).toList();

    final totalCollected = recalculatedFees.fold(0, (sum, m) => sum + m.paidAmount);

    final updated = SessionSettlement(
      sessionId: sessionId,
      shuttlecockUsed: shuttlecockUsed,
      shuttlecockPrice: current.shuttlecockPrice,
      courtFee: courtCost,
      extraFee: extraFee,
      totalCost: total,
      totalCollected: totalCollected,
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
    var current = await getSettlement(sessionId);
    if (!current.isSettled) {
      try {
        current = await calculateSettlement(
          sessionId: sessionId,
          shuttlecockUsed: current.shuttlecockUsed,
          extraFee: current.extraFee,
          courtRentalCost: current.courtFee,
        );
      } catch (_) {}
    }

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

    current = await getSettlement(sessionId);
    final updatedFees = current.memberFees.map((m) {
      if (m.userId == userId) {
        return m.copyWith(
          paidAmount: m.finalFee,
          paymentStatus: 'PAID',
          paymentMethod: 'CASH',
        );
      }
      return m;
    }).toList();

    final collected = updatedFees.fold(0, (sum, m) => sum + m.paidAmount);

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
      bankAccount: current.bankAccount,
    );
    _settlementCache[sessionId] = updated;
    return updated;
  }

  @override
  Future<SessionSettlement> requestCashPayment({
    required String sessionId,
    required String userId,
    String? feeId,
  }) async {
    try {
      final res = await dio.post('/api/v1/sessions/$sessionId/settlement/members/$userId/cash-request');
      if (res.statusCode == 200 && res.data != null) {
        final payload = res.data is Map<String, dynamic> && res.data.containsKey('result') ? res.data['result'] : res.data;
        if (payload is Map<String, dynamic>) {
          final entity = SessionSettlementDto.fromJson(payload).toEntity();
          _settlementCache[sessionId] = entity;
          return entity;
        }
      }
    } catch (_) {
      if (feeId != null && feeId.isNotEmpty) {
        try {
          await dio.post('/api/v1/user/me/fees/$feeId/cash-request');
        } catch (_) {}
      }
    }

    final current = await getSettlement(sessionId);
    final updatedFees = current.memberFees.map((m) {
      if (m.userId == userId) {
        return m.copyWith(
          paymentProgress: 'CASH_CONFIRMATION_REQUESTED',
          paymentMethod: 'CASH',
        );
      }
      return m;
    }).toList();

    final updated = SessionSettlement(
      sessionId: sessionId,
      shuttlecockUsed: current.shuttlecockUsed,
      shuttlecockPrice: current.shuttlecockPrice,
      courtFee: current.courtFee,
      extraFee: current.extraFee,
      totalCost: current.totalCost,
      totalCollected: current.totalCollected,
      memberFees: updatedFees,
      isSettled: current.isSettled,
      bankAccount: current.bankAccount,
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
