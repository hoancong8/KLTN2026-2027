// lib/domain/entities/session/session_rotation.dart

class RotationPlayer {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int skillLevel;
  final DateTime? lastFinishedAt;
  final int restSecondsLeft;
  final bool isPaused;

  const RotationPlayer({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.skillLevel = 3,
    this.lastFinishedAt,
    this.restSecondsLeft = 0,
    this.isPaused = false,
  });

  bool get isResting => restSecondsLeft > 0;
}

class CourtMatch {
  final String matchId;
  final int courtNumber;
  final String state; // 'Proposed' | 'Playing' | 'Finished'
  final DateTime? startedAt;
  final List<RotationPlayer> teamA;
  final List<RotationPlayer> teamB;
  final bool isManualSwapped;

  const CourtMatch({
    required this.matchId,
    required this.courtNumber,
    required this.state,
    this.startedAt,
    required this.teamA,
    required this.teamB,
    this.isManualSwapped = false,
  });

  bool get isProposed => state == 'Proposed';
  bool get isPlaying => state == 'Playing';
  bool get isFinished => state == 'Finished';

  int get teamASkill => teamA.fold(0, (sum, p) => sum + p.skillLevel);
  int get teamBSkill => teamB.fold(0, (sum, p) => sum + p.skillLevel);
  int get skillDiff => (teamASkill - teamBSkill).abs();
}

class SessionRotationSnapshot {
  final String sessionId;
  final String sessionStatus;
  final int rotationVersion;
  final DateTime serverTime;
  final DateTime? rotationStartedAt;
  final bool canInitialize;
  final bool canGenerateProposals;
  final String? reason;
  final int minRestMinutes;
  final int readyCandidateCount;
  final int coolingDownCount;
  final List<CourtMatch> courts;
  final List<RotationPlayer> queuePlayers;

  const SessionRotationSnapshot({
    required this.sessionId,
    required this.sessionStatus,
    required this.rotationVersion,
    required this.serverTime,
    this.rotationStartedAt,
    required this.canInitialize,
    required this.canGenerateProposals,
    this.reason,
    this.minRestMinutes = 5,
    required this.readyCandidateCount,
    required this.coolingDownCount,
    required this.courts,
    this.queuePlayers = const [],
  });

  bool get isInitialized => rotationStartedAt != null;
}
