// lib/ui/screen/club/session_operations/session_rotation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_rotation.dart';

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
            Text('Giải thuật ưu tiên thời gian nghỉ & cân bằng trình độ (FR15 - FR17)',
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
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.how_to_reg_rounded),
                label: const Text('Xem Điểm Danh (FR14)'),
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
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Hạch Toán Cầu/Sân (FR18)'),
                onPressed: () => context.push('/session/$sessionId/settlement'),
              ),
            ),
          ],
        ),
      ),
      body: asyncState.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
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

                ...snapshot.courts.map((court) => _buildCourtCard(context, court, vm)),
                AppSpacing.gapH16,

                // 3. Resting / Waiting Queue
                Text('Hàng đợi sẵn sàng vào sân (${snapshot.queuePlayers.length})',
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                AppSpacing.gapH8,
                _buildQueueSection(context, snapshot.queuePlayers),

                AppSpacing.gapH48,
              ],
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
        ],
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, CourtMatch court, SessionRotationNotifier vm) {
    final colors = context.colors;
    final isPlaying = court.isPlaying;
    final isProposed = court.isProposed;

    Color badgeColor = colors.textMuted;
    String badgeText = 'Trống';
    if (isPlaying) {
      badgeColor = colors.success;
      badgeText = 'Đang thi đấu';
    } else if (isProposed) {
      badgeColor = colors.warning;
      badgeText = 'Đề xuất sẵn sàng';
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.tag,
                ),
                child: Text(badgeText, style: AppTypography.labelSmall.bold.colored(badgeColor)),
              ),
            ],
          ),
          AppSpacing.gapH12,

          // 2 Teams Layout
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

          // Action Buttons
          if (isProposed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Bắt đầu trận đấu trên sân này'),
                onPressed: () => vm.startMatch(court.matchId),
              ),
            )
          else if (isPlaying)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  foregroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Kết thúc trận (Tự động tính 5p nghỉ)'),
                onPressed: () => vm.finishMatch(court.matchId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueueSection(BuildContext context, List<RotationPlayer> queue) {
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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: AppRadius.tag,
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline_rounded, size: 14, color: colors.primary),
              AppSpacing.gapW4,
              Text(p.fullName, style: AppTypography.labelSmall.bold.colored(colors.textPrimary)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.tag,
                ),
                child: Text('L${p.skillLevel}', style: AppTypography.labelSmall.colored(colors.primary)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
