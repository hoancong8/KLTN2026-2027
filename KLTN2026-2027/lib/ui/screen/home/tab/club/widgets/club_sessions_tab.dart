// lib/ui/screen/home/tab/club/widgets/club_sessions_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../domain/entities/session/session.dart';
import '../../../../../../domain/enums/session_enums.dart';
import '../../../../club/session_vm/club_sessions_vm.dart';
import '../../../../club/widgets/create_session_dialog.dart';

class ClubSessionsTab extends ConsumerStatefulWidget {
  final String clubId;
  final String clubName;
  final bool isHost;

  const ClubSessionsTab({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.isHost,
  });

  @override
  ConsumerState<ClubSessionsTab> createState() => _ClubSessionsTabState();
}

class _ClubSessionsTabState extends ConsumerState<ClubSessionsTab> {
  late DateTime _focusedMonth;

  AppThemeColors get colors => context.colors;
  AppLocalizations get l10n => context.l10n;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  String _getWeekdayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  String _getTimeRemainingLabel(DateTime sessionTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(sessionTime.year, sessionTime.month, sessionTime.day);
    final diffDays = sessionDate.difference(today).inDays;

    if (diffDays == 0) {
      if (sessionTime.isAfter(now)) {
        return 'Hôm nay';
      } else {
        return 'Đang diễn ra';
      }
    } else if (diffDays == 1) {
      return 'Ngày mai';
    } else if (diffDays > 1 && diffDays <= 7) {
      return 'Còn $diffDays ngày';
    } else if (diffDays > 7) {
      return DateFormat('dd/MM').format(sessionTime);
    } else {
      return 'Đã kết thúc';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubSessionsViewModelProvider(widget.clubId));
    final vm = ref.read(clubSessionsViewModelProvider(widget.clubId).notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.read(clubSessionsViewModelProvider(widget.clubId).notifier).loadSessions(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final sortedSessions = List<Session>.from(state.sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final upcomingSessions = sortedSessions.where(
      (s) => s.endTime.isAfter(now) && s.status != SessionStatus.completed,
    ).toList();

    final Session? nearestSession = upcomingSessions.isNotEmpty
        ? upcomingSessions.first
        : (sortedSessions.isNotEmpty ? sortedSessions.last : null);

    final List<Session> displaySessions;
    if (_selectedDate != null) {
      displaySessions = sortedSessions.where((s) {
        return s.startTime.year == _selectedDate!.year &&
            s.startTime.month == _selectedDate!.month &&
            s.startTime.day == _selectedDate!.day;
      }).toList();
    } else {
      displaySessions = sortedSessions;
    }

    final canCreateSession = widget.isHost || ref.hasClubPermission('OPERATIONS.SESSION.CREATE');

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: canCreateSession
          ? FloatingActionButton.extended(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo buổi chơi', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                final sessionId = await CreateSessionDialog.show(
                  context,
                  clubId: widget.clubId,
                  clubName: widget.clubName,
                );
                if (sessionId != null && context.mounted) {
                  ref.read(clubSessionsViewModelProvider(widget.clubId).notifier).loadSessions();
                }
              },
            )
          : null,
      body: RefreshIndicator(
        onRefresh: vm.loadSessions,
        color: AppColors.primary,
        child: state.sessions.isEmpty
            ? _buildEmptyState(context)
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. Buổi tập gần nhất (Đưa lên trên cùng để nhận biết lịch tiếp theo)
                  if (nearestSession != null)
                    _buildNearestSessionHero(context, nearestSession),

                  // 2. Banner truy cập nhanh: Lịch tôi đã đăng ký
                  InkWell(
                    onTap: () => context.push(AppConfig.myBookingsRoutePath),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lịch tập tôi đã đăng ký',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.textPrimary),
                                ),
                                Text(
                                  'Xem danh sách vé, check-in và trạng thái giữ chỗ',
                                  style: TextStyle(fontSize: 11, color: colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),

                  // 3. Lịch tháng trực quan về các ngày tập
                  _buildMonthCalendarCard(sortedSessions, nearestSession),

                  // 4. Thanh lọc ngày đã chọn trên lịch
                  if (_selectedDate != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Lịch ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate!)} (${displaySessions.length} buổi)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _selectedDate = null),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 5. Danh sách các buổi tập
                  if (displaySessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.event_busy_rounded, color: colors.textMuted, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'Không có buổi tập nào vào ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                              style: TextStyle(fontSize: 13, color: colors.textMuted),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() => _selectedDate = null),
                              child: const Text('Xem tất cả các buổi tập'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...displaySessions.map((session) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SessionCard(
                            session: session,
                            onTap: () {
                              context.push(AppConfig.sessionDetailRoutePath(session.id));
                            },
                          ),
                        )),
                ],
              ),
      ),
    );
  }

  /// 1. Card Buổi tập gần nhất (Đưa lên trên cùng)
  Widget _buildNearestSessionHero(BuildContext context, Session session) {
    final remainingLabel = _getTimeRemainingLabel(session.startTime);
    final isToday = remainingLabel == 'Hôm nay' || remainingLabel == 'Đang diễn ra';
    final progress = session.maxPlayers > 0 ? (session.confirmedCount / session.maxPlayers).clamp(0.0, 1.0) : 0.0;
    final isFull = session.isFull;
    final timeRange = '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}';
    final dateStr = '${_getWeekdayName(session.startTime)}, ngày ${DateFormat('dd/MM/yyyy').format(session.startTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push(AppConfig.sessionDetailRoutePath(session.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Badge Lịch gần nhất + Tag thời gian
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: AppColors.white),
                        SizedBox(width: 4),
                        Text(
                          'BUỔI TẬP GẦN NHẤT',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.accentOrange.withValues(alpha: 0.15)
                          : AppColors.roleSky.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday
                            ? AppColors.accentOrange.withValues(alpha: 0.4)
                            : AppColors.roleSky.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      remainingLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isToday ? AppColors.accentOrange : AppColors.roleSky,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (session.isBookedByCurrentUser)
                    _buildUserTicketBadge(session.currentUserBookingStatus, session.currentUserQueueOrder),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                session.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Date & Time Row
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 12, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          timeRange,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Court location
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 15, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      session.courtLocation,
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Capacity Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: colors.cardBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFull ? colors.warning : colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${session.confirmedCount}/${session.maxPlayers} slot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFull ? colors.warning : colors.primary,
                    ),
                  ),
                  if (session.waitingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${session.waitingCount} chờ',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.sports_tennis_rounded, size: 18),
                  label: Text(
                    session.isBookedByCurrentUser ? 'Xem chi tiết & Điểm danh' : 'Xem chi tiết & Giữ chỗ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () => context.push(AppConfig.sessionDetailRoutePath(session.id)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2. Giao diện Lịch Tháng trực quan về các ngày tập
  Widget _buildMonthCalendarCard(List<Session> allSessions, Session? nearestSession) {
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    // Monday is 1 -> 0 blanks; Sunday is 7 -> 6 blanks
    final leadingBlanks = (firstWeekday - 1) % 7;

    // Lọc các buổi tập trong tháng đang xem
    final sessionsInMonth = allSessions.where((s) {
      return s.startTime.year == _focusedMonth.year && s.startTime.month == _focusedMonth.month;
    }).toList();

    // Map các ngày trong tháng có buổi tập
    final Map<int, List<Session>> sessionsByDay = {};
    for (final s in sessionsInMonth) {
      sessionsByDay.putIfAbsent(s.startTime.day, () => []).add(s);
    }

    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header Row with Navigation
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch Tập Tháng ${DateFormat('MM/yyyy').format(_focusedMonth)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${sessionsInMonth.length} buổi tập dự kiến',
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ),
              const Spacer(),
              // Month Navigation Buttons
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, size: 22, color: colors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, size: 22, color: colors.textPrimary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday Header Row
          Row(
            children: weekdays.map((label) {
              final isWeekend = label == 'T7' || label == 'CN';
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isWeekend ? AppColors.accentOrange : colors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + totalDaysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }

              final day = index - leadingBlanks + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final daySessions = sessionsByDay[day] ?? [];
              final hasSessions = daySessions.isNotEmpty;

              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isSelected = _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;
              final isNearest = nearestSession != null &&
                  date.year == nearestSession.startTime.year &&
                  date.month == nearestSession.startTime.month &&
                  date.day == nearestSession.startTime.day;

              // Visual styling
              Color bgColor = AppColors.transparent;
              Color textColor = colors.textPrimary;
              Border? border;

              if (isSelected) {
                bgColor = AppColors.primary;
                textColor = AppColors.white;
              } else if (hasSessions) {
                if (isNearest) {
                  bgColor = AppColors.primary.withValues(alpha: 0.18);
                  border = Border.all(color: AppColors.primary, width: 1.5);
                  textColor = AppColors.primary;
                } else {
                  bgColor = AppColors.primary.withValues(alpha: 0.08);
                  textColor = AppColors.primary;
                }
              } else if (isToday) {
                border = Border.all(color: AppColors.neutral400, width: 1);
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDate = null;
                    } else {
                      _selectedDate = date;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: border,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: (hasSessions || isSelected || isToday) ? FontWeight.bold : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      if (hasSessions) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.white : colors.primary,
                              ),
                            ),
                            if (daySessions.length > 1) ...[
                              const SizedBox(width: 2),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.white.withValues(alpha: 0.7) : AppColors.accentOrange,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          // Legend
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 5),
              Text('Ngày có buổi tập', style: TextStyle(fontSize: 11, color: colors.textMuted)),
              const SizedBox(width: 14),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: AppColors.primary.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
              ),
              const SizedBox(width: 5),
              Text('Buổi gần nhất', style: TextStyle(fontSize: 11, color: colors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_rounded, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa Có Buổi Sinh Hoạt Mới',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Các buổi giao lưu sắp tới của câu lạc bộ sẽ hiển thị ở đây để bạn biểu quyết giữ chỗ.',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => context.push(AppConfig.myBookingsRoutePath),
              icon: const Icon(Icons.event_available_rounded, size: 18),
              label: const Text('Xem Lịch Tôi Đã Đăng Ký'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (widget.isHost) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.read(clubSessionsViewModelProvider(widget.clubId).notifier).loadSessions(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tải lại lịch tập tự động'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserTicketBadge(BookingStatus? status, int queueOrder) {
    if (status == BookingStatus.waiting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: AppRadius.tag,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 12, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'Hàng đợi #$queueOrder',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Đã giữ chỗ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    final timeStr = '${DateFormat('HH:mm').format(session.startTime)} - ${dateFormat.format(session.endTime)}';
    final progress = session.maxPlayers > 0 ? (session.confirmedCount / session.maxPlayers).clamp(0.0, 1.0) : 0.0;
    final isFull = session.isFull;

    return Card(
      elevation: 0.8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: session.isBookedByCurrentUser ? colors.primary : colors.cardBorder,
          width: session.isBookedByCurrentUser ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Status badge & User booking tag
              Row(
                children: [
                  _buildStatusBadge(session.status, colors),
                  const Spacer(),
                  if (session.isBookedByCurrentUser)
                    _buildUserTicketBadge(session.currentUserBookingStatus, session.currentUserQueueOrder),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                session.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Court Location
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: colors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session.courtLocation,
                      style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Time
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16, color: colors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 13, color: colors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Capacity Progress
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: colors.cardBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFull ? colors.warning : colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${session.confirmedCount}/${session.maxPlayers} slot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFull ? colors.warning : colors.primary,
                    ),
                  ),
                  if (session.waitingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: AppRadius.borderXs,
                      ),
                      child: Text(
                        '${session.waitingCount} chờ',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentDark),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status, AppThemeColors colors) {
    Color bg;
    Color fg;
    switch (status) {
      case SessionStatus.open:
        bg = AppColors.successLight;
        fg = AppColors.roleMember;
        break;
      case SessionStatus.locked:
        bg = AppColors.warningLight;
        fg = AppColors.roleTreasurer;
        break;
      case SessionStatus.playing:
        bg = AppColors.infoLight;
        fg = AppColors.indigo;
        break;
      default:
        bg = colors.surfaceSubtle;
        fg = colors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildUserTicketBadge(BookingStatus? status, int queueOrder) {
    if (status == BookingStatus.waiting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: AppRadius.tag,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 12, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              'Hàng đợi #$queueOrder',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Đã giữ chỗ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
