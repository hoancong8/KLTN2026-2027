// lib/ui/screen/club/session_operations/session_attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_attendance.dart';
import '../../../../widget/app_shimmer.dart';
import '../../../../widget/app_status_badge.dart';
import 'session_rotation_screen.dart';

final sessionAttendanceNotifierProvider =
    StateNotifierProvider.autoDispose.family<SessionAttendanceNotifier, AsyncValue<SessionAttendanceSnapshot>, String>(
        (ref, sessionId) {
  final repo = ref.watch(sessionOperationsRepositoryProvider);
  return SessionAttendanceNotifier(repo, sessionId, ref);
});

class SessionAttendanceNotifier extends StateNotifier<AsyncValue<SessionAttendanceSnapshot>> {
  final dynamic _repo;
  final String sessionId;
  final Ref ref;

  SessionAttendanceNotifier(this._repo, this.sessionId, this.ref) : super(const AsyncValue.loading()) {
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
      ref.invalidate(sessionRotationNotifierProvider(sessionId));
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
      ref.invalidate(sessionRotationNotifierProvider(sessionId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> complete() async {
    try {
      final updated = await _repo.completeAttendance(sessionId);
      state = AsyncValue.data(updated);
      ref.invalidate(sessionRotationNotifierProvider(sessionId));
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
            Text('Xác nhận hội viên có mặt để nạp hàng đợi xoay tua',
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
      floatingActionButton: asyncState.maybeWhen(
        data: (snapshot) {
          final now = DateTime.now();
          final isOngoing = now.isAfter(snapshot.startTime) && now.isBefore(snapshot.endTime) && !snapshot.isCompleted;
          if (!isOngoing) return null;
          return FloatingActionButton.extended(
            onPressed: () => _showAddWalkInDialog(context, vm),
            backgroundColor: colors.primary,
            foregroundColor: AppColors.white,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Thêm khách vãng lai'),
          );
        },
        orElse: () => null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: asyncState.when(
            loading: () => ListView(
              padding: AppSpacing.allBase,
              children: [
                AppShimmer.card(height: 120),
                AppSpacing.gapH16,
                AppShimmer.line(width: 180, height: 20),
                AppSpacing.gapH12,
                AppShimmer.card(height: 72),
                AppSpacing.gapH8,
                AppShimmer.card(height: 72),
                AppSpacing.gapH8,
                AppShimmer.card(height: 72),
              ],
            ),
            error: (err, _) => Padding(
              padding: AppSpacing.allXl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                  AppSpacing.gapH12,
                  Text('Không thể tải điểm danh', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
                  AppSpacing.gapH4,
                  Text('$err', style: AppTypography.bodySmall.colored(colors.textMuted), textAlign: TextAlign.center),
                  AppSpacing.gapH16,
                  ElevatedButton.icon(
                    onPressed: vm.loadAttendance,
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
              final now = DateTime.now();
              final isOngoing = now.isAfter(snapshot.startTime) && now.isBefore(snapshot.endTime);
              final isUpcoming = now.isBefore(snapshot.startTime);
              final isExpired = now.isAfter(snapshot.endTime);
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
                              snapshot.isCompleted
                                  ? const AppStatusBadge.success(label: 'Đã hoàn tất điểm danh')
                                  : isUpcoming
                                      ? const AppStatusBadge.neutral(label: 'Chưa tới giờ chơi')
                                      : isOngoing
                                          ? const AppStatusBadge.warning(label: 'Đang mở điểm danh')
                                          : const AppStatusBadge.neutral(label: 'Đã kết thúc giờ chơi'),
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
                    if (isUpcoming) ...[
                      AppSpacing.gapH12,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.1),
                          borderRadius: AppRadius.card,
                          border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 20, color: colors.warning),
                            AppSpacing.gapW12,
                            Expanded(
                              child: Text(
                                'Buổi chơi chưa diễn ra. Điểm danh tại sân chỉ mở khi buổi chơi bắt đầu.',
                                style: AppTypography.bodySmall.medium.colored(colors.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isExpired && !snapshot.isCompleted) ...[
                      AppSpacing.gapH12,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: AppRadius.card,
                          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 20, color: colors.error),
                            AppSpacing.gapW12,
                            Expanded(
                              child: Text(
                                'Buổi chơi đã kết thúc thời gian thi đấu.',
                                style: AppTypography.bodySmall.medium.colored(colors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        label: const Text('Bàn Điều Phối Xoay Tua Sân'),
                        onPressed: () {
                          HapticFeedback.lightImpact();
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
                        if (!snapshot.isCompleted && isOngoing)
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                            label: const Text('Khóa điểm danh'),
                            onPressed: () => _confirmCompleteAttendance(context, vm),
                          ),
                      ],
                    ),
                    AppSpacing.gapH8,

                    if (snapshot.players.isEmpty)
                      Container(
                        padding: AppSpacing.allXl,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.group_off_rounded, size: 48, color: colors.textMuted),
                            AppSpacing.gapH12,
                            Text(
                              'Chưa có thành viên nào đăng ký buổi chơi này',
                              style: AppTypography.bodyMedium.colored(colors.textMuted),
                            ),
                          ],
                        ),
                      )
                    else
                      ...snapshot.players.map((p) => _buildPlayerCard(context, p, vm, isOngoing && !snapshot.isCompleted)),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
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

  Widget _buildPlayerCard(BuildContext context, AttendancePlayer player, SessionAttendanceNotifier vm, bool canCheckIn) {
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
          // Quick Toggle Action Chips (Touch target >= 44dp)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: canCheckIn
                    ? () {
                        HapticFeedback.lightImpact();
                        vm.markStatus(player.userId, 'CHECKED_IN');
                      }
                    : null,
                borderRadius: AppRadius.tag,
                child: Opacity(
                  opacity: canCheckIn ? 1.0 : 0.45,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44, minWidth: 68),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCheckedIn ? colors.success : colors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.tag,
                      border: Border.all(color: colors.success.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 16, color: isCheckedIn ? AppColors.white : colors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Có mặt',
                          style: AppTypography.labelSmall.bold.colored(isCheckedIn ? AppColors.white : colors.success),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: canCheckIn ? () => _confirmMarkNoShow(context, player, vm) : null,
                borderRadius: AppRadius.tag,
                child: Opacity(
                  opacity: canCheckIn ? 1.0 : 0.45,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44, minWidth: 64),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isNoShow ? colors.error : colors.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.tag,
                      border: Border.all(color: colors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close_rounded, size: 16, color: isNoShow ? AppColors.white : colors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Vắng',
                          style: AppTypography.labelSmall.bold.colored(isNoShow ? AppColors.white : colors.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmMarkNoShow(BuildContext context, AttendancePlayer player, SessionAttendanceNotifier vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận báo vắng'),
        content: Text(
          'Đánh dấu "${player.fullName}" vắng mặt? Hệ thống sẽ giải phóng suất và loại khỏi danh sách xoay tua.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              vm.markStatus(player.userId, 'NO_SHOW');
              Navigator.of(ctx).pop();
            },
            child: const Text('Xác nhận vắng'),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteAttendance(BuildContext context, SessionAttendanceNotifier vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khóa lượt điểm danh ban đầu'),
        content: const Text(
          'Xác nhận hoàn tất lượt điểm danh? Các tay vợt có mặt sẽ được nạp vào hàng đợi xoay tua.',
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
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop();
              await vm.complete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hoàn tất lượt điểm danh ban đầu!')),
                );
              }
            },
            child: const Text('Khóa điểm danh'),
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
        content: SingleChildScrollView(
          child: Column(
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
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                HapticFeedback.lightImpact();
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
