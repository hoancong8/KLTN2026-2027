import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../../app/theme/theme.dart';
import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_vm/report_state.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_vm/report_vm.dart';

class ReportTablet extends ConsumerStatefulWidget {
  final ReportState state;
  final Future<void> Function() onRefresh;

  const ReportTablet({super.key, required this.state, required this.onRefresh});

  @override
  ConsumerState<ReportTablet> createState() => _ReportTabletState();
}

class _ReportTabletState extends ConsumerState<ReportTablet> {
  AppThemeColors get colors => context.colors;

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(reportViewModelProvider.notifier);
    final state = widget.state;

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.surface,
        onRefresh: widget.onRefresh,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Month Calendar + Mini Stats
            Container(
              width: 380,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                border: Border(right: BorderSide(color: colors.cardBorder)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildHeaderInfo(state),
                  const SizedBox(height: 20),
                  _buildMonthCalendar(state, vm),
                ],
              ),
            ),

            // Right column: Booked Sessions List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  _buildListHeader(state, vm),
                  const SizedBox(height: 16),
                  if (state.bookingsOnSelectedDate.isEmpty)
                    _buildEmptyState(state)
                  else
                    ...state.bookingsOnSelectedDate.map((b) => _buildBookingCard(b)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(ReportState state) {
    final total = state.myBookings.length;
    final confirmed = state.myBookings.where((b) => b.isConfirmed).length;
    final waiting = state.myBookings.where((b) => b.isWaiting).length;

    return Column(
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
              child: Icon(Icons.event_note_rounded, size: 22, color: colors.primary),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch Đăng Ký',
                    style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                  ),
                  Text(
                    'Lịch tháng & các suất tham gia',
                    style: AppTypography.labelSmall.colored(colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMiniStat('Tổng suất', '$total', colors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStat('Đã giữ chỗ', '$confirmed', colors.success),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStat('Hàng đợi', '$waiting', colors.warning),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.colored(color)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleMedium.bold.colored(color)),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(ReportState state, ReportViewModel vm) {
    final now = DateTime.now();
    final focusedMonth = state.focusedMonth;
    final totalDaysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;
    final leadingBlanks = (firstWeekday - 1) % 7;

    final Map<int, List<MyBookingItem>> bookingsByDay = {};
    for (final b in state.bookingsInFocusedMonth) {
      bookingsByDay.putIfAbsent(b.startTime.day, () => []).add(b);
    }

    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Tháng ${DateFormat('MM/yyyy').format(focusedMonth)}',
                style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, size: 20, color: colors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () => vm.changeMonth(-1),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, size: 20, color: colors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: () => vm.changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + totalDaysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();

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
                        style: AppTypography.labelSmall.bold.colored(textColor),
                      ),
                      if (hasBookings) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.white : colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(ReportState state, ReportViewModel vm) {
    final title = state.selectedDate != null
        ? 'Buổi sinh hoạt ngày ${DateFormat('dd/MM/yyyy').format(state.selectedDate!)}'
        : 'Danh sách các buổi đăng ký tháng ${DateFormat('MM/yyyy').format(state.focusedMonth)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title (${state.bookingsOnSelectedDate.length})',
          style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
        ),
        if (state.selectedDate != null)
          TextButton.icon(
            onPressed: () => vm.selectDate(state.selectedDate!),
            icon: const Icon(Icons.clear_rounded, size: 16),
            label: const Text('Xem cả tháng'),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: InkWell(
        onTap: () => context.push('/session/${booking.sessionId}'),
        borderRadius: AppRadius.card,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                  ? Center(child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 24))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.sessionTitle.isNotEmpty ? booking.sessionTitle : 'Buổi sinh hoạt cầu lông',
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.groups_rounded, size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(booking.clubName, style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Text('$startStr - $endStr, $dateStr', style: AppTypography.labelSmall.colored(colors.textPrimary)),
                    ],
                  ),
                  if (booking.courtLocation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text(booking.courtLocation, style: AppTypography.labelSmall.colored(colors.textMuted)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      ),
    );
  }

  Widget _buildEmptyState(ReportState state) {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 50, color: colors.textMuted),
          const SizedBox(height: 12),
          Text(
            state.selectedDate != null
                ? 'Không có lịch chơi trong ngày đã chọn'
                : 'Chưa có lịch đăng ký nào trong tháng này',
            style: AppTypography.titleMedium.bold.colored(colors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy tham gia đăng ký giữ chỗ tại các câu lạc bộ để lịch xuất hiện tại đây.',
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
        ],
      ),
    );
  }
}
