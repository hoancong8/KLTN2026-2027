// lib/widget/badminton_court_widget.dart

import 'package:flutter/material.dart';
import '../app/theme/theme.dart';
import '../domain/entities/session/session_rotation.dart';
import 'app_status_badge.dart';

class BadmintonCourtWidget extends StatelessWidget {
  final CourtMatch court;
  final bool isManualMode;
  final VoidCallback? onStartMatch;
  final VoidCallback? onFinishMatch;
  final VoidCallback? onSwapLineup;
  final VoidCallback? onRestoreProposal;
  final void Function(DraggingPlayerPayload payload, String targetTeam, int? spotIndex)? onPlayerDropped;
  final VoidCallback? onClearCourt;
  final VoidCallback? onSwapTeams;

  const BadmintonCourtWidget({
    super.key,
    required this.court,
    this.isManualMode = false,
    this.onStartMatch,
    this.onFinishMatch,
    this.onSwapLineup,
    this.onRestoreProposal,
    this.onPlayerDropped,
    this.onClearCourt,
    this.onSwapTeams,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCourtState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          // Team A Drop Zone for empty court
          DragTarget<DraggingPlayerPayload>(
            onWillAcceptWithDetails: (details) => !court.isPlaying,
            onAcceptWithDetails: (details) {
              onPlayerDropped?.call(details.data, 'A', null);
            },
            builder: (ctx, candidates, rejected) {
              final isHovered = candidates.isNotEmpty;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                decoration: BoxDecoration(
                  color: isHovered
                      ? AppColors.primaryLight.withValues(alpha: 0.35)
                      : AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHovered ? AppColors.white : AppColors.white.withValues(alpha: 0.25),
                    width: isHovered ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isHovered ? Icons.add_circle_rounded : Icons.sports_tennis_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHovered ? 'Thả vào ĐỘI 1' : 'ĐỘI 1: Kéo thả tay vợt vào đây',
                      style: AppTypography.labelSmall.bold.copyWith(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Net Line & VS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'VS',
                    style: AppTypography.labelSmall.bold.copyWith(
                      color: AppColors.courtGreen,
                      fontWeight: FontWeight.w900,
                    ),
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

          // Team B Drop Zone for empty court
          DragTarget<DraggingPlayerPayload>(
            onWillAcceptWithDetails: (details) => !court.isPlaying,
            onAcceptWithDetails: (details) {
              onPlayerDropped?.call(details.data, 'B', null);
            },
            builder: (ctx, candidates, rejected) {
              final isHovered = candidates.isNotEmpty;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                decoration: BoxDecoration(
                  color: isHovered
                      ? AppColors.accent.withValues(alpha: 0.35)
                      : AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHovered ? AppColors.white : AppColors.white.withValues(alpha: 0.25),
                    width: isHovered ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isHovered ? Icons.add_circle_rounded : Icons.sports_tennis_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHovered ? 'Thả vào ĐỘI 2' : 'ĐỘI 2: Kéo thả tay vợt vào đây',
                      style: AppTypography.labelSmall.bold.copyWith(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
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
            teamLetter: 'A',
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
            teamLetter: 'B',
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
    required String teamLetter,
    required List<RotationPlayer> players,
    required int totalSkill,
    required Color teamColor,
    required bool isTopTeam,
  }) {
    return DragTarget<DraggingPlayerPayload>(
      onWillAcceptWithDetails: (details) => !court.isPlaying,
      onAcceptWithDetails: (details) {
        onPlayerDropped?.call(details.data, teamLetter, null);
      },
      builder: (ctx, candidates, rejected) {
        final isHovered = candidates.isNotEmpty;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: isHovered
              ? BoxDecoration(
                  color: teamColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.white, width: 1.5),
                )
              : null,
          child: Column(
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
                      isHovered ? 'Thả vào $teamName' : teamName,
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
                            ? _buildDraggablePlayerSpot(context, players[i], teamLetter, i)
                            : _buildEmptyDropSpot(teamLetter, i),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggablePlayerSpot(
    BuildContext context,
    RotationPlayer player,
    String teamLetter,
    int spotIndex,
  ) {
    final spotWidget = _buildPlayerSpot(player);
    if (court.isPlaying) {
      return spotWidget;
    }

    final payload = DraggingPlayerPayload(
      player: player,
      sourceCourtMatchId: court.matchId,
      sourceTeam: teamLetter,
      sourceSpotIndex: spotIndex,
    );

    return LongPressDraggable<DraggingPlayerPayload>(
      data: payload,
      delay: const Duration(milliseconds: 150),
      hapticFeedbackOnStart: true,
      feedback: _buildDraggingFeedbackCard(player),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: spotWidget,
      ),
      child: DragTarget<DraggingPlayerPayload>(
        onWillAcceptWithDetails: (details) =>
            !court.isPlaying && details.data.player.userId != player.userId,
        onAcceptWithDetails: (details) {
          onPlayerDropped?.call(details.data, teamLetter, spotIndex);
        },
        builder: (ctx, candidates, rejected) {
          final isHovered = candidates.isNotEmpty;
          return Container(
            decoration: isHovered
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: AppColors.white.withValues(alpha: 0.6), blurRadius: 8),
                    ],
                  )
                : null,
            child: spotWidget,
          );
        },
      ),
    );
  }

  Widget _buildDraggingFeedbackCard(RotationPlayer player) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              player.fullName,
              style: const TextStyle(
                color: AppColors.neutral900,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'L${player.skillLevel}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildEmptyDropSpot(String teamLetter, int spotIndex) {
    return DragTarget<DraggingPlayerPayload>(
      onWillAcceptWithDetails: (details) => !court.isPlaying,
      onAcceptWithDetails: (details) {
        onPlayerDropped?.call(details.data, teamLetter, spotIndex);
      },
      builder: (ctx, candidates, rejected) {
        final isHovered = candidates.isNotEmpty;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.white.withValues(alpha: 0.35)
                : AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered ? AppColors.white : AppColors.white.withValues(alpha: 0.4),
              width: isHovered ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isHovered ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                size: 13,
                color: AppColors.white.withValues(alpha: isHovered ? 1.0 : 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                isHovered ? 'Thả tay vợt' : 'Kéo vào đây',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: isHovered ? 1.0 : 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colors = context.colors;
    final hasPlayers = court.teamA.isNotEmpty || court.teamB.isNotEmpty;

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

    if (isManualMode) {
      return Column(
        children: [
          Row(
            children: [
              if (hasPlayers) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'Bắt Đầu Trận Đấu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: onStartMatch,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (onSwapTeams != null && hasPlayers) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    side: BorderSide(color: colors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  icon: const Icon(Icons.swap_vert_rounded, size: 16),
                  label: const Text('Đổi bên'),
                  onPressed: onSwapTeams,
                ),
                const SizedBox(width: 8),
              ],
              if (onClearCourt != null && hasPlayers) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Làm trống'),
                  onPressed: onClearCourt,
                ),
              ],
            ],
          ),
        ],
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
