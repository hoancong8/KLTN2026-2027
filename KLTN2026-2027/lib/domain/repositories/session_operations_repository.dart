// lib/domain/repositories/session_operations_repository.dart

import '../entities/session/session_attendance.dart';
import '../entities/session/session_rotation.dart';
import '../entities/session/session_settlement.dart';

abstract class SessionOperationsRepository {
  // --- FR14 / UC12: Điểm danh thành viên tại sân ---
  Future<SessionAttendanceSnapshot> getAttendance(String sessionId);
  Future<SessionAttendanceSnapshot> updateAttendanceStatus({
    required String sessionId,
    required String userId,
    required String status, // 'CHECKED_IN' | 'NO_SHOW'
  });
  Future<SessionAttendanceSnapshot> addWalkIn({
    required String sessionId,
    required String fullName,
    String? phoneNumber,
  });
  Future<SessionAttendanceSnapshot> completeAttendance(String sessionId);

  // --- FR15 - FR17 / UC13: Điều phối xoay tua sân ---
  Future<SessionRotationSnapshot> getRotation(String sessionId);
  Future<SessionRotationSnapshot> initializeRotation(String sessionId);
  Future<SessionRotationSnapshot> generateProposals(String sessionId);
  Future<SessionRotationSnapshot> startMatch({
    required String sessionId,
    required String matchId,
  });
  Future<SessionRotationSnapshot> finishMatch({
    required String sessionId,
    required String matchId,
  });
  Future<SessionRotationSnapshot> pausePlayer({
    required String sessionId,
    required String userId,
    required bool isPaused,
  });
  Future<SessionRotationSnapshot> restoreProposal({
    required String sessionId,
    required String matchId,
  });
  Future<SessionRotationSnapshot> swapMatchPlayers({
    required String sessionId,
    required String matchId,
    required List<String> teamAUserIds,
    required List<String> teamBUserIds,
  });
  Future<SessionRotationSnapshot> setThreePlayerMode({
    required String sessionId,
    required ThreePlayerMatchMode mode,
  });
  Future<SessionRotationSnapshot> movePlayer({
    required String sessionId,
    required DraggingPlayerPayload payload,
    String? targetCourtMatchId,
    String? targetTeam,
    int? targetSpotIndex,
  });
  Future<SessionRotationSnapshot> clearCourt({
    required String sessionId,
    required String matchId,
  });

  // --- FR18 - FR21: Hạch toán vật tư, đa hệ số & VietQR ---
  Future<SessionSettlement> getSettlement(String sessionId);
  Future<SessionSettlement> calculateSettlement({
    required String sessionId,
    required int shuttlecockUsed,
    required int extraFee,
    int? courtRentalCost,
    bool monthlyExemptCourtOnly = false,
    Future<bool> Function(List<SettlementAdvanceLine>)? confirmAdvances,
  });
  Future<SessionSettlement> markMemberPaid({
    required String sessionId,
    required String userId,
  });
  Future<SessionSettlement> requestCashPayment({
    required String sessionId,
    required String userId,
    String? feeId,
  });


}
