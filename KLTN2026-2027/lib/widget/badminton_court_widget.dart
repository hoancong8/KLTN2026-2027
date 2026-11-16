// lib/widget/badminton_court_widget.dart

import 'package:flutter/material.dart';
import '../app/theme/theme.dart';
import '../domain/entities/session/session_rotation.dart';
import 'app_status_badge.dart';

class BadmintonCourtWidget extends StatelessWidget {
  final CourtMatch court;
  final VoidCallback? onStartMatch;
  final VoidCallback? onFinishMatch;
  final VoidCallback? onSwapLineup;
  final VoidCallback? onRestoreProposal;

  const BadmintonCourtWidget({
    super.key,
    required this.court,
    this.onStartMatch,
    this.onFinishMatch,
    this.onSwapLineup,
    this.onRestoreProposal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPlaying = court.isPlaying;
    final isProposed = court.isProposed;
    final isEmpty = court.state == 'Empty' || (court.teamA.isEmpty && court.teamB.isEmpty);

    Widget statusBadge;
    if (isPlaying) {
      statusBadge = const AppStatusBadge.success(label: 'Đang thi đấu');
    } else if (isProposed) {
      statusBadge = AppStatusBadge.warning(
        label: court.isManualSwapped ? 'Đã đổi thủ công' : 'Đề xuất sẵn sàng',
      );
    } else {
      statusBadge = const AppStatusBadge.neutral(label: 'Sân trống');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isPlaying
              ? colors.primary.withValues(alpha: 0.5)
              : (isProposed ? colors.warning.withValues(alpha: 0.5) : colors.cardBorder),
          width: 1.5,
        ),
        boxShadow: isPlaying ? AppShadows.primaryGlow() : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Bar: Court Number, Live Match Indicator & Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPlaying ? colors.primaryContainer : colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_tennis_rounded,
                            size: 16,
                            color: isPlaying ? colors.primary : colors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'SÂN SỐ ${court.courtNumber}',
                            style: AppTypography.titleSmall.bold.copyWith(
                              color: isPlaying ? colors.primary : colors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPlaying) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                statusBadge,
              ],
            ),
          ),

          // 2. 2D Badminton Court Visual Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.courtGradient,
                ),
                child: CustomPaint(
                  painter: _BadmintonCourtLinesPainter(),
                  child: isEmpty
                      ? _buildEmptyCourtState(context)
                      : _buildActiveCourtState(context),
                ),
              ),
            ),
          ),

          // 3. Action Buttons
          if (!isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: _buildActionButtons(context),
            ),
          ] else ...[
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyCourtState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_tennis_rounded,
              size: 28,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sân thi đấu đang sẵn sàng',
            style: AppTypography.titleSmall.bold.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hệ thống tự động đề xuất 4 tay vợt khi đủ hàng đợi',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCourtState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: [
          // Team A Side (Top Half-court)
          _buildTeamHalfCourt(
            context,
            teamName: 'ĐỘI 1',
            players: court.teamA,
            totalSkill: court.teamASkill,
            teamColor: AppColors.primaryLight,
            isTopTeam: true,
          ),

          // Net Line & VS Match Badge
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VS',
                        style: AppTypography.labelSmall.bold.copyWith(
                          color: AppColors.courtGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (court.skillDiff > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '±${court.skillDiff}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.neutral600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Team B Side (Bottom Half-court)
          _buildTeamHalfCourt(
            context,
            teamName: 'ĐỘI 2',
            players: court.teamB,
            totalSkill: court.teamBSkill,
            teamColor: AppColors.accent,
            isTopTeam: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHalfCourt(
    BuildContext context, {
    required String teamName,
    required List<RotationPlayer> players,
    required int totalSkill,
    required Color teamColor,
    required bool isTopTeam,
  }) {
    return Column(
      children: [
        // Team Tag & Total Skill Level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: teamColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                teamName,
                style: AppTypography.labelSmall.bold.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Tổng Lvl $totalSkill',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2 Player Spots in Doubles Court
        Row(
          children: [
            for (int i = 0; i < 2; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == 0 ? 4 : 0,
                    left: i == 1 ? 4 : 0,
                  ),
                  child: i < players.length
                      ? _buildPlayerSpot(players[i])
                      : _buildEmptySpot(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerSpot(RotationPlayer player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.courtGreen,
            child: Text(
              player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : 'P',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              player.fullName,
              style: const TextStyle(
                color: AppColors.neutral900,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'L${player.skillLevel}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySpot() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Text(
          'Chờ tay vợt',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colors = context.colors;

    if (court.isPlaying) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          elevation: 0,
        ),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
        label: const Text(
          'Kết Thúc Trận (Tự động tính 5p nghỉ)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: onFinishMatch,
      );
    }

    if (court.isProposed) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text(
                'Bắt Đầu Trận Đấu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: onStartMatch,
            ),
          ),
          if (onSwapLineup != null) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  side: BorderSide(color: colors.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text(
                  'Đổi Đội Hình',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                onPressed: onSwapLineup,
              ),
            ),
          ],
          if (court.isManualSwapped && onRestoreProposal != null) ...[
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.warning,
                side: BorderSide(color: colors.warning.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: const Text(
                'Gợi ý gốc',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              onPressed: onRestoreProposal,
            ),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// CustomPainter to draw crisp, realistic white court boundary lines for Badminton
class _BadmintonCourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.courtLine.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const pad = 6.0;
    final w = size.width;
    final h = size.height;

    // Outer boundary line
    canvas.drawRect(Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2), paint);

    // Inner doubles sideline (10% inward from left and right)
    final doublesPad = pad + (w - pad * 2) * 0.08;
    canvas.drawLine(Offset(doublesPad, pad), Offset(doublesPad, h - pad), paint);
    canvas.drawLine(Offset(w - doublesPad, pad), Offset(w - doublesPad, h - pad), paint);

    // Center service line (vertical divider line in top and bottom halves)
    final midX = w / 2;
    final midY = h / 2;
    final shortServiceOffset = (h - pad * 2) * 0.15;

    // Top half center line (from short service line to back line)
    canvas.drawLine(Offset(midX, pad), Offset(midX, midY - shortServiceOffset), paint);

    // Bottom half center line (from short service line to back line)
    canvas.drawLine(Offset(midX, midY + shortServiceOffset), Offset(midX, h - pad), paint);

    // Short service lines (horizontal lines near the net)
    canvas.drawLine(Offset(pad, midY - shortServiceOffset), Offset(w - pad, midY - shortServiceOffset), paint);
    canvas.drawLine(Offset(pad, midY + shortServiceOffset), Offset(w - pad, midY + shortServiceOffset), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
