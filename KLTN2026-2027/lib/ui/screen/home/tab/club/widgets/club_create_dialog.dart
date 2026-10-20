// lib/ui/screen/home/tab/club/widgets/club_create_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/consts/app_color.dart';
import '../../../../../../domain/enums/session_enums.dart';
import '../../../../club/club_vm/club_context_vm.dart';

class _ScheduleEntry {
  int dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;

  _ScheduleEntry({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}

class ClubCreateDialog extends ConsumerStatefulWidget {
  const ClubCreateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ClubCreateDialog(),
    );
  }

  @override
  ConsumerState<ClubCreateDialog> createState() => _ClubCreateDialogState();
}

class _ClubCreateDialogState extends ConsumerState<ClubCreateDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _descController;
  late final TextEditingController _venueController;
  late final TextEditingController _addressController;

  SkillLevel _minLevel = SkillLevel.nb;
  SkillLevel _maxLevel = SkillLevel.k;

  bool _hasSchedule = false;
  final List<_ScheduleEntry> _schedules = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  static const List<MapEntry<int, String>> _dayOptions = [
    MapEntry(1, 'Thứ 2'),
    MapEntry(2, 'Thứ 3'),
    MapEntry(3, 'Thứ 4'),
    MapEntry(4, 'Thứ 5'),
    MapEntry(5, 'Thứ 6'),
    MapEntry(6, 'Thứ 7'),
    MapEntry(0, 'Chủ Nhật'),
  ];

  static const List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=150',
    'https://images.unsplash.com/photo-1613918431703-aa6321ab85ec?w=150',
    'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _descController = TextEditingController();
    _venueController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(int index, bool isStart) async {
    final item = _schedules[index];
    final initial = isStart ? item.startTime : item.endTime;
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
          item.startTime = picked;
        } else {
          item.endTime = picked;
        }
      });
    }
  }

  void _addScheduleEntry() {
    setState(() {
      _schedules.add(
        _ScheduleEntry(
          dayOfWeek: 3,
          startTime: const TimeOfDay(hour: 19, minute: 0),
          endTime: const TimeOfDay(hour: 21, minute: 0),
        ),
      );
    });
  }

  void _removeScheduleEntry(int index) {
    setState(() {
      _schedules.removeAt(index);
      if (_schedules.isEmpty) {
        _hasSchedule = false;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasSchedule) {
      if (_schedules.isEmpty) {
        setState(() {
          _errorMessage = 'Vui lòng thêm ít nhất một khung giờ sinh hoạt hoặc bỏ chọn lịch cố định.';
        });
        return;
      }

      for (int i = 0; i < _schedules.length; i++) {
        final entry = _schedules[i];
        final startMin = entry.startTime.hour * 60 + entry.startTime.minute;
        final endMin = entry.endTime.hour * 60 + entry.endTime.minute;
        if (startMin >= endMin) {
          setState(() {
            _errorMessage = 'Buổi thứ ${i + 1}: Giờ bắt đầu (${_formatTime(entry.startTime)}) phải trước giờ kết thúc (${_formatTime(entry.endTime)}).';
          });
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    final vm = ref.read(clubContextViewModelProvider.notifier);

    final schedulesList = _hasSchedule && _schedules.isNotEmpty
        ? _schedules.map((s) => {
            'dayOfWeek': s.dayOfWeek,
            'startTime': _formatTime(s.startTime),
            'endTime': _formatTime(s.endTime),
          }).toList()
        : null;

    final ok = await vm.createClub(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      avatarUrl: _avatarUrlController.text.trim().isNotEmpty ? _avatarUrlController.text.trim() : null,
      fixedVenueName: _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : null,
      fixedAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      minSkillLevel: _minLevel.level,
      maxSkillLevel: _maxLevel.level,
      schedules: schedulesList,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chúc mừng! Bạn đã tạo CLB thành công và trở thành Chủ nhóm (Host).'),
          backgroundColor: AppColor.cGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final err = ref.read(clubContextViewModelProvider).error;
      setState(() {
        _errorMessage = err?.message ?? 'Không thể tạo câu lạc bộ. Vui lòng kiểm tra lại kết nối mạng.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 580 ? 540.0 : screenWidth * 0.94;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.cMain.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_business_rounded, color: AppColor.cMain, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo Câu Lạc Bộ Mới',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.cTitle,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Khởi tạo nhóm cầu lông và trở thành Host',
                          style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColor.cMuted),
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColor.cRed, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(fontSize: 12, color: AppColor.cRed, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section 1: Thong tin co ban
                      _buildSectionHeader('1. Thông tin cơ bản', Icons.info_outline_rounded),
                      const SizedBox(height: 10),

                      const Text('Tên câu lạc bộ *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: CLB Cầu Lông Chiến Binh',
                          prefixIcon: const Icon(Icons.groups_rounded, color: AppColor.cMuted, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập tên câu lạc bộ';
                          }
                          if (v.trim().length < 3) {
                            return 'Tên câu lạc bộ phải có ít nhất 3 ký tự';
                          }
                          if (v.trim().length > 100) {
                            return 'Tên câu lạc bộ tối đa 100 ký tự';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),
                      const Text('Ảnh đại diện (Avatar URL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _avatarUrlController,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'https://...',
                                prefixIcon: const Icon(Icons.image_outlined, color: AppColor.cMuted, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                              image: _avatarUrlController.text.trim().isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_avatarUrlController.text.trim()),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _avatarUrlController.text.trim().isEmpty
                                ? const Icon(Icons.sports_tennis_rounded, color: AppColor.cMuted, size: 24)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quick Avatar Presets
                      Wrap(
                        spacing: 8,
                        children: [
                          const Text('Gợi ý ảnh:', style: TextStyle(fontSize: 11, color: AppColor.cMuted)),
                          ..._avatarPresets.asMap().entries.map((e) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _avatarUrlController.text = e.value;
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Text(
                                  'Mẫu ${e.key + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColor.cMain,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Text('Mô tả nhóm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Mục tiêu giao lưu, đối tượng thành viên...',
                          prefixIcon: const Icon(Icons.notes_rounded, color: AppColor.cMuted, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),

                      const SizedBox(height: 20),
                      // Section 2: San & Trinh do
                      _buildSectionHeader('2. Sân đấu & Trình độ mục tiêu', Icons.stadium_outlined),
                      const SizedBox(height: 10),

                      const Text('Sân cố định & Địa chỉ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _venueController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Tên sân (Ví dụ: Sân Cầu Lông Kỳ Hòa)',
                          prefixIcon: const Icon(Icons.place_outlined, color: AppColor.cMuted, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Địa chỉ cụ thể (Ví dụ: 238 Đường 3/2, Quận 10)',
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColor.cMuted, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Text('Khoảng trình độ tuyển chọn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<SkillLevel>(
                              initialValue: _minLevel,
                              decoration: InputDecoration(
                                labelText: 'Từ',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: SkillLevel.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName, style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _minLevel = val;
                                    if (_minLevel.level > _maxLevel.level) {
                                      _maxLevel = _minLevel;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<SkillLevel>(
                              initialValue: _maxLevel,
                              decoration: InputDecoration(
                                labelText: 'Đến',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: SkillLevel.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName, style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _maxLevel = val;
                                    if (_maxLevel.level < _minLevel.level) {
                                      _minLevel = _maxLevel;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Section 3: Lich sinh hoat dinh ky
                      _buildSectionHeader('3. Lịch sinh hoạt định kỳ', Icons.event_repeat_rounded),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Checkbox(
                            value: _hasSchedule,
                            activeColor: AppColor.cMain,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                _hasSchedule = val ?? false;
                                if (_hasSchedule && _schedules.isEmpty) {
                                  _addScheduleEntry();
                                }
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Thiết lập các buổi tập cố định trong tuần',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                            ),
                          ),
                        ],
                      ),

                      if (_hasSchedule) ...[
                        const SizedBox(height: 6),
                        ..._schedules.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final schedule = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
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
                                    Text(
                                      'Buổi ${idx + 1}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.cMain),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColor.cRed, size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => _removeScheduleEntry(idx),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Day of week
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButtonFormField<int>(
                                        initialValue: schedule.dayOfWeek,
                                        decoration: InputDecoration(
                                          labelText: 'Thứ',
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        items: _dayOptions.map((opt) {
                                          return DropdownMenuItem(
                                            value: opt.key,
                                            child: Text(opt.value, style: const TextStyle(fontSize: 12)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => schedule.dayOfWeek = val);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Start Time
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () => _pickTime(idx, true),
                                        borderRadius: BorderRadius.circular(8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Bắt đầu',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatTime(schedule.startTime),
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                              const Icon(Icons.access_time_rounded, size: 14, color: AppColor.cMuted),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // End Time
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () => _pickTime(idx, false),
                                        borderRadius: BorderRadius.circular(8),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Kết thúc',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatTime(schedule.endTime),
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              ),
                                              const Icon(Icons.access_time_rounded, size: 14, color: AppColor.cMuted),
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
                        }),

                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Thêm khung giờ / ngày chơi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.cMain,
                            side: const BorderSide(color: AppColor.cMain),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _addScheduleEntry,
                        ),
                      ],

                      const SizedBox(height: 20),
                      // Section 4: Luu y tai chinh & Quyen Host
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined, size: 18, color: AppColor.cMain),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ghi chú quyền hạn:\n'
                                '• Người tạo nhóm tự động giữ vai trò Chủ nhóm (Host) với 100% quyền hạn.\n'
                                '• Hệ thống tự sinh 4 vai trò chuẩn: Phó nhóm, Thủ quỹ, Thành viên và Khách vãng lai.\n'
                                '• Bạn có thể thiết lập số tài khoản ngân hàng nhận quỹ (VietQR) và biểu phí đa hệ số trong phần Cài đặt CLB sau khi tạo.',
                                style: TextStyle(fontSize: 11, color: AppColor.cMuted, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Hủy', style: TextStyle(color: AppColor.cMuted)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Hoàn tất tạo CLB', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.cMain),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColor.cTitle,
          ),
        ),
      ],
    );
  }
}
