// lib/ui/screen/home/tab/club/widgets/club_create_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../../domain/enums/session_enums.dart';
import '../../../../club/club_vm/club_context_vm.dart';
import 'club_schedule_planner.dart';

class ClubCreateDialog extends ConsumerStatefulWidget {
  const ClubCreateDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ClubCreateDialog(),
    );
  }

  @override
  ConsumerState<ClubCreateDialog> createState() => _ClubCreateDialogState();
}

class _ClubCreateDialogState extends ConsumerState<ClubCreateDialog> {
  AppThemeColors get colors => context.colors;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _descController;
  late final TextEditingController _venueController;
  late final TextEditingController _addressController;

  double? _lat;
  double? _lng;
  bool _isGettingLocation = false;

  SkillLevel _minLevel = SkillLevel.nb;
  SkillLevel _maxLevel = SkillLevel.k;

  bool _hasSchedule = false;
  final List<ClubScheduleEntry> _schedules = [];

  bool _isSubmitting = false;
  String? _errorMessage;

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
        return 'Thứ $dayOfWeek';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final locationService = ref.read(locationServiceProvider);
      final loc = await locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _lat = loc.latitude;
        _lng = loc.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật tọa độ GPS: (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)})'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy tọa độ GPS. Vui lòng kiểm tra quyền truy cập vị trí.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasSchedule) {
      if (_schedules.isEmpty) {
        setState(() {
          _errorMessage = 'Vui lòng chọn ít nhất một thứ sinh hoạt trong tuần hoặc tắt thiết lập lịch định kỳ.';
        });
        return;
      }

      for (int i = 0; i < _schedules.length; i++) {
        final entry = _schedules[i];
        final startMin = entry.startTime.hour * 60 + entry.startTime.minute;
        final endMin = entry.endTime.hour * 60 + entry.endTime.minute;
        if (startMin >= endMin) {
          setState(() {
            _errorMessage = 'Buổi ${_getDayName(entry.dayOfWeek)}: Giờ bắt đầu (${_formatTime(entry.startTime)}) phải trước giờ kết thúc (${_formatTime(entry.endTime)}).';
          });
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    final vm = ref.read(clubContextViewModelProvider.notifier);

    final Map<int, Map<String, dynamic>> distinctSchedules = {};
    if (_hasSchedule && _schedules.isNotEmpty) {
      for (final s in _schedules) {
        distinctSchedules[s.dayOfWeek] = {
          'dayOfWeek': s.dayOfWeek,
          'startTime': _formatTime(s.startTime),
          'endTime': _formatTime(s.endTime),
        };
      }
    }
    final schedulesList = distinctSchedules.isNotEmpty
        ? distinctSchedules.values.toList()
        : null;

    final newClubId = await vm.createClub(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      avatarUrl: _avatarUrlController.text.trim().isNotEmpty ? _avatarUrlController.text.trim() : null,
      fixedVenueName: _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : null,
      fixedAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      lat: _lat,
      lng: _lng,
      minSkillLevel: _minLevel.code,
      maxSkillLevel: _maxLevel.code,
      schedules: schedulesList,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (newClubId != null && newClubId.isNotEmpty) {
      Navigator.of(context).pop(newClubId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chúc mừng! Bạn đã tạo CLB thành công và trở thành Chủ nhóm (Host).'),
          backgroundColor: AppColors.success,
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final dialogWidth = screenWidth > 580 ? 540.0 : screenWidth * 0.94;
    final screenHeight = mediaQuery.size.height;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      backgroundColor: colors.cardBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: (screenHeight * 0.88).clamp(380.0, 780.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 18, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Icon(Icons.add_business_rounded, color: colors.primary, size: 22),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo Câu Lạc Bộ Mới',
                          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          'Khởi tạo nhóm cầu lông và trở thành Host',
                          style: AppTypography.bodySmall.colored(colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textMuted),
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.divider),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: AppSpacing.allMd,
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: colors.error, size: 20),
                              AppSpacing.gapW12,
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTypography.bodySmall.colored(AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapH16,
                      ],

                      // Section 1: Thong tin co ban
                      _buildSectionHeader('1. Thông tin cơ bản', Icons.info_outline_rounded),
                      AppSpacing.gapH12,

                      Text('Tên câu lạc bộ *', style: AppTypography.labelMedium.semiBold.colored(colors.textPrimary)),
                      AppSpacing.gapH8,
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Ví dụ: CLB Cầu Lông Chiến Binh',
                          hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                          prefixIcon: Icon(Icons.groups_rounded, color: colors.textMuted, size: 20),
                          border: const OutlineInputBorder(borderRadius: AppRadius.input),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập tên câu lạc bộ';
                          }
                          if (v.trim().length < 3) {
                            return 'Tên câu lạc bộ phải có ít nhất 3 ký tự';
                          }
                          if (v.trim().length > 255) {
                            return 'Tên câu lạc bộ tối đa 255 ký tự';
                          }
                          return null;
                        },
                      ),

                      AppSpacing.gapH16,
                      Text('Ảnh đại diện (Avatar URL)', style: AppTypography.labelMedium.semiBold.colored(colors.textPrimary)),
                      AppSpacing.gapH8,
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
                                hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                                prefixIcon: Icon(Icons.image_outlined, color: colors.textMuted, size: 20),
                                border: const OutlineInputBorder(borderRadius: AppRadius.input),
                                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                              ),
                            ),
                          ),
                          AppSpacing.gapW12,
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.surfaceSubtle,
                              borderRadius: AppRadius.borderSm,
                              border: Border.all(color: colors.cardBorder),
                              image: _avatarUrlController.text.trim().isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_avatarUrlController.text.trim()),
                                      fit: BoxFit.cover,
                                      onError: (_, _) {},
                                    )
                                  : null,
                            ),
                            child: _avatarUrlController.text.trim().isEmpty
                                ? Icon(Icons.sports_tennis_rounded, color: colors.textMuted, size: 24)
                                : null,
                          ),
                        ],
                      ),
                      AppSpacing.gapH8,
                      // Quick Avatar Presets
                      Wrap(
                        spacing: 8,
                        children: [
                          Text('Gợi ý ảnh:', style: AppTypography.labelSmall.colored(colors.textMuted)),
                          ..._avatarPresets.asMap().entries.map((e) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _avatarUrlController.text = e.value;
                                });
                              },
                              borderRadius: AppRadius.borderXs,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Text(
                                  'Mẫu ${e.key + 1}',
                                  style: AppTypography.labelSmall.underlined.colored(AppColors.primary),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),

                      AppSpacing.gapH16,
                      Text('Mô tả nhóm', style: AppTypography.labelMedium.semiBold.colored(colors.textPrimary)),
                      AppSpacing.gapH8,
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        maxLength: 500,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Mục tiêu giao lưu, đối tượng thành viên...',
                          hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                          prefixIcon: Icon(Icons.notes_rounded, color: colors.textMuted, size: 20),
                          border: const OutlineInputBorder(borderRadius: AppRadius.input),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          counterText: '',
                        ),
                      ),

                      AppSpacing.gapH20,
                      // Section 2: San & Trinh do
                      _buildSectionHeader('2. Sân đấu & Trình độ mục tiêu', Icons.stadium_outlined),
                      AppSpacing.gapH12,

                      Text('Sân cố định & Địa chỉ', style: AppTypography.labelMedium.semiBold.colored(colors.textPrimary)),
                      AppSpacing.gapH8,
                      TextFormField(
                        controller: _venueController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Tên sân (Ví dụ: Sân Cầu Lông Kỳ Hòa)',
                          hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                          prefixIcon: Icon(Icons.place_outlined, color: colors.textMuted, size: 20),
                          border: const OutlineInputBorder(borderRadius: AppRadius.input),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        ),
                      ),
                      AppSpacing.gapH8,
                      TextFormField(
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Địa chỉ cụ thể (Ví dụ: 238 Đường 3/2, Quận 10)',
                          hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                          prefixIcon: Icon(Icons.location_on_outlined, color: colors.textMuted, size: 20),
                          border: const OutlineInputBorder(borderRadius: AppRadius.input),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        ),
                      ),
                      AppSpacing.gapH8,

                      // GPS Coordinates Control
                      Row(
                        children: [
                          if (_lat != null && _lng != null) ...[
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSubtle,
                                  borderRadius: AppRadius.borderSm,
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.my_location_rounded, size: 16, color: AppColors.primary),
                                    AppSpacing.gapW4,
                                    Expanded(
                                      child: Text(
                                        'GPS: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                                        style: AppTypography.labelSmall.semiBold.colored(colors.textPrimary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => setState(() {
                                        _lat = null;
                                        _lng = null;
                                      }),
                                      child: Icon(Icons.close_rounded, size: 16, color: colors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppSpacing.gapW8,
                          ],
                          Flexible(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                              ),
                              onPressed: _isGettingLocation ? null : _getCurrentLocation,
                              icon: _isGettingLocation
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    )
                                  : const Icon(Icons.my_location_rounded, size: 16, color: AppColors.primary),
                              label: Text(
                                _lat != null ? 'Cập nhật GPS' : 'Lấy vị trí GPS',
                                style: AppTypography.labelSmall.semiBold.colored(AppColors.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.gapH16,
                      Text('Khoảng trình độ tuyển chọn', style: AppTypography.labelMedium.semiBold.colored(colors.textPrimary)),
                      AppSpacing.gapH8,
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<SkillLevel>(
                              isExpanded: true,
                              initialValue: _minLevel,
                              decoration: const InputDecoration(
                                labelText: 'Từ',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: AppRadius.input),
                              ),
                              items: SkillLevel.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName, style: AppTypography.bodySmall),
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
                          AppSpacing.gapW8,
                          Expanded(
                            child: DropdownButtonFormField<SkillLevel>(
                              isExpanded: true,
                              initialValue: _maxLevel,
                              decoration: const InputDecoration(
                                labelText: 'Đến',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: AppRadius.input),
                              ),
                              items: SkillLevel.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName, style: AppTypography.bodySmall),
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

                      AppSpacing.gapH20,
                      // Section 3: Lich sinh hoat dinh ky hang tuan
                      _buildSectionHeader('3. Lịch sinh hoạt định kỳ hàng tuần', Icons.event_repeat_rounded),
                      AppSpacing.gapH8,

                      Container(
                        decoration: BoxDecoration(
                          color: _hasSchedule
                              ? colors.primaryContainer
                              : colors.surfaceSubtle,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(
                            color: _hasSchedule
                                ? colors.primary.withValues(alpha: 0.3)
                                : colors.cardBorder,
                          ),
                        ),
                        child: Material(
                          color: AppColors.transparent,
                          child: SwitchListTile(
                            value: _hasSchedule,
                            activeThumbColor: AppColors.primary,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
                            title: Text(
                              'Thiết lập lịch sinh hoạt định kỳ',
                              style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                            ),
                            subtitle: Text(
                              'Thiết lập các thứ sinh hoạt cố định trong tuần (Thứ 2 - Chủ Nhật) và khung giờ',
                              style: AppTypography.labelSmall.colored(colors.textMuted),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _hasSchedule = val;
                              });
                            },
                          ),
                        ),
                      ),

                      if (_hasSchedule) ...[
                        AppSpacing.gapH12,
                        ClubSchedulePlanner(
                          initialSchedules: _schedules,
                          onChanged: (updated) {
                            setState(() {
                              _schedules.clear();
                              _schedules.addAll(updated);
                            });
                          },
                        ),
                      ],

                      AppSpacing.gapH20,
                      // Section 4: Luu y tai chinh & Quyen Host
                      Container(
                        padding: AppSpacing.allMd,
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
                            AppSpacing.gapW12,
                            Expanded(
                              child: Text(
                                'Ghi chú quyền hạn:\n'
                                '• Người tạo nhóm tự động giữ vai trò Chủ nhóm (Host) với 100% quyền hạn.\n'
                                '• Hệ thống tự sinh 4 vai trò chuẩn: Phó nhóm, Thủ quỹ, Thành viên và Khách vãng lai.\n'
                                '• Bạn có thể thiết lập số tài khoản ngân hàng nhận quỹ (VietQR) và biểu phí đa hệ số trong phần Cài đặt CLB sau khi tạo.',
                                style: AppTypography.bodySmall.colored(colors.textMuted),
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
            Divider(height: 1, color: colors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: AppSpacing.verticalMd,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        side: BorderSide(color: colors.cardBorder),
                      ),
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: AppSpacing.verticalMd,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                            )
                          : const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        'Xác nhận tạo CLB',
                        style: AppTypography.labelLarge.bold.colored(AppColors.onPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        AppSpacing.gapW8,
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
