// lib/ui/screen/home/tab/club/widgets/club_schedule_planner.dart

import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';

/// Che do cai dat gio cho lich dinh ky
enum ScheduleTimeMode {
  /// Gio co dinh ap dung chung cho tat ca cac ngay da tich chon
  fixed,

  /// Gio tuy chinh rieng biet cho tung ngay da tich chon
  custom,
}

/// Thong tin mot buoi tap tich chon tren lich
class ClubScheduleEntry {
  /// Ngay cu the duoc chon trong thang (VD: 2026-10-05)
  final DateTime? date;

  /// 0 = Chu Nhat, 1 = Thu 2, ..., 6 = Thu 7 (chuan ABP / C# DayOfWeek)
  final int dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;

  ClubScheduleEntry({
    this.date,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  ClubScheduleEntry copyWith({
    DateTime? date,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return ClubScheduleEntry(
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Widget hien thi Lich Thang 30/31 ngay, cho phep tich chon tung ngay va cai dat gio
class ClubSchedulePlanner extends StatefulWidget {
  final List<ClubScheduleEntry> initialSchedules;
  final ValueChanged<List<ClubScheduleEntry>> onChanged;

  const ClubSchedulePlanner({
    super.key,
    required this.initialSchedules,
    required this.onChanged,
  });

  @override
  State<ClubSchedulePlanner> createState() => _ClubSchedulePlannerState();
}

class _ClubSchedulePlannerState extends State<ClubSchedulePlanner> {
  late DateTime _focusedMonth;
  ScheduleTimeMode _timeMode = ScheduleTimeMode.fixed;

  TimeOfDay _commonStartTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _commonEndTime = const TimeOfDay(hour: 20, minute: 0);

  /// Map luu tru cac ngay da tich chon theo DateTime chuan hoa (nam-thang-ngay)
  final Map<DateTime, ClubScheduleEntry> _selectedDatesMap = {};

  // Thu tu cac thu trong tuan theo chuan Viet Nam (Thu 2 -> Chu Nhat)
  static const List<int> _weekdayOrder = [1, 2, 3, 4, 5, 6, 0];

  static const List<String> _weekdayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);

    if (widget.initialSchedules.isNotEmpty) {
      _commonStartTime = widget.initialSchedules.first.startTime;
      _commonEndTime = widget.initialSchedules.first.endTime;

      for (final s in widget.initialSchedules) {
        if (s.date != null) {
          _selectedDatesMap[_normalizeDate(s.date!)] = s.copyWith();
        } else {
          // Neu chi co dayOfWeek (tu cau hinh tuan cu), tich cac ngay tuong ung trong thang hien tai
          final totalDays = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
          for (int day = 1; day <= totalDays; day++) {
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final dow = date.weekday == 7 ? 0 : date.weekday;
            if (dow == s.dayOfWeek) {
              _selectedDatesMap[_normalizeDate(date)] = ClubScheduleEntry(
                date: date,
                dayOfWeek: dow,
                startTime: s.startTime,
                endTime: s.endTime,
              );
            }
          }
        }
      }

      // Kiem tra xem tat ca cac ngay da chon co cung khung gio khong
      bool allSame = true;
      for (final entry in _selectedDatesMap.values) {
        if (entry.startTime != _commonStartTime || entry.endTime != _commonEndTime) {
          allSame = false;
          break;
        }
      }
      _timeMode = allSame ? ScheduleTimeMode.fixed : ScheduleTimeMode.custom;
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 0:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  String _getDayFullName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Thứ Hai';
      case 2:
        return 'Thứ Ba';
      case 3:
        return 'Thứ Tư';
      case 4:
        return 'Thứ Năm';
      case 5:
        return 'Thứ Sáu';
      case 6:
        return 'Thứ Bảy';
      case 0:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  String _formatFullDate(DateTime d) {
    final dow = d.weekday == 7 ? 0 : d.weekday;
    final dayName = _getDayFullName(dow);
    final dayStr = d.day.toString().padLeft(2, '0');
    final monthStr = d.month.toString().padLeft(2, '0');
    return '$dayName, ngày $dayStr/$monthStr';
  }

  String _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    final diff = endMin - startMin;
    if (diff <= 0) return 'Không hợp lệ';
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    if (minutes == 0) return '$hours tiếng';
    return '$hours tiếng $minutes phút';
  }

  bool _isValidTime(TimeOfDay start, TimeOfDay end) {
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    return startMin < endMin;
  }

  void _notifyChange() {
    final sortedKeys = _selectedDatesMap.keys.toList()..sort();
    final sortedList = sortedKeys.map((k) => _selectedDatesMap[k]!).toList();
    widget.onChanged(sortedList);
  }

  /// Tich hoac bo tich dung mot ngay cu the tren lich thang
  void _toggleSpecificDate(DateTime date) {
    final norm = _normalizeDate(date);
    setState(() {
      if (_selectedDatesMap.containsKey(norm)) {
        _selectedDatesMap.remove(norm);
      } else {
        final dow = date.weekday == 7 ? 0 : date.weekday;
        final start = _timeMode == ScheduleTimeMode.fixed
            ? _commonStartTime
            : const TimeOfDay(hour: 18, minute: 0);
        final end = _timeMode == ScheduleTimeMode.fixed
            ? _commonEndTime
            : const TimeOfDay(hour: 20, minute: 0);

        _selectedDatesMap[norm] = ClubScheduleEntry(
          date: date,
          dayOfWeek: dow,
          startTime: start,
          endTime: end,
        );
      }
    });
    _notifyChange();
  }

  /// Tich hoac bo tich toan bo cac ngay thu dow trong thang hien tai
  void _toggleAllDatesOfWeekdayInFocusedMonth(int apiDayOfWeek) {
    final totalDays = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final datesInMonth = <DateTime>[];
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dow = date.weekday == 7 ? 0 : date.weekday;
      if (dow == apiDayOfWeek) {
        datesInMonth.add(_normalizeDate(date));
      }
    }

    final allSelected = datesInMonth.every(_selectedDatesMap.containsKey);

    setState(() {
      if (allSelected) {
        for (final d in datesInMonth) {
          _selectedDatesMap.remove(d);
        }
      } else {
        for (final d in datesInMonth) {
          final dow = d.weekday == 7 ? 0 : d.weekday;
          _selectedDatesMap[d] = ClubScheduleEntry(
            date: d,
            dayOfWeek: dow,
            startTime: _commonStartTime,
            endTime: _commonEndTime,
          );
        }
      }
    });
    _notifyChange();
  }

  void _applyPresetToFocusedMonth(List<int> weekdays) {
    final totalDays = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    setState(() {
      _selectedDatesMap.clear();
      for (int day = 1; day <= totalDays; day++) {
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final dow = date.weekday == 7 ? 0 : date.weekday;
        if (weekdays.contains(dow)) {
          final norm = _normalizeDate(date);
          _selectedDatesMap[norm] = ClubScheduleEntry(
            date: date,
            dayOfWeek: dow,
            startTime: _commonStartTime,
            endTime: _commonEndTime,
          );
        }
      }
    });
    _notifyChange();
  }

  void _clearAllSelectedDates() {
    setState(() {
      _selectedDatesMap.clear();
    });
    _notifyChange();
  }

  Future<void> _pickCommonTime({required bool isStart}) async {
    final initial = isStart ? _commonStartTime : _commonEndTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _commonStartTime = picked;
        } else {
          _commonEndTime = picked;
        }
        if (_timeMode == ScheduleTimeMode.fixed) {
          for (final key in _selectedDatesMap.keys) {
            final entry = _selectedDatesMap[key]!;
            _selectedDatesMap[key] = entry.copyWith(
              startTime: _commonStartTime,
              endTime: _commonEndTime,
            );
          }
        }
      });
      _notifyChange();
    }
  }

