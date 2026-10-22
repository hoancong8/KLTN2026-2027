// lib/ui/screen/club/settings/club_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../domain/entities/club/club_detail.dart';
import '../../../../domain/enums/session_enums.dart';
import '../club_vm/club_context_vm.dart';
import '../role_management/club_role_management_screen.dart';
import '../../club_detail/club_detail_vm/club_detail_vm.dart';
import '../../home/tab/club/widgets/club_schedule_planner.dart';

class ClubSettingsScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubSettingsScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubSettingsScreen> createState() => _ClubSettingsScreenState();
}

class _ClubSettingsScreenState extends ConsumerState<ClubSettingsScreen> {
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

  SkillLevel? _minLevel;
  SkillLevel? _maxLevel;
  bool _isRecruiting = true;

  final List<ClubScheduleEntry> _schedules = [];
  bool _initialized = false;
  bool _isSaving = false;

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

  void _populateData(ClubDetail club) {
    if (_initialized) return;
    _initialized = true;

    _nameController.text = club.groupName;
    _avatarUrlController.text = club.avatarUrl ?? '';
    _descController.text = club.description ?? '';
    _venueController.text = club.fixedVenueName ?? '';
    _addressController.text = club.fixedAddress ?? '';
    _lat = club.lat;
    _lng = club.lng;
    _minLevel = club.minSkillLevel ?? SkillLevel.nb;
    _maxLevel = club.maxSkillLevel ?? SkillLevel.k;
    _isRecruiting = club.isRecruiting;

    _schedules.clear();
    for (final s in club.schedules) {
      _schedules.add(
        ClubScheduleEntry(
          dayOfWeek: s.dayOfWeek,
          startTime: _parseTime(s.startTime),
          endTime: _parseTime(s.endTime),
        ),
      );
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 18, minute: 0);
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
          content: Text(
            'Đã cập nhật tọa độ GPS: (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)})',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy tọa độ GPS. Vui lòng kiểm tra quyền vị trí.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _saveAllChanges(ClubDetailViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      // 1. Cập nhật thông tin nhóm
      await vm.updateInfo(
        groupName: _nameController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        avatarUrl: _avatarUrlController.text.trim().isNotEmpty ? _avatarUrlController.text.trim() : null,
        fixedVenueName: _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : null,
        fixedAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        lat: _lat,
        lng: _lng,
        minSkillLevel: _minLevel,
        maxSkillLevel: _maxLevel,
        isRecruiting: _isRecruiting,
      );

      // 2. Cập nhật lịch sinh hoạt tuần
      final scheduleInputs = _schedules
          .map(
            (e) => ClubScheduleInput(
              dayOfWeek: e.dayOfWeek,
              startTime: _formatTime(e.startTime),
              endTime: _formatTime(e.endTime),
            ),
          )
          .toList();
      await vm.updateSchedules(scheduleInputs);

      // 3. Tải lại MyClubs để đồng bộ avatar và tên
      await ref.read(clubContextViewModelProvider.notifier).loadMyClubs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật cài đặt câu lạc bộ thành công!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showLockClubDialog(ClubDetailViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            AppSpacing.gapW8,
            Text('Tạm Dừng / Khóa Nhóm', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
          ],
        ),
        content: Text(
          'Khi tạm dừng hoạt động, câu lạc bộ sẽ ẩn khỏi radar tìm kiếm và thành viên không thể biểu quyết buổi chơi mới. Bạn có thể mở lại bất cứ lúc nào.',
          style: AppTypography.bodyMedium.colored(colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isRecruiting = false);
              await _saveAllChanges(vm);
            },
            child: const Text('Xác nhận khóa'),
          ),
        ],
      ),
    );
  }

  void _showLeaveClubDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            const Icon(Icons.exit_to_app_rounded, color: AppColors.error, size: 24),
            AppSpacing.gapW8,
            Text('Rời Câu Lạc Bộ', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn rời khỏi câu lạc bộ này? Mọi quyền hạn và lịch sử điểm danh của bạn tại nhóm sẽ bị hủy bỏ.',
          style: AppTypography.bodyMedium.colored(colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(clubContextViewModelProvider.notifier)
                  .leaveClub(widget.clubId);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn đã rời khỏi câu lạc bộ.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  context.go('/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chủ nhóm (Host) không thể tự rời khi chưa chuyển giao quyền.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Xác nhận rời'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubDetailViewModelProvider(widget.clubId));
    final vm = ref.read(clubDetailViewModelProvider(widget.clubId).notifier);

    final club = state.club;
    if (club != null) {
      _populateData(club);
    }

    final isHost = club?.currentUserStatus.isHost ?? false;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Cài Đặt Câu Lạc Bộ',
          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        actions: [
          if (club != null)
            TextButton.icon(
              icon: _isSaving
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_rounded, size: 18),
              label: const Text('Lưu'),
              onPressed: _isSaving ? null : () => _saveAllChanges(vm),
            ),
        ],
      ),
      body: state.isLoading && club == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Thông tin chung
                    _buildSectionCard(
                      title: 'Thông Tin Chung',
                      icon: Icons.info_outline_rounded,
                      children: [
                        Text('Tên Câu Lạc Bộ *', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        TextFormField(
                          controller: _nameController,
                          enabled: isHost,
                          decoration: InputDecoration(
                            hintText: 'Nhập tên câu lạc bộ',
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Tên câu lạc bộ không được để trống';
                            return null;
                          },
                        ),
                        AppSpacing.gapH16,
                        Text('Đường dẫn ảnh đại diện (Avatar URL)', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        TextFormField(
                          controller: _avatarUrlController,
                          decoration: InputDecoration(
                            hintText: 'https://...',
                            filled: true,
                            fillColor: colors.inputFill,
                            prefixIcon: Icon(Icons.link_rounded, color: colors.textMuted),
                            border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                          ),
                        ),
                        AppSpacing.gapH16,
                        Text('Mô tả câu lạc bộ', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Giới thiệu về hoạt động của câu lạc bộ',
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                          ),
                        ),
                        AppSpacing.gapH16,
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.primary,
                          title: Text('Mở tuyển thành viên mới', style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                          subtitle: Text('Cho phép người chơi khác tìm thấy và nộp đơn gia nhập', style: AppTypography.bodySmall.colored(colors.textMuted)),
                          value: _isRecruiting,
                          onChanged: (val) => setState(() => _isRecruiting = val),
                        ),
                      ],
                    ),
                    AppSpacing.gapH16,

                    // Section 2: Sân bãi & GPS
                    _buildSectionCard(
                      title: 'Sân Sinh Hoạt & Vị Trí',
                      icon: Icons.place_outlined,
                      children: [
                        Text('Tên Sân Cố Định', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        TextFormField(
                          controller: _venueController,
                          decoration: InputDecoration(
                            hintText: 'Ví dụ: Sân Cầu Lông Kỳ Hòa Q10',
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                          ),
                        ),
                        AppSpacing.gapH16,
                        Text('Địa Chỉ Cụ Thể', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH8,
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: 'Ví dụ: 238 Ba Tháng Hai, P.12, Q.10',
                            filled: true,
                            fillColor: colors.inputFill,
                            border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                          ),
                        ),
                        AppSpacing.gapH16,
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tọa độ GPS', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                                  AppSpacing.gapH4,
                                  Text(
                                    _lat != null
                                        ? '(${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)})'
                                        : 'Chưa có tọa độ',
                                    style: AppTypography.bodySmall.colored(colors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.primary,
                                side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                              ),
                              icon: _isGettingLocation
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.my_location_rounded, size: 16),
                              label: const Text('Cập nhật GPS'),
                              onPressed: _isGettingLocation ? null : _getCurrentLocation,
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.gapH16,

                    // Section 3: Lịch sinh hoạt định kỳ
                    _buildSectionCard(
                      title: 'Lịch Sinh Hoạt Cố Định Hàng Tuần',
                      icon: Icons.calendar_month_outlined,
                      children: [
                        ClubSchedulePlanner(
                          initialSchedules: _schedules,
                          onChanged: (list) {
                            _schedules.clear();
                            _schedules.addAll(list);
                          },
                        ),
                      ],
                    ),
                    AppSpacing.gapH16,

                    // Section 4: Quản lý vai trò (Nếu là Host)
                    if (isHost) ...[
                      _buildSectionCard(
                        title: 'Phân Quyền Vai Trò (Discord-Style)',
                        icon: Icons.shield_outlined,
                        children: [
                          Text(
                            'Tùy chỉnh các vai trò (Host, Thủ quỹ, Phó nhóm) và phân công quyền hạn trong nhóm.',
                            style: AppTypography.bodySmall.colored(colors.textMuted),
                          ),
                          AppSpacing.gapH12,
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.roleHost,
                                side: BorderSide(color: AppColors.roleHost.withValues(alpha: 0.5)),
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              ),
                              icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                              label: const Text('Quản lý cây vai trò & quyền hạn'),
                              onPressed: () {
                                ClubRoleManagementScreen.show(context, clubId: widget.clubId);
                              },
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH16,
                    ],

                    // Section 5: Vùng nhạy cảm (Danger Zone)
                    _buildSectionCard(
                      title: 'Vùng Nguy Hiểm',
                      icon: Icons.warning_rounded,
                      isDanger: true,
                      children: [
                        if (isHost) ...[
                          Text(
                            'Tạm dừng hoạt động hoặc khóa câu lạc bộ',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                          ),
                          AppSpacing.gapH4,
                          Text(
                            'Ẩn nhóm khỏi radar tìm kiếm và tạm ngừng các hoạt động sinh hoạt mới.',
                            style: AppTypography.bodySmall.colored(colors.textMuted),
                          ),
                          AppSpacing.gapH12,
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.warning,
                              side: const BorderSide(color: AppColors.warning),
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            ),
                            icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                            label: const Text('Tạm dừng hoạt động CLB'),
                            onPressed: () => _showLockClubDialog(vm),
                          ),
                          AppSpacing.gapH16,
                        ],
                        Text(
                          'Rời khỏi câu lạc bộ',
                          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          'Hủy tư cách thành viên của bạn tại câu lạc bộ này.',
                          style: AppTypography.bodySmall.colored(colors.textMuted),
                        ),
                        AppSpacing.gapH12,
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          ),
                          icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                          label: const Text('Rời câu lạc bộ'),
                          onPressed: _showLeaveClubDialog,
                        ),
                      ],
                    ),
                    AppSpacing.gapH32,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isDanger = false,
  }) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDanger ? AppColors.error.withValues(alpha: 0.3) : colors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDanger ? AppColors.error : colors.primary,
                size: 20,
              ),
              AppSpacing.gapW8,
              Text(
                title,
                style: AppTypography.titleMedium.bold.colored(
                  isDanger ? AppColors.error : colors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(color: colors.cardBorder, height: 24),
          ...children,
        ],
      ),
    );
  }
}
