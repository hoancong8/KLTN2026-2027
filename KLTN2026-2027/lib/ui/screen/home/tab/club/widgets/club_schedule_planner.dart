// lib/ui/screen/home/tab/club/widgets/club_schedule_planner.dart

import 'package:flutter/material.dart';
import '../../../../../../app/consts/app_color.dart';

/// Che do cai dat gio cho lich dinh ky
enum ScheduleTimeMode {
  /// Gio co dinh ap dung chung cho tat ca cac ngay da chon
  fixed,

  /// Gio tuy chinh rieng biet cho tung ngay da chon
  custom,
}

/// Thong tin mot buoi tap dinh ky trong tuan
class ClubScheduleEntry {
  /// 0 = Chu Nhat, 1 = Thu 2, ..., 6 = Thu 7 (chuan ABP / C# DayOfWeek)
  final int dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;

  ClubScheduleEntry({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  ClubScheduleEntry copyWith({
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return ClubScheduleEntry(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Widget hien thi Lich Thang va thiet lap Gio sinh hoat dinh ky cho CLB / Nhom
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

  // Map luu tru theo dayOfWeek (0 = Chu Nhat, 1..6 = Thu 2..7)
  final Map<int, ClubScheduleEntry> _schedulesMap = {};

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);

    if (widget.initialSchedules.isNotEmpty) {
      for (final s in widget.initialSchedules) {
        _schedulesMap[s.dayOfWeek] = s.copyWith();
      }
      _commonStartTime = widget.initialSchedules.first.startTime;
      _commonEndTime = widget.initialSchedules.first.endTime;

      // Kiem tra xem cac ngay co cung khung gio khong
      bool allSame = true;
      for (final s in widget.initialSchedules) {
        if (s.startTime != _commonStartTime || s.endTime != _commonEndTime) {
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

  /// Tinh thoi luong giua 2 khung gio
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

  /// Danh sach cac ngay trong thang hien tai tuong ung voi thu (dayOfWeek)
  List<int> _getDaysInMonthForWeekday(int apiDayOfWeek) {
    final days = <int>[];
    final totalDays = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dow = date.weekday == 7 ? 0 : date.weekday;
      if (dow == apiDayOfWeek) {
        days.add(day);
      }
    }
    return days;
  }

  void _notifyChange() {
    final sorted = _weekdayOrder
        .where((dow) => _schedulesMap.containsKey(dow))
        .map((dow) => _schedulesMap[dow]!)
        .toList();
    widget.onChanged(sorted);
  }

  void _toggleDay(int apiDayOfWeek) {
    setState(() {
      if (_schedulesMap.containsKey(apiDayOfWeek)) {
        _schedulesMap.remove(apiDayOfWeek);
      } else {
        final start = _timeMode == ScheduleTimeMode.fixed
            ? _commonStartTime
            : const TimeOfDay(hour: 18, minute: 0);
        final end = _timeMode == ScheduleTimeMode.fixed
            ? _commonEndTime
            : const TimeOfDay(hour: 20, minute: 0);

        _schedulesMap[apiDayOfWeek] = ClubScheduleEntry(
          dayOfWeek: apiDayOfWeek,
          startTime: start,
          endTime: end,
        );
      }
    });
    _notifyChange();
  }

  void _setPreset(List<int> days) {
    setState(() {
      _schedulesMap.clear();
      for (final d in days) {
        _schedulesMap[d] = ClubScheduleEntry(
          dayOfWeek: d,
          startTime: _commonStartTime,
          endTime: _commonEndTime,
        );
      }
    });
    _notifyChange();
  }

  void _clearAllDays() {
    setState(() {
      _schedulesMap.clear();
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
        // Neu o che do co dinh, cap nhat toan bo cac ngay da chon
        if (_timeMode == ScheduleTimeMode.fixed) {
          for (final key in _schedulesMap.keys) {
            final entry = _schedulesMap[key]!;
            _schedulesMap[key] = entry.copyWith(
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
    required int dayOfWeek,
    required bool isStart,
  }) async {
    final entry = _schedulesMap[dayOfWeek];
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

  void _copyTimeToAll(int sourceDayOfWeek) {
    final source = _schedulesMap[sourceDayOfWeek];
    if (source == null) return;

    setState(() {
      for (final key in _schedulesMap.keys) {
        if (key != sourceDayOfWeek) {
          _schedulesMap[key] = _schedulesMap[key]!.copyWith(
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
          'Đã sao chép khung giờ ${_formatTime(source.startTime)} - ${_formatTime(source.endTime)} cho tất cả các ngày.',
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

    // Khong cho lui ve truoc thang hien tai
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Giao dien Lich Thang
        _buildMonthCalendarCard(),

        const SizedBox(height: 14),

        // 2. Chon nhanh cac ngay trong tuan & Presets
        _buildQuickWeekdaySelector(),

        const SizedBox(height: 16),

        // 3. Tab lua chon Che do Gio: Co dinh vs Tuy chinh theo ngay
        _buildTimeModeSelector(),

        const SizedBox(height: 12),

        // 4. Panel thiet lap gio chi tiet theo che do
        if (_timeMode == ScheduleTimeMode.fixed)
          _buildFixedTimeCard()
        else
          _buildCustomTimeList(),
      ],
    );
  }

  /// 1. Giao dien Lich Thang
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                color: isAtCurrentMonth ? const Color(0xFFCBD5E1) : AppColor.cTitle,
                onPressed: isAtCurrentMonth ? null : _goToPreviousMonth,
                splashRadius: 20,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: AppColor.cMain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tháng ${_focusedMonth.month} / ${_focusedMonth.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.cTitle,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColor.cTitle,
                onPressed: _goToNextMonth,
                splashRadius: 20,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Day of week labels (T2, T3, T4, T5, T6, T7, CN)
          Row(
            children: List.generate(7, (idx) {
              final isSunday = idx == 6;
              final apiDow = _weekdayOrder[idx];
              final isDaySelected = _schedulesMap.containsKey(apiDow);

              return Expanded(
                child: InkWell(
                  onTap: () => _toggleDay(apiDow),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isDaySelected
                          ? AppColor.cMain.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        _weekdayLabels[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDaySelected
                              ? AppColor.cMain
                              : isSunday
                                  ? const Color(0xFFE11D48)
                                  : AppColor.cMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const Divider(height: 14, color: Color(0xFFE2E8F0)),

          // Calendar Grid (Dates)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingBlanks + totalDaysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 0.95,
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
              final apiDow = date.weekday == 7 ? 0 : date.weekday;
              final isSelected = _schedulesMap.containsKey(apiDow);
              final scheduleEntry = _schedulesMap[apiDow];

              final isToday = now.year == date.year &&
                  now.month == date.month &&
                  now.day == date.day;

              return InkWell(
                onTap: () => _toggleDay(apiDow),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.cMain : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.cMain
                          : isToday
                              ? AppColor.cMain
                              : const Color(0xFFE2E8F0),
                      width: isToday ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColor.cMain.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColor.cMain
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                      if (isSelected && scheduleEntry != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatTime(scheduleEntry.startTime),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Chu thich duoi lich
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColor.cMain,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Ngày có buổi sinh hoạt (Chạm để bật/tắt)',
                style: TextStyle(fontSize: 11, color: AppColor.cMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Chon nhanh cac ngay trong tuan & Presets
  Widget _buildQuickWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn nhanh các ngày sinh hoạt trong tuần:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.cTitle,
          ),
        ),
        const SizedBox(height: 8),

        // Cac nut thu T2 -> CN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekdayOrder.map((dow) {
            final isSelected = _schedulesMap.containsKey(dow);
            final dayName = _getDayName(dow);

            return InkWell(
              onTap: () => _toggleDay(dow),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.cMain
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.cMain
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColor.cTitle,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Preset buttons: 2-4-6, 3-5-7, Cuoi tuan, Xoa
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text(
                'Mẫu nhanh:',
                style: TextStyle(fontSize: 11, color: AppColor.cMuted),
              ),
              const SizedBox(width: 8),
              _buildPresetChip('2 - 4 - 6', [1, 3, 5]),
              const SizedBox(width: 6),
              _buildPresetChip('3 - 5 - 7', [2, 4, 6]),
              const SizedBox(width: 6),
              _buildPresetChip('Cuối tuần', [6, 0]),
              const SizedBox(width: 6),
              if (_schedulesMap.isNotEmpty)
                InkWell(
                  onTap: _clearAllDays,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Text(
                      'Xóa chọn',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.cRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String title, List<int> days) {
    return InkWell(
      onTap: () => _setPreset(days),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColor.cMain,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 3. Tab lua chon Che do Gio
  Widget _buildTimeModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
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
                  // Dong bo gio co dinh cho tat ca ngay dang duoc chon
                  for (final key in _schedulesMap.keys) {
                    _schedulesMap[key] = _schedulesMap[key]!.copyWith(
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
                          const BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
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
                          ? AppColor.cMain
                          : AppColor.cMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giờ cố định chung',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _timeMode == ScheduleTimeMode.fixed
                            ? AppColor.cMain
                            : AppColor.cMuted,
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
                          const BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
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
                          ? AppColor.cMain
                          : AppColor.cMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giờ tùy chỉnh theo ngày',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _timeMode == ScheduleTimeMode.custom
                            ? AppColor.cMain
                            : AppColor.cMuted,
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

  /// 4a. Che do Gio Co Dinh (Fixed Time)
  Widget _buildFixedTimeCard() {
    final isValid = _isValidTime(_commonStartTime, _commonEndTime);
    final durationText = _calculateDuration(_commonStartTime, _commonEndTime);
    final selectedDayNames = _weekdayOrder
        .where((d) => _schedulesMap.containsKey(d))
        .map(_getDayName)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColor.cMain),
              const SizedBox(width: 6),
              const Text(
                'Khung giờ sinh hoạt cố định:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColor.cTitle,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isValid
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isValid ? 'Thời lượng: $durationText' : 'Giờ không hợp lệ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isValid ? const Color(0xFF16A34A) : AppColor.cRed,
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
                  color: AppColor.cMuted,
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
              style: TextStyle(fontSize: 11, color: AppColor.cRed),
            ),
          ],

          const SizedBox(height: 10),

          // Helper Text
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColor.cMain,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selectedDayNames.isNotEmpty
                        ? 'Khung giờ ${_formatTime(_commonStartTime)} - ${_formatTime(_commonEndTime)} áp dụng cho tất cả ${selectedDayNames.length} ngày đã chọn: ${selectedDayNames.join(", ")}.'
                        : 'Chưa có ngày nào được chọn. Hãy chạm vào các ngày trên lịch hoặc thanh chọn nhanh ở trên.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.cMuted,
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

  /// 4b. Che do Gio Tuy Chinh Theo Ngay (Custom Time per Day)
  Widget _buildCustomTimeList() {
    final selectedDays = _weekdayOrder
        .where((d) => _schedulesMap.containsKey(d))
        .toList();

    if (selectedDays.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 28, color: AppColor.cMuted),
            SizedBox(height: 6),
            Text(
              'Chưa có ngày nào được chọn',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.cTitle,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Chạm vào các ngày trên lịch hoặc các nút thứ để thiết lập giờ cho từng ngày.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColor.cMuted),
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
              'Thiết lập giờ cho ${selectedDays.length} ngày đã chọn:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColor.cTitle,
              ),
            ),
            Text(
              'Tháng ${_focusedMonth.month}/${_focusedMonth.year}',
              style: const TextStyle(fontSize: 11, color: AppColor.cMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...selectedDays.map((dow) {
          final entry = _schedulesMap[dow]!;
          final dayName = _getDayFullName(dow);
          final monthDates = _getDaysInMonthForWeekday(dow);
          final isValid = _isValidTime(entry.startTime, entry.endTime);
          final durationText = _calculateDuration(entry.startTime, entry.endTime);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isValid
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFFCA5A5),
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
                        color: AppColor.cMain,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dayName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        monthDates.isNotEmpty
                            ? 'Ngày: ${monthDates.map((d) => "$d/${_focusedMonth.month}").join(", ")}'
                            : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColor.cMuted,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _toggleDay(dow),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColor.cMuted,
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
                            _pickCustomTime(dayOfWeek: dow, isStart: true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColor.cMuted,
                      ),
                    ),
                    Expanded(
                      child: _buildTimeButton(
                        label: 'Giờ kết thúc',
                        time: entry.endTime,
                        onTap: () =>
                            _pickCustomTime(dayOfWeek: dow, isStart: false),
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
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isValid ? durationText : 'Lỗi giờ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isValid
                              ? const Color(0xFF16A34A)
                              : AppColor.cRed,
                        ),
                      ),
                    ),
                  ],
                ),

                if (!isValid) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Giờ bắt đầu phải trước giờ kết thúc.',
                    style: TextStyle(fontSize: 10.5, color: AppColor.cRed),
                  ),
                ],

                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _copyTimeToAll(dow),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: AppColor.cMain,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Áp dụng khung giờ này cho các ngày còn lại',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.cMain,
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
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColor.cMuted),
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
                    color: AppColor.cTitle,
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColor.cMain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
