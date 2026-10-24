// lib/domain/entities/session/session_attendance.dart

class AttendancePlayer {
  final String userId;
  final String bookingId;
  final String fullName;
  final String? avatarUrl;
  final String status; // 'WAITING' | 'CHECKED_IN' | 'NO_SHOW'
  final DateTime? checkinAt;
  final DateTime bookedAt;
  final int skillLevel; // 1..6
  final bool isReady;
  final bool isWalkIn;

  const AttendancePlayer({
    required this.userId,
    required this.bookingId,
    required this.fullName,
    this.avatarUrl,
    required this.status,
    this.checkinAt,
    required this.bookedAt,
    this.skillLevel = 3,
    this.isReady = false,
    this.isWalkIn = false,
  });

  bool get isCheckedIn => status == 'CHECKED_IN';
  bool get isNoShow => status == 'NO_SHOW';
  bool get isWaiting => status == 'WAITING';

  AttendancePlayer copyWith({
    String? status,
    DateTime? checkinAt,
    bool? isReady,
  }) {
    return AttendancePlayer(
      userId: userId,
      bookingId: bookingId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      status: status ?? this.status,
      checkinAt: checkinAt ?? this.checkinAt,
      bookedAt: bookedAt,
      skillLevel: skillLevel,
      isReady: isReady ?? this.isReady,
      isWalkIn: isWalkIn,
    );
  }
}

class SessionAttendanceSnapshot {
  final String sessionId;
  final String groupId;
  final DateTime startTime;
  final DateTime endTime;
  final int maxPlayers;
  final int presentCount;
  final int notArrivedCount;
  final int noShowCount;
  final int waitlistCount;
  final int readyCount;
  final bool canEdit;
  final bool canStartRotation;
  final DateTime? attendanceCompletedAt;
  final String? attendanceCompletedBy;
  final List<AttendancePlayer> players;

  const SessionAttendanceSnapshot({
    required this.sessionId,
    required this.groupId,
    required this.startTime,
    required this.endTime,
    required this.maxPlayers,
    required this.presentCount,
    required this.notArrivedCount,
    required this.noShowCount,
    required this.waitlistCount,
    required this.readyCount,
    required this.canEdit,
    required this.canStartRotation,
    this.attendanceCompletedAt,
    this.attendanceCompletedBy,
    required this.players,
  });

  bool get isCompleted => attendanceCompletedAt != null;
}
