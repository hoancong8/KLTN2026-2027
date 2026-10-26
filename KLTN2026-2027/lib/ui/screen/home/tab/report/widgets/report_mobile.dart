import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../../app/theme/theme.dart';
import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_vm/report_state.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_vm/report_vm.dart';

class ReportMobile extends ConsumerStatefulWidget {
  final ReportState state;
  final Future<void> Function() onRefresh;

  const ReportMobile({super.key, required this.onRefresh, required this.state});

  @override
  ConsumerState<ReportMobile> createState() => _ReportMobileState();
}

class _ReportMobileState extends ConsumerState<ReportMobile> {
  AppThemeColors get colors => context.colors;

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(reportViewModelProvider.notifier);
    final state = widget.state;

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.allBase,
        children: [
          // 1. Header Title & Stats
          _buildSummaryCard(state),
          AppSpacing.gapH16,

          // 2. Month Calendar Card
          _buildMonthCalendarCard(state, vm),
          AppSpacing.gapH16,

          // 3. Booked Sessions List Section
          _buildBookingsHeader(state, vm),
          AppSpacing.gapH12,

          if (state.bookingsOnSelectedDate.isEmpty)
            _buildEmptyBookings(state)
          else
            ...state.bookingsOnSelectedDate.map((b) => _buildBookingCard(b)),

          AppSpacing.gapH32,
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ReportState state) {
    final total = state.myBookings.length;
    final confirmed = state.myBookings.where((b) => b.isConfirmed).length;
    final waiting = state.myBookings.where((b) => b.isWaiting).length;

    return Container(
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(Icons.event_note_rounded, size: 20, color: colors.primary),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch Đăng Ký Tham Gia',
                      style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                    ),
                    Text(
                      'Theo dõi và quản lý các buổi sinh hoạt đã giữ chỗ',
                      style: AppTypography.labelSmall.colored(colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Tổng số suất',
                  '$total',
                  colors.primary,
                  Icons.sports_tennis_rounded,
                ),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: _buildMiniStat(
                  'Đã giữ chỗ',
                  '$confirmed',
                  colors.success,
                  Icons.check_circle_outline_rounded,
                ),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: _buildMiniStat(
                  'Hàng đợi',
                  '$waiting',
                  colors.warning,
                  Icons.access_time_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              AppSpacing.gapW4,
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.colored(color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapH4,
          Text(
            value,
            style: AppTypography.titleMedium.bold.colored(color),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarCard(ReportState state, ReportViewModel vm) {
    final now = DateTime.now();
    final focusedMonth = state.focusedMonth;
    final totalDaysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;
    final leadingBlanks = (firstWeekday - 1) % 7;

    // Group bookings in focused month by day
    final Map<int, List<MyBookingItem>> bookingsByDay = {};
    for (final b in state.bookingsInFocusedMonth) {
      bookingsByDay.putIfAbsent(b.startTime.day, () => []).add(b);
    }

    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      padding: AppSpacing.allBase,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header Row with Navigation
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(Icons.calendar_month_rounded, size: 18, color: colors.primary),
              ),
              AppSpacing.gapW8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch Tháng ${DateFormat('MM/yyyy').format(focusedMonth)}',
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                  ),
                  Text(
                    '${state.bookingsInFocusedMonth.length} buổi đã đăng ký',
                    style: AppTypography.labelSmall.colored(colors.textMuted),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, size: 22, color: colors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => vm.changeMonth(-1),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, size: 22, color: colors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => vm.changeMonth(1),
              ),
            ],
          ),
          AppSpacing.gapH12,

          // Weekdays header
          Row(
            children: weekdays.map((label) {
              final isWeekend = label == 'T7' || label == 'CN';
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.bold.colored(
                      isWeekend ? colors.warning : colors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapH8,

          // Calendar Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cellWidth = (availableWidth - 36) / 7;
              final targetHeight = availableWidth > 500 ? 44.0 : 42.0;
              final aspectRatio = (cellWidth / targetHeight).clamp(0.9, 3.5);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadingBlanks + totalDaysInMonth,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingBlanks) {
                    return const SizedBox.shrink();
                  }

                  final day = index - leadingBlanks + 1;
                  final date = DateTime(focusedMonth.year, focusedMonth.month, day);
                  final dayBookings = bookingsByDay[day] ?? [];
                  final hasBookings = dayBookings.isNotEmpty;

                  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                  final isSelected = state.selectedDate != null &&
                      date.year == state.selectedDate!.year &&
                      date.month == state.selectedDate!.month &&
                      date.day == state.selectedDate!.day;

                  Color bgColor = AppColors.transparent;
                  Color textColor = colors.textPrimary;
                  Border? border;

                  if (isSelected) {
                    bgColor = colors.primary;
                    textColor = AppColors.white;
                  } else if (hasBookings) {
                    bgColor = colors.primary.withValues(alpha: 0.12);
                    border = Border.all(color: colors.primary, width: 1.5);
                    textColor = colors.primary;
                  } else if (isToday) {
                    border = Border.all(color: colors.primary.withValues(alpha: 0.5), width: 1);
                  }

                  return InkWell(
                    onTap: () => vm.selectDate(date),
                    borderRadius: AppRadius.borderSm,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: AppRadius.borderSm,
                        border: border,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: AppTypography.labelMedium.bold.colored(textColor),
                          ),
                          if (hasBookings) ...[
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.white.withValues(alpha: 0.25) : colors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '${DateFormat('HH:mm').format(dayBookings.first.startTime)} - ${DateFormat('HH:mm').format(dayBookings.first.endTime)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsHeader(ReportState state, ReportViewModel vm) {
    final title = state.selectedDate != null
        ? 'Buổi chơi ngày ${DateFormat('dd/MM/yyyy').format(state.selectedDate!)}'
        : 'Tất cả buổi chơi trong tháng ${DateFormat('MM/yyyy').format(state.focusedMonth)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title (${state.bookingsOnSelectedDate.length})',
          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
        ),
        if (state.selectedDate != null)
          TextButton(
            onPressed: () => vm.selectDate(state.selectedDate!),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Xem cả tháng',
              style: AppTypography.labelSmall.bold.colored(colors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildBookingCard(MyBookingItem booking) {
    final startStr = DateFormat('HH:mm').format(booking.startTime);
    final endStr = DateFormat('HH:mm').format(booking.endTime);
    final dateStr = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(booking.startTime);
    final isConfirmed = booking.isConfirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      padding: AppSpacing.allBase,
      child: InkWell(
        onTap: () => context.push('/session/${booking.sessionId}'),
        borderRadius: AppRadius.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar / Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderMd,
                    image: (booking.clubAvatarUrl != null && booking.clubAvatarUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(booking.clubAvatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (booking.clubAvatarUrl == null || booking.clubAvatarUrl!.isEmpty)
                      ? Center(child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 22))
                      : null,
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.sessionTitle.isNotEmpty ? booking.sessionTitle : 'Buổi sinh hoạt cầu lông',
                        style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                      ),
                      AppSpacing.gapH4,
                      Row(
                        children: [
                          Icon(Icons.groups_rounded, size: 14, color: colors.textSecondary),
                          AppSpacing.gapW4,
                          Expanded(
                            child: Text(
                              booking.clubName,
                              style: AppTypography.labelSmall.bold.colored(colors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isConfirmed ? colors.success : colors.warning).withValues(alpha: 0.15),
                    borderRadius: AppRadius.tag,
                    border: Border.all(
                      color: (isConfirmed ? colors.success : colors.warning).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isConfirmed ? 'Đã giữ chỗ' : 'Hàng đợi #${booking.queueOrder}',
                    style: AppTypography.labelSmall.bold.colored(
                      isConfirmed ? colors.success : colors.warning,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            Divider(height: 1, color: colors.cardBorder),
            AppSpacing.gapH12,
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: colors.primary),
                AppSpacing.gapW4,
                Text(
                  '$startStr - $endStr, $dateStr',
                  style: AppTypography.labelSmall.colored(colors.textPrimary),
                ),
              ],
            ),
            if (booking.courtLocation.isNotEmpty) ...[
              AppSpacing.gapH4,
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: colors.textMuted),
                  AppSpacing.gapW4,
                  Expanded(
                    child: Text(
                      booking.courtLocation,
                      style: AppTypography.labelSmall.colored(colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBookings(ReportState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 44, color: colors.textMuted),
          AppSpacing.gapH12,
          Text(
            state.selectedDate != null
                ? 'Không có lịch chơi trong ngày đã chọn'
                : 'Chưa có lịch đăng ký nào trong tháng này',
            style: AppTypography.titleSmall.bold.colored(colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapH4,
          Text(
            'Hãy tham gia đăng ký giữ chỗ tại các câu lạc bộ để lịch xuất hiện tại đây.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
        ],
      ),
    );
  }
}