  Future<void> _pickCustomTime({
    required DateTime dateKey,
    required bool isStart,
  }) async {
    final entry = _selectedDatesMap[dateKey];
    if (entry == null) return;

    final initial = isStart ? entry.startTime : entry.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          entry.startTime = picked;
        } else {
          entry.endTime = picked;
        }
      });
      _notifyChange();
    }
  }

  void _copyTimeToAllDates(DateTime sourceDateKey) {
    final source = _selectedDatesMap[sourceDateKey];
    if (source == null) return;

    setState(() {
      for (final key in _selectedDatesMap.keys) {
        if (key != sourceDateKey) {
          _selectedDatesMap[key] = _selectedDatesMap[key]!.copyWith(
            startTime: source.startTime,
            endTime: source.endTime,
          );
        }
      }
    });
    _notifyChange();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã sao chép khung giờ ${_formatTime(source.startTime)} - ${_formatTime(source.endTime)} cho tất cả các ngày đã chọn.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToPreviousMonth() {
    final now = DateTime.now();
    final currentMonthFirst = DateTime(now.year, now.month, 1);
    final prev = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);

    if (prev.isBefore(currentMonthFirst)) return;

    setState(() {
      _focusedMonth = prev;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedDatesMap.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Giao dien Lich Thang 30/31 ngay (Tich chon tung ngay)
        _buildMonthCalendarCard(),

        const SizedBox(height: 12),

        // 2. Chon nhanh hoac tich theo thu
        _buildQuickWeekdaySelector(),

        const SizedBox(height: 16),

        // 3. Tab lua chon Che do Gio: Co dinh vs Tuy chinh theo ngay
        _buildTimeModeSelector(selectedCount),

        const SizedBox(height: 12),

        // 4. Panel thiet lap gio chi tiet theo che do
        if (_timeMode == ScheduleTimeMode.fixed)
          _buildFixedTimeCard(selectedCount)
        else
          _buildCustomTimeList(),
      ],
    );
  }

  /// 1. Giao dien Lich Thang 30/31 ngay
  Widget _buildMonthCalendarCard() {
    final now = DateTime.now();
    final currentMonthFirst = DateTime(now.year, now.month, 1);
    final isAtCurrentMonth = !_focusedMonth.isAfter(currentMonthFirst);

    final totalDaysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    // Monday is 1 -> 0 blanks; Sunday is 7 -> 6 blanks
    final leadingBlanks = (firstWeekday - 1) % 7;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Month Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: isAtCurrentMonth ? AppColors.borderStrong : AppColors.textPrimary,
                onPressed: isAtCurrentMonth ? null : _goToPreviousMonth,
                splashRadius: 20,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tháng ${_focusedMonth.month} / ${_focusedMonth.year}',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedDatesMap.length} ngày đã chọn',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.textPrimary,
                onPressed: _goToNextMonth,
                splashRadius: 20,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Day of week labels (T2, T3, T4, T5, T6, T7, CN)
          Row(
            children: List.generate(7, (idx) {
              final isSunday = idx == 6;
              final apiDow = _weekdayOrder[idx];

              return Expanded(
                child: InkWell(
                  onTap: () => _toggleAllDatesOfWeekdayInFocusedMonth(apiDow),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        _weekdayLabels[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSunday
                              ? AppColors.roleRose
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const Divider(height: 12, color: AppColors.border),

          // Calendar Grid (Dates: 1..30/31)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + totalDaysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox();
              }

              final dayNumber = index - leadingBlanks + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                dayNumber,
              );
              final normDate = _normalizeDate(date);
              final isSelected = _selectedDatesMap.containsKey(normDate);
              final scheduleEntry = _selectedDatesMap[normDate];

              final isToday = now.year == date.year &&
                  now.month == date.month &&
                  now.day == date.day;

              return InkWell(
                onTap: () => _toggleSpecificDate(date),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary
                              : AppColors.border,
                      width: isSelected ? 1.8 : (isToday ? 1.5 : 1),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header o lich: Check icon & Date number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked,
                            size: 13,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderStrong,
                          ),
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : isToday
                                      ? AppColors.primary
                                      : AppColors.neutral800,
                            ),
                          ),
                        ],
                      ),

                      // Footer o lich: Gio bat dau neu duoc chon
                      if (isSelected && scheduleEntry != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatTime(scheduleEntry.startTime),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Chu thich duoi lich
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 14, color: AppColors.textMuted),
              SizedBox(width: 4),
              Text(
                'Tích vào từng ngày bạn muốn đi chơi để chọn ngày đó',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Chon nhanh theo thu trong thang hien tai & Presets
  Widget _buildQuickWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chọn nhanh theo thứ trong tháng:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_selectedDatesMap.isNotEmpty)
              InkWell(
                onTap: _clearAllSelectedDates,
                child: const Text(
                  'Bỏ chọn tất cả',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Cac nut thu T2 -> CN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekdayOrder.map((dow) {
            final dayName = _getDayName(dow);

            return InkWell(
              onTap: () => _toggleAllDatesOfWeekdayInFocusedMonth(dow),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Presets: 2-4-6, 3-5-7, Cuoi tuan
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text(
                'Mẫu nhanh cả tháng:',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              _buildPresetChip('Tất cả 2 - 4 - 6', [1, 3, 5]),
              const SizedBox(width: 6),
              _buildPresetChip('Tất cả 3 - 5 - 7', [2, 4, 6]),
              const SizedBox(width: 6),
              _buildPresetChip('Tất cả Cuối tuần', [6, 0]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String title, List<int> weekdays) {
    return InkWell(
      onTap: () => _applyPresetToFocusedMonth(weekdays),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 3. Tab lua chon Che do Gio
  Widget _buildTimeModeSelector(int selectedCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _timeMode = ScheduleTimeMode.fixed;
                  for (final key in _selectedDatesMap.keys) {
                    _selectedDatesMap[key] = _selectedDatesMap[key]!.copyWith(
                      startTime: _commonStartTime,
                      endTime: _commonEndTime,
                    );
                  }
                });
                _notifyChange();
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _timeMode == ScheduleTimeMode.fixed
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _timeMode == ScheduleTimeMode.fixed
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      size: 15,
                      color: _timeMode == ScheduleTimeMode.fixed
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giờ cố định ($selectedCount ngày)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _timeMode == ScheduleTimeMode.fixed
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _timeMode = ScheduleTimeMode.custom;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _timeMode == ScheduleTimeMode.custom
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _timeMode == ScheduleTimeMode.custom
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: _timeMode == ScheduleTimeMode.custom
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giờ tùy chỉnh từng ngày',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _timeMode == ScheduleTimeMode.custom
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4a. Che do Gio Co Dinh (Fixed Time cho tat ca cac ngay da tich)
  Widget _buildFixedTimeCard(int selectedCount) {
    final isValid = _isValidTime(_commonStartTime, _commonEndTime);
    final durationText = _calculateDuration(_commonStartTime, _commonEndTime);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Khung giờ áp dụng chung:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isValid
                      ? AppColors.successContainer
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isValid ? 'Thời lượng: $durationText' : 'Giờ không hợp lệ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isValid ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Two Time Pickers
          Row(
            children: [
              Expanded(
                child: _buildTimeButton(
                  label: 'Giờ bắt đầu',
                  time: _commonStartTime,
                  onTap: () => _pickCommonTime(isStart: true),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: _buildTimeButton(
                  label: 'Giờ kết thúc',
                  time: _commonEndTime,
                  onTap: () => _pickCommonTime(isStart: false),
                ),
              ),
            ],
          ),

          if (!isValid) ...[
            const SizedBox(height: 8),
            const Text(
              'Lưu ý: Giờ bắt đầu phải trước giờ kết thúc.',
              style: TextStyle(fontSize: 11, color: AppColors.error),
            ),
          ],

          const SizedBox(height: 10),

          // Helper Text
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedCount > 0
                        ? 'Khung giờ ${_formatTime(_commonStartTime)} - ${_formatTime(_commonEndTime)} sẽ được áp dụng cho toàn bộ $selectedCount ngày bạn đã tích chọn trên lịch.'
                        : 'Chưa có ngày nào được tích chọn. Hãy bấm vào các ô ngày trên lịch tháng ở trên để chọn ngày đi chơi.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4b. Che do Gio Tuy Chinh Theo Tung Ngay Da Tich
  Widget _buildCustomTimeList() {
    final sortedKeys = _selectedDatesMap.keys.toList()..sort();

    if (sortedKeys.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 28, color: AppColors.textMuted),
            SizedBox(height: 6),
            Text(
              'Chưa tích chọn ngày nào',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Hãy chạm vào các ngày trên lịch tháng để tích chọn ngày đi chơi và cài đặt giờ.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cài đặt giờ riêng cho ${sortedKeys.length} ngày đã tích:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Tháng ${_focusedMonth.month}/${_focusedMonth.year}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...sortedKeys.map((dateKey) {
          final entry = _selectedDatesMap[dateKey]!;
          final dateTitle = _formatFullDate(dateKey);
          final isValid = _isValidTime(entry.startTime, entry.endTime);
          final durationText = _calculateDuration(entry.startTime, entry.endTime);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isValid
                    ? AppColors.border
                    : AppColors.errorBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateTitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _toggleSpecificDate(dateKey),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeButton(
                        label: 'Giờ bắt đầu',
                        time: entry.startTime,
                        onTap: () =>
                            _pickCustomTime(dateKey: dateKey, isStart: true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Expanded(
                      child: _buildTimeButton(
                        label: 'Giờ kết thúc',
                        time: entry.endTime,
                        onTap: () =>
                            _pickCustomTime(dateKey: dateKey, isStart: false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isValid
                            ? AppColors.successContainer
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isValid ? durationText : 'Lỗi giờ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isValid
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),

                if (!isValid) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Giờ bắt đầu phải trước giờ kết thúc.',
                    style: TextStyle(fontSize: 10.5, color: AppColors.error),
                  ),
                ],

                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _copyTimeToAllDates(dateKey),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Áp dụng khung giờ này cho các ngày còn lại',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
