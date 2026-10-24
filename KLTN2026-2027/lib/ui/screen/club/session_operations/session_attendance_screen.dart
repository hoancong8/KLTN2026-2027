// lib/ui/screen/club/session_operations/session_attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_attendance.dart';

final sessionAttendanceNotifierProvider =
    StateNotifierProvider.autoDispose.family<SessionAttendanceNotifier, AsyncValue<SessionAttendanceSnapshot>, String>(
        (ref, sessionId) {
  final repo = ref.watch(sessionOperationsRepositoryProvider);
  return SessionAttendanceNotifier(repo, sessionId);
});

class SessionAttendanceNotifier extends StateNotifier<AsyncValue<SessionAttendanceSnapshot>> {
  final dynamic _repo;
  final String sessionId;

  SessionAttendanceNotifier(this._repo, this.sessionId) : super(const AsyncValue.loading()) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repo.getAttendance(sessionId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markStatus(String userId, String status) async {
    try {
      final updated = await _repo.updateAttendanceStatus(
        sessionId: sessionId,
        userId: userId,
        status: status,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWalkIn(String fullName, String? phone) async {
    try {
      final updated = await _repo.addWalkIn(
        sessionId: sessionId,
        fullName: fullName,
        phoneNumber: phone,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> complete() async {
    try {
      final updated = await _repo.completeAttendance(sessionId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class SessionAttendanceScreen extends ConsumerWidget {
  final String sessionId;

  const SessionAttendanceScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncState = ref.watch(sessionAttendanceNotifierProvider(sessionId));
    final vm = ref.read(sessionAttendanceNotifierProvider(sessionId).notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm Danh Tại Sân', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
            Text('Xác nhận hội viên có mặt để nạp hàng đợi xoay tua (FR14)',
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
            onPressed: vm.loadAttendance,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWalkInDialog(context, vm),
        backgroundColor: colors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Thêm khách vãng lai'),
      ),
      body: asyncState.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (snapshot) {
          final timeStr =
              '${DateFormat('HH:mm').format(snapshot.startTime)} - ${DateFormat('HH:mm').format(snapshot.endTime)}';

          return RefreshIndicator(
            onRefresh: vm.loadAttendance,
            color: colors.primary,
            child: ListView(
              padding: AppSpacing.allBase,
              children: [
                // 1. Overview Banner
                Container(
                  padding: AppSpacing.allBase,
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: colors.cardBorder),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_filled_rounded, size: 18, color: colors.primary),
                              AppSpacing.gapW8,
                              Text(timeStr, style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: snapshot.isCompleted
                                  ? colors.success.withValues(alpha: 0.15)
                                  : colors.warning.withValues(alpha: 0.15),
                              borderRadius: AppRadius.tag,
                            ),
                            child: Text(
                              snapshot.isCompleted ? 'Đã hoàn tất điểm danh' : 'Đang mở điểm danh',
                              style: AppTypography.labelSmall.bold.colored(
                                snapshot.isCompleted ? colors.success : colors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH16,
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(context, 'Có mặt', '${snapshot.presentCount}', colors.success),
                          ),
                          AppSpacing.gapW8,
                          Expanded(
                            child: _buildMetricTile(context, 'Chưa đến', '${snapshot.notArrivedCount}', colors.warning),
                          ),
                          AppSpacing.gapW8,
                          Expanded(
                            child: _buildMetricTile(context, 'Báo vắng', '${snapshot.noShowCount}', colors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH16,

                // 2. Action to Switch to Rotation or Complete
                if (snapshot.canStartRotation) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Bàn Điều Phối Xoay Tua Sân (FR15 - FR17)'),
                    onPressed: () {
                      context.push('/session/$sessionId/rotation');
                    },
                  ),
                  AppSpacing.gapH16,
                ],

                // 3. Players List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Danh sách tay vợt (${snapshot.players.length})',
                        style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                    if (!snapshot.isCompleted)
                      TextButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Khóa điểm danh'),
                        onPressed: () async {
                          await vm.complete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã hoàn tất lượt điểm danh ban đầu!')),
                            );
                          }
                        },
                      ),
                  ],
                ),
                AppSpacing.gapH8,

                ...snapshot.players.map((p) => _buildPlayerCard(context, p, vm)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.labelSmall.colored(color)),
          AppSpacing.gapH4,
          Text(value, style: AppTypography.titleMedium.bold.colored(color)),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, AttendancePlayer player, SessionAttendanceNotifier vm) {
    final colors = context.colors;
    final isCheckedIn = player.isCheckedIn;
    final isNoShow = player.isNoShow;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isCheckedIn
              ? colors.success.withValues(alpha: 0.4)
              : (isNoShow ? colors.error.withValues(alpha: 0.4) : colors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primary.withValues(alpha: 0.15),
            child: Text(
              player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
              style: AppTypography.labelLarge.bold.colored(colors.primary),
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.fullName,
                  style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                ),
                AppSpacing.gapH4,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: AppRadius.tag,
                      ),
                      child: Text('Trình độ: L${player.skillLevel}',
                          style: AppTypography.labelSmall.colored(colors.textSecondary)),
                    ),
                    if (player.checkinAt != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Vào sân: ${DateFormat('HH:mm').format(player.checkinAt!)}',
                        style: AppTypography.labelSmall.colored(colors.textMuted),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapW8,
          // Quick Toggle Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.check_circle_rounded,
                  color: isCheckedIn ? colors.success : colors.textMuted.withValues(alpha: 0.4),
                  size: 28,
                ),
                tooltip: 'Có mặt tại sân',
                onPressed: () => vm.markStatus(player.userId, 'CHECKED_IN'),
              ),
              IconButton(
                icon: Icon(
                  Icons.cancel_rounded,
                  color: isNoShow ? colors.error : colors.textMuted.withValues(alpha: 0.4),
                  size: 28,
                ),
                tooltip: 'Vắng mặt (No-show)',
                onPressed: () => vm.markStatus(player.userId, 'NO_SHOW'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddWalkInDialog(BuildContext context, SessionAttendanceNotifier vm) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Khách Vãng Lai'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ tên khách *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                vm.addWalkIn(nameCtrl.text.trim(), phoneCtrl.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Thêm & Check-in'),
          ),
        ],
      ),
    );
  }
}
