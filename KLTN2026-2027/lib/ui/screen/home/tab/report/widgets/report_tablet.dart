// lib/ui/screen/home/tab/report/widgets/report_tablet.dart

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
                  _buildHeaderInfo(state, vm),
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
                  _buildFilterChips(state, vm),
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

  Widget _buildHeaderInfo(ReportState state, ReportViewModel vm) {
    final total = state.myBookings.length;
    final confirmed = state.myBookings.where((b) => b.isConfirmed && !b.isEnded).length;
    final waiting = state.myBookings.where((b) => b.isWaiting && !b.isEnded).length;
    final completed = state.myBookings.where((b) => b.isEnded).length;

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
                    'Lịch Chơi Cá Nhân',
                    style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                  ),
                  Text(
                    'Phân định rõ buổi kết thúc, chờ duyệt và đã duyệt',
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
              child: _buildMiniStat(
                'Tổng suất',
                '$total',
                colors.primary,
                isSelected: state.filter == ReportFilter.all,
                onTap: () => vm.setFilter(ReportFilter.all),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStat(
                'Suất chính thức',
                '$confirmed',
                colors.success,
                isSelected: state.filter == ReportFilter.confirmed,
                onTap: () => vm.setFilter(ReportFilter.confirmed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                'Hàng đợi chờ duyệt',
                '$waiting',
                colors.warning,
                isSelected: state.filter == ReportFilter.waiting,
                onTap: () => vm.setFilter(ReportFilter.waiting),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStat(
                'Đã kết thúc',
                '$completed',
                colors.textMuted,
                isSelected: state.filter == ReportFilter.completed,
                onTap: () => vm.setFilter(ReportFilter.completed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    Color color, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.16) : color.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleMedium.bold.colored(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ReportState state, ReportViewModel vm) {
    final filters = [
      (ReportFilter.all, 'Tất cả (${state.countAll})', Icons.apps_rounded, colors.primary),
      (ReportFilter.confirmed, 'Suất chính thức (${state.countConfirmed})', Icons.verified_rounded, colors.success),
      (ReportFilter.waiting, 'Hàng đợi chờ duyệt (${state.countWaiting})', Icons.hourglass_top_rounded, colors.warning),
      (ReportFilter.completed, 'Đã kết thúc (${state.countCompleted})', Icons.history_rounded, colors.textMuted),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.filter == f.$1;
          final color = f.$4;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => vm.setFilter(f.$1),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? color : colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : colors.cardBorder,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      f.$3,
                      size: 15,
                      color: isSelected ? AppColors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.white : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tháng ${DateFormat('MM/yyyy').format(focusedMonth)}',
                style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 20, color: colors.textPrimary),
                    onPressed: () => vm.changeMonth(-1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Tháng trước',
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 20, color: colors.textPrimary),
                    onPressed: () => vm.changeMonth(1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Tháng sau',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: weekdays
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: AppTypography.labelSmall.bold.colored(
                            day == 'CN' ? colors.error : colors.textMuted,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              final cellHeight = cellWidth * 1.15;
              final totalCells = leadingBlanks + totalDaysInMonth;
              final rowCount = (totalCells / 7).ceil();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: cellWidth / cellHeight,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: rowCount * 7,
                itemBuilder: (context, index) {
                  if (index < leadingBlanks || index >= leadingBlanks + totalDaysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final day = index - leadingBlanks + 1;
                  final date = DateTime(focusedMonth.year, focusedMonth.month, day);
                  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                  final isSelected = state.selectedDate != null &&
                      state.selectedDate!.year == date.year &&
                      state.selectedDate!.month == date.month &&
                      state.selectedDate!.day == date.day;

                  final dayBookings = bookingsByDay[day] ?? [];
                  final hasBookings = dayBookings.isNotEmpty;

                  Color bgColor = AppColors.transparent;
                  Border? border;
                  Color textColor = colors.textPrimary;

                  if (isSelected) {
                    bgColor = colors.primary;
                    textColor = AppColors.white;
                  } else if (hasBookings) {
                    final hasOngoingOrUpcoming = dayBookings.any((b) => !b.isEnded);
                    bgColor = hasOngoingOrUpcoming
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.surfaceSubtle;
                    border = Border.all(
                      color: hasOngoingOrUpcoming ? colors.primary : colors.cardBorder,
                      width: 1.5,
                    );
                    textColor = hasOngoingOrUpcoming ? colors.primary : colors.textMuted;
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
                                color: isSelected
                                    ? AppColors.white.withValues(alpha: 0.25)
                                    : (dayBookings.any((b) => !b.isEnded) ? colors.primary : colors.textMuted),
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

  Widget _buildListHeader(ReportState state, ReportViewModel vm) {
    final title = state.selectedDate != null
        ? 'Buổi chơi ngày ${DateFormat('dd/MM/yyyy').format(state.selectedDate!)}'
        : 'Tất cả buổi chơi trong tháng ${DateFormat('MM/yyyy').format(state.focusedMonth)}';

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

    final isEnded = booking.isEnded;
    final isWaiting = booking.isWaiting && !isEnded;
    final isConfirmed = booking.isConfirmed && !isEnded;
    final isFixedMember = !booking.isGuest && isConfirmed;

    Color badgeBg;
    Color badgeBorder;
    Color badgeFg;
    IconData badgeIcon;
    String badgeText;
    String explainText;
    IconData explainIcon;

    if (isEnded) {
      badgeBg = colors.surfaceSubtle;
      badgeBorder = colors.cardBorder;
      badgeFg = colors.textMuted;
      badgeIcon = Icons.flag_circle_outlined;
      badgeText = 'BUỔI ĐÃ KẾT THÚC';
      explainText = 'Buổi chơi đã hoàn tất${booking.isConfirmed ? ' • Bạn đã hoàn thành buổi này' : ''}';
      explainIcon = Icons.task_alt_rounded;
    } else if (isWaiting) {
      badgeBg = colors.warning.withValues(alpha: 0.14);
      badgeBorder = colors.warning.withValues(alpha: 0.35);
      badgeFg = colors.warning;
      badgeIcon = Icons.hourglass_top_rounded;
      badgeText = booking.isGuest
          ? (booking.queueOrder > 0 ? 'VÃNG LAI CHỜ DUYỆT (#${booking.queueOrder})' : 'VÃNG LAI CHỜ DUYỆT')
          : (booking.queueOrder > 0 ? 'HÀNG ĐỢI (#${booking.queueOrder})' : 'DANH SÁCH CHỜ');
      explainText = booking.isGuest
          ? 'Đang trong danh sách chờ • Chờ Host xác nhận suất giao lưu'
          : 'Đang trong hàng đợi • Tự động đôn lên khi có người báo vắng';
      explainIcon = Icons.access_time_rounded;
    } else if (isFixedMember) {
      badgeBg = colors.primary.withValues(alpha: 0.14);
      badgeBorder = colors.primary.withValues(alpha: 0.35);
      badgeFg = colors.primary;
      badgeIcon = Icons.verified_user_rounded;
      badgeText = 'SUẤT CỐ ĐỊNH';
      explainText = 'Lịch sinh hoạt định kỳ • Tự động giữ chỗ không cần duyệt';
      explainIcon = Icons.calendar_today_rounded;
    } else if (isConfirmed) {
      badgeBg = colors.success.withValues(alpha: 0.14);
      badgeBorder = colors.success.withValues(alpha: 0.35);
      badgeFg = colors.success;
      badgeIcon = Icons.verified_rounded;
      badgeText = booking.isGuest ? 'VÉ GIAO LƯU CHÍNH THỨC' : 'SUẤT CHÍNH THỨC';
      explainText = booking.isGuest
          ? 'Host đã duyệt suất giao lưu • Vui lòng đến sân đúng giờ'
          : 'Đã giữ chỗ chính thức • Vui lòng đến sân đúng giờ';
      explainIcon = Icons.sports_tennis_rounded;
    } else {
      badgeBg = colors.warning.withValues(alpha: 0.14);
      badgeBorder = colors.warning.withValues(alpha: 0.35);
      badgeFg = colors.warning;
      badgeIcon = Icons.hourglass_top_rounded;
      badgeText = 'CHỜ DUYỆT';
      explainText = 'Đang chờ xử lý';
      explainIcon = Icons.access_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnded ? colors.cardBackground.withValues(alpha: 0.7) : colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: isConfirmed ? colors.success.withValues(alpha: 0.4) : colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: InkWell(
        onTap: () => context.push('/session/${booking.sessionId}'),
        borderRadius: AppRadius.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isEnded
                        ? colors.surfaceSubtle
                        : (isConfirmed ? colors.success : colors.primary).withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderMd,
                    image: (booking.clubAvatarUrl != null && booking.clubAvatarUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(booking.clubAvatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (booking.clubAvatarUrl == null || booking.clubAvatarUrl!.isEmpty)
                      ? Center(
                          child: Icon(
                            isEnded ? Icons.history_rounded : Icons.sports_tennis_rounded,
                            color: isEnded ? colors.textMuted : (isConfirmed ? colors.success : colors.primary),
                            size: 24,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.sessionTitle.isNotEmpty ? booking.sessionTitle : 'Buổi sinh hoạt cầu lông',
                        style: AppTypography.titleSmall.bold.colored(
                          isEnded ? colors.textSecondary : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.groups_rounded, size: 14, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(booking.clubName, style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                          const SizedBox(width: 8),
                          // Member Type Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (booking.isGuest || booking.isWaiting)
                                  ? colors.warning.withValues(alpha: 0.12)
                                  : colors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              booking.isWaiting
                                  ? (booking.isGuest ? 'Khách vãng lai (Chờ duyệt)' : 'Hàng đợi dự bị')
                                  : (booking.isGuest
                                      ? 'Khách vãng lai'
                                      : (booking.isMonthlyMember ? 'Hội viên cố định' : 'Hội viên theo buổi')),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: (booking.isGuest || booking.isWaiting) ? colors.warning : colors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time_rounded, size: 14, color: isEnded ? colors.textMuted : colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '$startStr - $endStr, $dateStr',
                            style: AppTypography.labelSmall.colored(
                              isEnded ? colors.textSecondary : colors.textPrimary,
                            ),
                          ),
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
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: AppRadius.tag,
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 13, color: badgeFg),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: AppTypography.labelSmall.bold.colored(badgeFg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Phase Explanation Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: badgeBorder.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(explainIcon, size: 13, color: badgeFg),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      explainText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: badgeFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ReportState state) {
    String emptyMessage;
    if (state.selectedDate != null) {
      emptyMessage = 'Không có buổi chơi trong ngày đã chọn';
    } else {
      switch (state.filter) {
        case ReportFilter.confirmed:
          emptyMessage = 'Chưa có buổi chơi nào được Host xác nhận';
          break;
        case ReportFilter.waiting:
          emptyMessage = 'Hiện không có buổi nào đang trong hàng đợi chờ duyệt';
          break;
        case ReportFilter.completed:
          emptyMessage = 'Chưa có buổi chơi nào đã kết thúc trong tháng này';
          break;
        case ReportFilter.all:
          emptyMessage = 'Chưa có lịch đăng ký nào trong tháng này';
          break;
      }
    }

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
            emptyMessage,
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
