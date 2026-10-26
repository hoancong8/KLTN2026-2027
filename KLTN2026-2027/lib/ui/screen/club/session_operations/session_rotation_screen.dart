// lib/ui/screen/club/session_operations/session_rotation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/consts/app_dimens.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_rotation.dart';
import '../../../../widget/app_shimmer.dart';
import '../../../../widget/app_status_badge.dart';

final sessionRotationNotifierProvider =
    StateNotifierProvider.autoDispose.family<SessionRotationNotifier, AsyncValue<SessionRotationSnapshot>, String>(
        (ref, sessionId) {
  final repo = ref.watch(sessionOperationsRepositoryProvider);
  return SessionRotationNotifier(repo, sessionId);
});

class SessionRotationNotifier extends StateNotifier<AsyncValue<SessionRotationSnapshot>> {
  final dynamic _repo;
  final String sessionId;

  SessionRotationNotifier(this._repo, this.sessionId) : super(const AsyncValue.loading()) {
    loadRotation();
  }

  Future<void> loadRotation() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repo.getRotation(sessionId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startMatch(String matchId) async {
    try {
      final updated = await _repo.startMatch(sessionId: sessionId, matchId: matchId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> finishMatch(String matchId) async {
    try {
      final updated = await _repo.finishMatch(sessionId: sessionId, matchId: matchId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateProposals() async {
    try {
      final updated = await _repo.generateProposals(sessionId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> initializeRotation() async {
    try {
      final updated = await _repo.initializeRotation(sessionId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restoreProposal(String matchId) async {
    try {
      final updated = await _repo.restoreProposal(sessionId: sessionId, matchId: matchId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pausePlayer(String userId, bool isPaused) async {
    try {
      final updated = await _repo.pausePlayer(sessionId: sessionId, userId: userId, isPaused: isPaused);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> swapPlayers(String matchId, List<String> teamAUserIds, List<String> teamBUserIds) async {
    try {
      final updated = await _repo.swapMatchPlayers(
        sessionId: sessionId,
        matchId: matchId,
        teamAUserIds: teamAUserIds,
        teamBUserIds: teamBUserIds,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class SessionRotationScreen extends ConsumerWidget {
  final String sessionId;

  const SessionRotationScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncState = ref.watch(sessionRotationNotifierProvider(sessionId));
    final vm = ref.read(sessionRotationNotifierProvider(sessionId).notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điều Phối Xoay Tua Sân', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
            Text('Giải thuật ưu tiên thời gian nghỉ & cân bằng trình độ',
                style: AppTypography.labelSmall.colored(colors.textMuted)),
          ],
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.primary),
            onPressed: vm.loadRotation,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: AppSpacing.allBase,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.cardBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 48),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.how_to_reg_rounded),
                label: const Text('Xem Điểm Danh'),
                onPressed: () => context.push('/session/$sessionId/attendance'),
              ),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 48),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Chia Tiền Buổi Chơi'),
                onPressed: () => context.push('/session/$sessionId/settlement'),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= AppDimens.tabletBreakpoint;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: asyncState.when(
                loading: () => ListView(
                  padding: AppSpacing.allBase,
                  children: [
                    AppShimmer.card(height: 90),
                    AppSpacing.gapH16,
                    AppShimmer.line(width: 220, height: 20),
                    AppSpacing.gapH12,
                    AppShimmer.card(height: 180),
                    AppSpacing.gapH16,
                    AppShimmer.card(height: 180),
                  ],
                ),
                error: (err, _) => Padding(
                  padding: AppSpacing.allXl,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                      AppSpacing.gapH12,
                      Text('Không thể tải bàn xoay tua',
                          style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
                      AppSpacing.gapH4,
                      Text('$err', style: AppTypography.bodySmall.colored(colors.textMuted), textAlign: TextAlign.center),
                      AppSpacing.gapH16,
                      ElevatedButton.icon(
                        onPressed: vm.loadRotation,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(120, 44),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (snapshot) {
                  return RefreshIndicator(
                    onRefresh: vm.loadRotation,
                    color: colors.primary,
                    child: ListView(
                      padding: AppSpacing.allBase,
                      children: [
                        // 1. Live Rotation Status Banner
                        _buildLiveStatusBanner(context, snapshot, vm),
                        AppSpacing.gapH16,

                        // 2. Courts & Matches
                        Text('Trạng thái các sân thi đấu (${snapshot.courts.length} sân)',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,

                        if (snapshot.courts.isEmpty)
                          Container(
                            padding: AppSpacing.allXl,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.sports_tennis_rounded, size: 48, color: colors.textMuted),
                                AppSpacing.gapH12,
                                Text(
                                  'Chưa có sân thi đấu nào được thiết lập cho buổi chơi này',
                                  style: AppTypography.bodyMedium.colored(colors.textMuted),
                                ),
                              ],
                            ),
                          )
                        else if (isTablet && snapshot.courts.length > 1)
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: snapshot.courts.map((court) {
                              final cardWidth = (constraints.maxWidth - 48) / 2;
                              return SizedBox(
                                width: cardWidth,
                                child: _buildCourtCard(context, court, snapshot.queuePlayers, vm),
                              );
                            }).toList(),
                          )
                        else
                          ...snapshot.courts.map((court) => _buildCourtCard(context, court, snapshot.queuePlayers, vm)),
                        AppSpacing.gapH16,

                        // 3. Resting / Waiting Queue
                        Text('Hàng đợi sẵn sàng vào sân (${snapshot.queuePlayers.length})',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        _buildQueueSection(context, snapshot.queuePlayers, vm),

                        AppSpacing.gapH48,
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveStatusBanner(BuildContext context, SessionRotationSnapshot snapshot, SessionRotationNotifier vm) {
    final colors = context.colors;

    return Container(
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.gapW8,
                  Text('Hệ Thống Xoay Tua Đang Chạy',
                      style: AppTypography.labelLarge.bold.colored(colors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.tag,
                ),
                child: Text('Nghỉ tối thiểu 5 phút', style: AppTypography.labelSmall.bold.colored(colors.primary)),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Text(
            'Giải thuật tự động phân phối 4 tay vợt có thời gian nghỉ lâu nhất vào sân trống tiếp theo và cân bằng chênh lệch tổng trình độ nhỏ nhất.',
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
          AppSpacing.gapH12,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Tạo Đề Xuất Mới'),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    vm.generateProposals();
                  },
                ),
              ),
              AppSpacing.gapW8,
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  side: BorderSide(color: colors.cardBorder),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Khởi Tạo Lại'),
                onPressed: () => _confirmInitializeRotation(context, vm),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmInitializeRotation(BuildContext context, SessionRotationNotifier vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khởi tạo lại bảng xoay tua?'),
        content: const Text(
          'Hệ thống sẽ đồng bộ lại toàn bộ danh sách điểm danh và phân bổ sân từ đầu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              vm.initializeRotation();
              Navigator.of(ctx).pop();
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(
      BuildContext context, CourtMatch court, List<RotationPlayer> queuePlayers, SessionRotationNotifier vm) {
    final colors = context.colors;
    final isPlaying = court.isPlaying;
    final isProposed = court.isProposed;

    Widget badgeWidget;
    if (isPlaying) {
      badgeWidget = const AppStatusBadge.success(label: 'Đang thi đấu');
    } else if (isProposed) {
      badgeWidget = AppStatusBadge.warning(
        label: court.isManualSwapped ? 'Đã đổi thủ công' : 'Đề xuất sẵn sàng',
      );
    } else {
      badgeWidget = const AppStatusBadge.neutral(label: 'Trống');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isPlaying
              ? colors.success.withValues(alpha: 0.4)
              : (isProposed ? colors.primary.withValues(alpha: 0.4) : colors.cardBorder),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Court Number & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stadium_rounded, color: colors.primary, size: 20),
                  AppSpacing.gapW8,
                  Text('SÂN SỐ ${court.courtNumber}',
                      style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                ],
              ),
              badgeWidget,
            ],
          ),
          AppSpacing.gapH12,

          // 2 Teams Layout
          if (court.state == 'Empty' || (court.teamA.isEmpty && court.teamB.isEmpty))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(Icons.sports_tennis_rounded, size: 28, color: colors.textMuted),
                  AppSpacing.gapH8,
                  Text(
                    'Sân đang trống, chờ đủ 4 người sẵn sàng trong hàng đợi...',
                    style: AppTypography.bodySmall.colored(colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                // Team A
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ĐỘI 1', style: AppTypography.labelSmall.bold.colored(colors.primary)),
                            Text('L${court.teamASkill}', style: AppTypography.labelSmall.colored(colors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...court.teamA.map(
                          (p) => Text('• ${p.fullName}',
                              style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('VS', style: AppTypography.titleSmall.bold.colored(colors.textMuted)),
                ),
                // Team B
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: colors.warning.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ĐỘI 2', style: AppTypography.labelSmall.bold.colored(colors.warning)),
                            Text('L${court.teamBSkill}', style: AppTypography.labelSmall.colored(colors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...court.teamB.map(
                          (p) => Text('• ${p.fullName}',
                              style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          AppSpacing.gapH12,

          // Action Buttons with touch target >= 48dp
          if (isProposed) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 44),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Đổi người'),
                    onPressed: () => _showSwapLineupDialog(context, court, queuePlayers, vm),
                  ),
                ),
                if (court.isManualSwapped) ...[
                  AppSpacing.gapW8,
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.warning,
                      side: BorderSide(color: colors.warning.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 44),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text('Gợi ý gốc'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      vm.restoreProposal(court.matchId);
                    },
                  ),
                ],
              ],
            ),
            AppSpacing.gapH8,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(court.isManualSwapped ? 'Xác nhận bắt đầu trận đã đổi' : 'Bắt đầu trận đấu trên sân này'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  vm.startMatch(court.matchId);
                },
              ),
            ),
          ] else if (isPlaying)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Kết thúc trận (Tự động tính 5p nghỉ)'),
                onPressed: () => _confirmFinishMatch(context, court, vm),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmFinishMatch(BuildContext context, CourtMatch court, SessionRotationNotifier vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Kết thúc trận sân ${court.courtNumber}?'),
        content: const Text(
          'Hệ thống sẽ giải phóng sân và tự động kích hoạt thời gian nghỉ 5 phút cho 4 tay vợt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.success,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              vm.finishMatch(court.matchId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Kết thúc trận'),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueSection(BuildContext context, List<RotationPlayer> queue, SessionRotationNotifier vm) {
    final colors = context.colors;

    if (queue.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: AppRadius.card,
          border: Border.all(color: colors.cardBorder),
        ),
        child: Center(
          child: Text('Tất cả hội viên đều đang thi đấu trên sân',
              style: AppTypography.bodySmall.colored(colors.textMuted)),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: queue.map((p) {
        return InkWell(
          borderRadius: AppRadius.tag,
          onTap: () => _showPlayerPauseDialog(context, p, vm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: p.isPaused ? colors.cardBorder.withValues(alpha: 0.3) : colors.surfaceSubtle,
              borderRadius: AppRadius.tag,
              border: Border.all(
                color: p.isPaused ? colors.warning.withValues(alpha: 0.6) : colors.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.isPaused ? Icons.pause_circle_outline_rounded : Icons.person_outline_rounded,
                  size: 14,
                  color: p.isPaused ? colors.warning : colors.primary,
                ),
                AppSpacing.gapW4,
                Text(
                  p.fullName,
                  style: AppTypography.labelSmall.bold.colored(
                    p.isPaused ? colors.textMuted : colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.tag,
                  ),
                  child: Text('L${p.skillLevel}', style: AppTypography.labelSmall.colored(colors.primary)),
                ),
                if (p.isPaused) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.15),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text('Tạm nghỉ', style: AppTypography.labelSmall.bold.colored(colors.warning)),
                  ),
                ] else if (p.isResting) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.15),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text('Nghỉ 5p', style: AppTypography.labelSmall.colored(colors.warning)),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPlayerPauseDialog(BuildContext context, RotationPlayer player, SessionRotationNotifier vm) {
    final colors = context.colors;
    final isPaused = player.isPaused;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(player.fullName),
        content: Text(
          isPaused
              ? 'Chuyển trạng thái người chơi sang "Sẵn sàng" để tiếp tục nhận lượt thi đấu?'
              : 'Chuyển trạng thái sang "Tạm nghỉ"? Thuật toán sẽ bỏ qua người chơi này khi đề xuất trận.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaused ? colors.primary : colors.warning,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              vm.pausePlayer(player.userId, !isPaused);
              Navigator.of(ctx).pop();
            },
            child: Text(isPaused ? 'Sẵn sàng thi đấu' : 'Đặt tạm nghỉ'),
          ),
        ],
      ),
    );
  }

  void _showSwapLineupDialog(
    BuildContext context,
    CourtMatch court,
    List<RotationPlayer> queuePlayers,
    SessionRotationNotifier vm,
  ) {
    final courtPlayers = [...court.teamA, ...court.teamB];
    if (courtPlayers.length < 4) return;

    final candidatePool = [
      ...courtPlayers,
      ...queuePlayers.where((q) => !q.isPaused),
    ];

    final uniqueCandidates = <String, RotationPlayer>{};
    for (final p in candidatePool) {
      uniqueCandidates[p.userId] = p;
    }
    final candidateList = uniqueCandidates.values.toList();

    String a1 = court.teamA[0].userId;
    String a2 = court.teamA[1].userId;
    String b1 = court.teamB[0].userId;
    String b2 = court.teamB[1].userId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final colors = dialogContext.colors;

            Widget buildDropdown(String label, String currentVal, ValueChanged<String?> onChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.cardBorder),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentVal,
                        isExpanded: true,
                        items: candidateList.map((p) {
                          return DropdownMenuItem(
                            value: p.userId,
                            child: Text(
                              '${p.fullName} (L${p.skillLevel})',
                              style: AppTypography.bodySmall.colored(colors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }

            return AlertDialog(
              title: Text('Đổi Đội Hình Sân ${court.courtNumber}'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chọn 4 tay vợt cho 2 đội (có thể đổi từ hàng đợi):',
                          style: AppTypography.bodySmall.colored(colors.textMuted)),
                      const SizedBox(height: 12),
                      Text('ĐỘI 1', style: AppTypography.labelMedium.bold.colored(colors.primary)),
                      const SizedBox(height: 6),
                      buildDropdown('Tay vợt 1A', a1, (v) {
                        if (v != null) setStateDialog(() => a1 = v);
                      }),
                      buildDropdown('Tay vợt 2A', a2, (v) {
                        if (v != null) setStateDialog(() => a2 = v);
                      }),
                      const Divider(),
                      Text('ĐỘI 2', style: AppTypography.labelMedium.bold.colored(colors.warning)),
                      const SizedBox(height: 6),
                      buildDropdown('Tay vợt 1B', b1, (v) {
                        if (v != null) setStateDialog(() => b1 = v);
                      }),
                      buildDropdown('Tay vợt 2B', b2, (v) {
                        if (v != null) setStateDialog(() => b2 = v);
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: () {
                    final selectedSet = {a1, a2, b1, b2};
                    if (selectedSet.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn 4 tay vợt khác nhau')),
                      );
                      return;
                    }
                    HapticFeedback.mediumImpact();
                    vm.swapPlayers(court.matchId, [a1, a2], [b1, b2]);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
