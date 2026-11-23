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
import '../../../../widget/badminton_court_widget.dart';

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

  Future<void> setThreePlayerMode(ThreePlayerMatchMode mode) async {
    try {
      final updated = await _repo.setThreePlayerMode(sessionId: sessionId, mode: mode);
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
            Text('Điều Phối Trận Đấu & Xoay Tua Sân', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
            Text('Tự động ghép cặp theo thời gian hồi sức & trình độ',
                style: AppTypography.labelSmall.colored(colors.textMuted)),
          ],
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
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
                label: const Text('Check-in Ra Sân'),
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
                label: const Text('Tổng Kết Chi Phí'),
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
                        Text('Hàng ghế dự bị sẵn sàng (${snapshot.queuePlayers.length} tay vợt)',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        _buildQueueSection(context, snapshot, vm),

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
                  Text('Điều Phối Trận Đấu Tự Động',
                      style: AppTypography.labelLarge.bold.colored(colors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.tag,
                ),
                child: Text('Hồi sức tối thiểu 5 phút', style: AppTypography.labelSmall.bold.colored(colors.primary)),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Text(
            'Thuật toán ưu tiên tay vợt có thời gian hồi sức lâu nhất vào sân tiếp theo. Hỗ trợ linh hoạt: Đánh đôi 2vs2 (>= 4 người), Đánh 2vs1 hoặc Đánh đơn 1vs1 xoay vòng (2-3 người).',
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
          AppSpacing.gapH12,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hình thức ca 3 người:',
                      style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                    ),
                    Text(
                      snapshot.threePlayerMode == ThreePlayerMatchMode.twoVsOne
                          ? '2 vs 1 (Cả 3 cùng đánh)'
                          : '1 vs 1 (1 người nghỉ xoay vòng)',
                      style: AppTypography.labelSmall.bold.colored(colors.primary),
                    ),
                  ],
                ),
                AppSpacing.gapH8,
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          vm.setThreePlayerMode(ThreePlayerMatchMode.twoVsOne);
                        },
                        borderRadius: AppRadius.borderSm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: snapshot.threePlayerMode == ThreePlayerMatchMode.twoVsOne
                                ? colors.primary
                                : colors.cardBackground,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(
                              color: snapshot.threePlayerMode == ThreePlayerMatchMode.twoVsOne
                                  ? colors.primary
                                  : colors.cardBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '2 vs 1 (Cả 3 cùng đánh)',
                            style: AppTypography.labelSmall.bold.colored(
                              snapshot.threePlayerMode == ThreePlayerMatchMode.twoVsOne
                                  ? AppColors.white
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapW8,
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          vm.setThreePlayerMode(ThreePlayerMatchMode.singlesRotation);
                        },
                        borderRadius: AppRadius.borderSm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: snapshot.threePlayerMode == ThreePlayerMatchMode.singlesRotation
                                ? colors.primary
                                : colors.cardBackground,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(
                              color: snapshot.threePlayerMode == ThreePlayerMatchMode.singlesRotation
                                  ? colors.primary
                                  : colors.cardBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '1 vs 1 (1 người nghỉ)',
                            style: AppTypography.labelSmall.bold.colored(
                              snapshot.threePlayerMode == ThreePlayerMatchMode.singlesRotation
                                  ? AppColors.white
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                  label: const Text('Tạo Lượt Đấu Mới'),
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
                label: const Text('Khởi Tạo Lại Lượt Đấu'),
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
          'Hệ thống sẽ đồng bộ lại toàn bộ danh sách ra sân và phân bổ sân từ đầu.',
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
    return BadmintonCourtWidget(
      court: court,
      onStartMatch: () {
        HapticFeedback.mediumImpact();
        vm.startMatch(court.matchId);
      },
      onFinishMatch: () => _confirmFinishMatch(context, court, vm),
      onSwapLineup: () => _showSwapLineupDialog(context, court, queuePlayers, vm),
      onRestoreProposal: court.isManualSwapped
          ? () {
              HapticFeedback.lightImpact();
              vm.restoreProposal(court.matchId);
            }
          : null,
    );
  }

  void _confirmFinishMatch(BuildContext context, CourtMatch court, SessionRotationNotifier vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Kết thúc trận sân ${court.courtNumber}?'),
        content: const Text(
          'Hệ thống sẽ giải phóng sân và tự động kích hoạt thời gian hồi sức 5 phút cho các tay vợt.',
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

  Widget _buildQueueSection(BuildContext context, SessionRotationSnapshot snapshot, SessionRotationNotifier vm) {
    final colors = context.colors;
    final queue = snapshot.queuePlayers;
    final hasActiveMatch = snapshot.courts.any((c) => c.isPlaying || c.isProposed);

    if (queue.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: AppRadius.card,
          border: Border.all(color: colors.cardBorder),
        ),
        child: Center(
          child: Text(
            hasActiveMatch
                ? 'Tất cả hội viên đều đang thi đấu trên sân'
                : 'Chưa có hội viên check-in ra sân. Cần tối thiểu 2 người để hệ thống tự động ghép cặp thi đấu (1vs1, 2vs1 hoặc 2vs2).',
            style: AppTypography.bodySmall.colored(colors.textMuted),
            textAlign: TextAlign.center,
          ),
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
                  p.isPaused ? Icons.pause_circle_outline_rounded : Icons.sports_tennis_rounded,
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
                    child: Text('Hồi sức 5p', style: AppTypography.labelSmall.colored(colors.warning)),
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
    if (courtPlayers.length < 2) return;

    final candidatePool = [
      ...courtPlayers,
      ...queuePlayers.where((q) => !q.isPaused),
    ];

    final uniqueCandidates = <String, RotationPlayer>{};
    for (final p in candidatePool) {
      uniqueCandidates[p.userId] = p;
    }
    final candidateList = uniqueCandidates.values.toList();

    String a1 = court.teamA.isNotEmpty ? court.teamA[0].userId : '';
    String? a2 = court.teamA.length > 1 ? court.teamA[1].userId : null;
    String b1 = court.teamB.isNotEmpty ? court.teamB[0].userId : '';
    String? b2 = court.teamB.length > 1 ? court.teamB[1].userId : null;
    final int requiredCount = courtPlayers.length;

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
                        value: currentVal.isNotEmpty ? currentVal : null,
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 380,
                    minWidth: MediaQuery.sizeOf(context).width < 400
                        ? MediaQuery.sizeOf(context).width * 0.8
                        : 360,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chọn $requiredCount tay vợt cho 2 đội (có thể đổi từ hàng đợi):',
                          style: AppTypography.bodySmall.colored(colors.textMuted)),
                      const SizedBox(height: 12),
                      Text('ĐỘI 1', style: AppTypography.labelMedium.bold.colored(colors.primary)),
                      const SizedBox(height: 6),
                      buildDropdown('Tay vợt 1A', a1, (v) {
                        if (v != null) setStateDialog(() => a1 = v);
                      }),
                      if (a2 != null)
                        buildDropdown('Tay vợt 2A', a2!, (v) {
                          if (v != null) setStateDialog(() => a2 = v);
                        }),
                      const Divider(),
                      Text('ĐỘI 2', style: AppTypography.labelMedium.bold.colored(colors.warning)),
                      const SizedBox(height: 6),
                      buildDropdown('Tay vợt 1B', b1, (v) {
                        if (v != null) setStateDialog(() => b1 = v);
                      }),
                      if (b2 != null)
                        buildDropdown('Tay vợt 2B', b2!, (v) {
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
                    final selectedList = [a1, if (a2 != null) a2!, b1, if (b2 != null) b2!];
                    final selectedSet = selectedList.toSet();
                    if (selectedSet.length < requiredCount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Vui lòng chọn $requiredCount tay vợt khác nhau')),
                      );
                      return;
                    }
                    HapticFeedback.mediumImpact();
                    final teamAIds = [a1, if (a2 != null) a2!];
                    final teamBIds = [b1, if (b2 != null) b2!];
                    vm.swapPlayers(court.matchId, teamAIds, teamBIds);
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
