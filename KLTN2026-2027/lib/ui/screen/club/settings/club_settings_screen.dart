// lib/ui/screen/club/settings/club_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../domain/entities/club/club_detail.dart';
import '../../../../domain/enums/club_role.dart';
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

  String _feeMode = 'DYNAMIC';
  int _roundRule = 1000;
  late final TextEditingController _monthlyFeeController;
  late final TextEditingController _femaleDiscountMonthlyController;
  late final TextEditingController _dailyMemberFeeController;
  late final TextEditingController _femaleDiscountController;
  late final TextEditingController _guestFeeController;

  String _bankName = 'Vietcombank';
  late final TextEditingController _bankAccountController;
  late final TextEditingController _bankHolderController;

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

    _monthlyFeeController = TextEditingController(text: '500.000');
    _femaleDiscountMonthlyController = TextEditingController(text: '50.000');
    _dailyMemberFeeController = TextEditingController(text: '50.000');
    _femaleDiscountController = TextEditingController(text: '10.000');
    _guestFeeController = TextEditingController(text: '70.000');

    for (final c in [
      _monthlyFeeController,
      _femaleDiscountMonthlyController,
      _dailyMemberFeeController,
      _femaleDiscountController,
      _guestFeeController,
    ]) {
      c.addListener(() {
        if (mounted) setState(() {});
      });
    }

    _bankAccountController = TextEditingController(text: '1029384756');
    _bankHolderController = TextEditingController(text: 'CLB CAU LONG CHIEN BINH');

    _avatarUrlController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _monthlyFeeController.dispose();
    _femaleDiscountMonthlyController.dispose();
    _dailyMemberFeeController.dispose();
    _femaleDiscountController.dispose();
    _guestFeeController.dispose();
    _bankAccountController.dispose();
    _bankHolderController.dispose();
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
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể lấy tọa độ GPS. Vui lòng kiểm tra quyền vị trí.'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _saveAllChanges(
    ClubDetailViewModel vm, {
    required bool canManageInfo,
    required bool canManageSchedule,
  }) async {
    if (!_formKey.currentState!.validate()) return;
    if (!canManageInfo && !canManageSchedule) return;

    setState(() => _isSaving = true);
    try {
      if (canManageInfo) {
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
      }

      if (canManageSchedule) {
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
      }

      await ref.read(clubContextViewModelProvider.notifier).loadMyClubs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật cài đặt câu lạc bộ thành công!'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: colors.error,
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
            Icon(Icons.warning_amber_rounded, color: colors.warning, size: 24),
            AppSpacing.gapW8,
            Text('Tạm Dừng / Khóa Nhóm', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
          ],
        ),
        content: Text(
          'Khi tạm dừng hoạt động, câu lạc bộ sẽ ẩn khỏi radar tìm kiếm và thành viên không thể đăng ký buổi chơi mới. Bạn có thể mở lại bất cứ lúc nào.',
          style: AppTypography.bodyMedium.colored(colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.warning,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isRecruiting = false);
              await _saveAllChanges(vm, canManageInfo: true, canManageSchedule: false);
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
            Icon(Icons.exit_to_app_rounded, color: colors.error, size: 24),
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
              backgroundColor: colors.error,
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
                    SnackBar(
                      content: const Text('Bạn đã rời khỏi câu lạc bộ.'),
                      backgroundColor: colors.primary,
                    ),
                  );
                  context.go('/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Chủ nhóm (Host) không thể tự rời khi chưa chuyển giao quyền.'),
                      backgroundColor: colors.error,
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

  Widget _buildAvatarPreview() {
    final avatarUrl = _avatarUrlController.text.trim();
    return Center(
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.1),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35), width: 2),
            ),
            child: ClipOval(
              child: avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.sports_tennis_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    )
                  : Icon(
                      Icons.groups_rounded,
                      size: 42,
                      color: colors.primary,
                    ),
            ),
          ),
          AppSpacing.gapH8,
          Text(
            avatarUrl.isNotEmpty ? 'Ảnh đại diện câu lạc bộ' : 'Chưa có ảnh đại diện',
            style: AppTypography.labelSmall.colored(colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillLevelSelector(bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yêu Cầu Trình Độ Thành Viên',
          style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
        ),
        AppSpacing.gapH4,
        Text(
          'Khoảng trình độ phù hợp để thành viên mới tìm kiếm và nộp đơn',
          style: AppTypography.bodySmall.colored(colors.textMuted),
        ),
        AppSpacing.gapH8,
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SkillLevel>(
                initialValue: _minLevel,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Tối thiểu',
                  labelStyle: AppTypography.labelSmall.colored(colors.textMuted),
                  filled: true,
                  fillColor: colors.inputFill,
                  prefixIcon: Icon(Icons.trending_up_rounded, size: 18, color: colors.primary),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: colors.inputBorder),
                  ),
                ),
                items: SkillLevel.values.map((lvl) {
                  return DropdownMenuItem(
                    value: lvl,
                    child: Text(
                      '${lvl.code} - ${lvl.displayName}',
                      style: AppTypography.bodySmall.colored(colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: enabled ? (val) => setState(() => _minLevel = val) : null,
              ),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: DropdownButtonFormField<SkillLevel>(
                initialValue: _maxLevel,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Tối đa',
                  labelStyle: AppTypography.labelSmall.colored(colors.textMuted),
                  filled: true,
                  fillColor: colors.inputFill,
                  prefixIcon: Icon(Icons.military_tech_outlined, size: 18, color: colors.primary),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: colors.inputBorder),
                  ),
                ),
                items: SkillLevel.values.map((lvl) {
                  return DropdownMenuItem(
                    value: lvl,
                    child: Text(
                      '${lvl.code} - ${lvl.displayName}',
                      style: AppTypography.bodySmall.colored(colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: enabled ? (val) => setState(() => _maxLevel = val) : null,
              ),
            ),
          ],
        ),
      ],
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

    final currentProfile = ref.watch(currentUserProfileProvider);
    final activeContext = ref.watch(activeClubContextProvider);
    final isSameClub = activeContext?.clubId == widget.clubId;
    final isHostOwner = club != null && currentProfile != null && club.host.userId == currentProfile.id;
    final isHost = isHostOwner || (club?.currentUserStatus.isHost ?? false) || (isSameClub && activeContext?.role == ClubRole.host);
    final canManageInfo = isHost || (isSameClub && ref.hasClubPermission('MEMBER.INFO.UPDATE'));
    final canManageSchedule = isHost || (isSameClub && ref.hasClubPermission('OPERATIONS.SCHEDULE.MANAGE'));
    final canManageRoles = isHost || (isSameClub && ref.hasClubPermission('MEMBER.ROLE.MANAGE'));
    final canSave = canManageInfo || canManageSchedule;

    if (club != null && !isHost && !canManageInfo && !canManageSchedule && !canManageRoles) {
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
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 54, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Không Có Quyền Chỉnh Sửa',
                  style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đang tham gia với tư cách Thành viên. Chỉ Chủ nhóm (Host) hoặc người có quyền quản trị mới có thể chỉnh sửa thông tin câu lạc bộ.',
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          if (club != null && canSave)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Lưu thay đổi',
                icon: _isSaving
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
                    : Icon(Icons.done_all_rounded, color: colors.primary),
                onPressed: _isSaving
                    ? null
                    : () => _saveAllChanges(vm, canManageInfo: canManageInfo, canManageSchedule: canManageSchedule),
              ),
            ),
        ],
      ),
      bottomNavigationBar: (club != null && canSave)
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.cardBorder)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardBorder.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 768),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                          elevation: 0,
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : const Icon(Icons.check_rounded, size: 20),
                        label: Text(
                          _isSaving ? 'Đang lưu thay đổi...' : 'Lưu Thay Đổi Cài Đặt',
                          style: AppTypography.bodyMedium.bold.colored(AppColors.white),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () => _saveAllChanges(vm, canManageInfo: canManageInfo, canManageSchedule: canManageSchedule),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: state.isLoading && club == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 768),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Thông tin chung
                        _buildSectionCard(
                          title: 'Thông Tin Chung',
                          icon: Icons.info_outline_rounded,
                          children: [
                            _buildAvatarPreview(),
                            AppSpacing.gapH16,
                            Text('Tên Câu Lạc Bộ *', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                            AppSpacing.gapH8,
                            TextFormField(
                              controller: _nameController,
                              enabled: isHost,
                              decoration: InputDecoration(
                                hintText: 'Nhập tên câu lạc bộ',
                                filled: true,
                                fillColor: colors.inputFill,
                                prefixIcon: Icon(Icons.groups_rounded, color: colors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
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
                              enabled: canManageInfo,
                              decoration: InputDecoration(
                                hintText: 'https://...',
                                filled: true,
                                fillColor: colors.inputFill,
                                prefixIcon: Icon(Icons.link_rounded, color: colors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
                              ),
                            ),
                            AppSpacing.gapH16,
                            Text('Mô tả câu lạc bộ', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                            AppSpacing.gapH8,
                            TextFormField(
                              controller: _descController,
                              enabled: canManageInfo,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Giới thiệu về hoạt động và tiêu chí của câu lạc bộ',
                                filled: true,
                                fillColor: colors.inputFill,
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
                              ),
                            ),
                            AppSpacing.gapH16,
                            _buildSkillLevelSelector(canManageInfo),
                            AppSpacing.gapH16,
                            Material(
                              color: colors.surfaceSubtle,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.borderMd,
                                side: BorderSide(color: colors.cardBorder),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  activeThumbColor: colors.primary,
                                  title: Text(
                                    'Mở tuyển thành viên mới',
                                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                                  ),
                                  subtitle: Text(
                                    'Cho phép người chơi khác tìm thấy và nộp đơn gia nhập CLB',
                                    style: AppTypography.bodySmall.colored(colors.textMuted),
                                  ),
                                  value: _isRecruiting,
                                  onChanged: canManageInfo ? (val) => setState(() => _isRecruiting = val) : null,
                                ),
                              ),
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
                              enabled: canManageInfo,
                              decoration: InputDecoration(
                                hintText: 'Ví dụ: Sân Cầu Lông Kỳ Hòa Q10',
                                filled: true,
                                fillColor: colors.inputFill,
                                prefixIcon: Icon(Icons.sports_tennis_rounded, color: colors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
                              ),
                            ),
                            AppSpacing.gapH16,
                            Text('Địa Chỉ Cụ Thể', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                            AppSpacing.gapH8,
                            TextFormField(
                              controller: _addressController,
                              enabled: canManageInfo,
                              decoration: InputDecoration(
                                hintText: 'Ví dụ: 238 Ba Tháng Hai, P.12, Q.10',
                                filled: true,
                                fillColor: colors.inputFill,
                                prefixIcon: Icon(Icons.location_on_outlined, color: colors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderMd,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
                              ),
                            ),
                            AppSpacing.gapH16,
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (_lat != null ? colors.success : colors.textMuted).withValues(alpha: 0.15),
                                      borderRadius: AppRadius.borderSm,
                                    ),
                                    child: Icon(
                                      _lat != null ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                                      color: _lat != null ? colors.success : colors.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                  AppSpacing.gapW12,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Tọa độ vị trí GPS', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                                        AppSpacing.gapH4,
                                        Text(
                                          _lat != null
                                              ? '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                                              : 'Chưa có tọa độ',
                                          style: AppTypography.bodySmall.semiBold.colored(
                                            _lat != null ? colors.primary : colors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colors.primary,
                                      minimumSize: const Size(0, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                      side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                    ),
                                    icon: _isGettingLocation
                                        ? SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                                          )
                                        : const Icon(Icons.my_location_rounded, size: 16),
                                    label: const Text('Cập nhật GPS'),
                                    onPressed: (_isGettingLocation || !canManageInfo) ? null : _getCurrentLocation,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapH16,

                        // Section 3: Lịch sinh hoạt định kỳ
                        _buildSectionCard(
                          title: 'Lịch Sinh Hoạt Cố Định Hàng Tuần',
                          icon: Icons.calendar_month_outlined,
                          children: [
                            IgnorePointer(
                              ignoring: !canManageSchedule,
                              child: Opacity(
                                opacity: canManageSchedule ? 1.0 : 0.75,
                                child: ClubSchedulePlanner(
                                  initialSchedules: _schedules,
                                  onChanged: (list) {
                                    _schedules.clear();
                                    _schedules.addAll(list);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapH16,

                        // Section: Cấu hình biểu phí đa hệ số
                        _buildSectionCard(
                          title: 'Biểu Phí & Quy Tắc Phân Bổ Chi Phí',
                          icon: Icons.account_balance_wallet_outlined,
                          children: [
                            Text(
                              '1. Cách tính tiền & Làm tròn tiền lẻ',
                              style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                            ),
                            AppSpacing.gapH8,
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(child: Text('Chia Thực Tế (DYNAMIC)')),
                                    selected: _feeMode == 'DYNAMIC',
                                    selectedColor: colors.primary,
                                    labelStyle: AppTypography.bodySmall.copyWith(
                                      color: _feeMode == 'DYNAMIC' ? AppColors.white : colors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    backgroundColor: colors.surfaceSubtle,
                                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                    onSelected: (_) => setState(() => _feeMode = 'DYNAMIC'),
                                  ),
                                ),
                                AppSpacing.gapW8,
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Center(child: Text('Định Mức Cố Định (FIXED)')),
                                    selected: _feeMode == 'FIXED',
                                    selectedColor: colors.primary,
                                    labelStyle: AppTypography.bodySmall.copyWith(
                                      color: _feeMode == 'FIXED' ? AppColors.white : colors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    backgroundColor: colors.surfaceSubtle,
                                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                    onSelected: (_) => setState(() => _feeMode = 'FIXED'),
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapH8,
                            Text(
                              _feeMode == 'DYNAMIC'
                                  ? 'Tổng tiền sân + (Số quả cầu bóc mới × Đơn giá) + Phụ phí chia cho người tham gia.'
                                  : 'Thu theo đơn giá buổi cố định đã thiết lập cho từng nhóm đối tượng.',
                              style: AppTypography.labelSmall.colored(colors.textMuted),
                            ),
                            AppSpacing.gapH12,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Làm tròn hóa đơn VietQR:',
                                  style: AppTypography.labelSmall.bold.colored(colors.textSecondary),
                                ),
                                AppSpacing.gapH8,
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [1000, 2000, 5000].map((rule) {
                                    final isSelected = _roundRule == rule;
                                    return ChoiceChip(
                                      label: Text('${rule ~/ 1000}.000đ'),
                                      selected: isSelected,
                                      selectedColor: colors.primary,
                                      visualDensity: VisualDensity.compact,
                                      labelStyle: AppTypography.labelSmall.copyWith(
                                        color: isSelected ? AppColors.white : colors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      backgroundColor: colors.surfaceSubtle,
                                      onSelected: (_) => setState(() => _roundRule = rule),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            AppSpacing.gapH16,
                            Divider(color: colors.cardBorder, height: 1),
                            AppSpacing.gapH16,

                            Text(
                              '2. Biểu phí theo 3 nhóm đối tượng & Ưu đãi giới tính',
                              style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                            ),
                            AppSpacing.gapH12,

                            // Nhóm 1: Hội viên cố định theo tháng (MONTHLY)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_month_rounded, size: 17, color: colors.success),
                                            AppSpacing.gapW8,
                                            Flexible(
                                              child: Text(
                                                'Hội viên Cố định (Gói Tháng)',
                                                style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpacing.gapW8,
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: colors.success.withValues(alpha: 0.14),
                                          borderRadius: AppRadius.tag,
                                        ),
                                        child: Text(
                                          '0đ / buổi chơi',
                                          style: AppTypography.labelSmall.bold.colored(colors.success),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    'Đóng quỹ đầu tháng, miễn phí tiền sân & cầu trong các buổi sinh hoạt định kỳ.',
                                    style: AppTypography.labelSmall.colored(colors.textMuted),
                                  ),
                                  AppSpacing.gapH12,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Quỹ tháng chuẩn (Nam)', style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                                            AppSpacing.gapH4,
                                            TextFormField(
                                              controller: _monthlyFeeController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: const [CurrencyThousandsFormatter()],
                                              style: AppTypography.bodyMedium.colored(colors.textPrimary),
                                              decoration: InputDecoration(
                                                suffixText: 'đ/tháng',
                                                filled: true,
                                                fillColor: colors.inputFill,
                                                border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpacing.gapW12,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Giảm trừ Nữ / tháng', style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                                            AppSpacing.gapH4,
                                            TextFormField(
                                              controller: _femaleDiscountMonthlyController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: const [CurrencyThousandsFormatter()],
                                              style: AppTypography.bodyMedium.colored(colors.textPrimary),
                                              decoration: InputDecoration(
                                                prefixText: '- ',
                                                suffixText: 'đ',
                                                filled: true,
                                                fillColor: colors.inputFill,
                                                border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.gapH12,

                            // Nhóm 2: Hội viên theo buổi (DAILY)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.sports_tennis_rounded, size: 17, color: colors.primary),
                                            AppSpacing.gapW8,
                                            Flexible(
                                              child: Text(
                                                'Hội viên Đóng theo buổi (DAILY)',
                                                style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpacing.gapW8,
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(alpha: 0.14),
                                          borderRadius: AppRadius.tag,
                                        ),
                                        child: Text(
                                          'Đi buổi nào tính buổi đó',
                                          style: AppTypography.labelSmall.bold.colored(colors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH12,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Phí buổi chuẩn (Nam)', style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                                            AppSpacing.gapH4,
                                            TextFormField(
                                              controller: _dailyMemberFeeController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: const [CurrencyThousandsFormatter()],
                                              style: AppTypography.bodyMedium.colored(colors.textPrimary),
                                              decoration: InputDecoration(
                                                suffixText: 'đ/buổi',
                                                filled: true,
                                                fillColor: colors.inputFill,
                                                border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpacing.gapW12,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Giảm trừ Nữ / buổi', style: AppTypography.labelSmall.bold.colored(colors.textSecondary)),
                                            AppSpacing.gapH4,
                                            TextFormField(
                                              controller: _femaleDiscountController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: const [CurrencyThousandsFormatter()],
                                              style: AppTypography.bodyMedium.colored(colors.textPrimary),
                                              decoration: InputDecoration(
                                                prefixText: '- ',
                                                suffixText: 'đ',
                                                filled: true,
                                                fillColor: colors.inputFill,
                                                border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.gapH12,

                            // Nhóm 3: Khách vãng lai (GUEST)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_pin_circle_outlined, size: 18, color: colors.warning),
                                            AppSpacing.gapW8,
                                            Flexible(
                                              child: Text(
                                                'Khách vãng lai / Giao lưu (GUEST)',
                                                style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppSpacing.gapW8,
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: colors.warning.withValues(alpha: 0.15),
                                          borderRadius: AppRadius.tag,
                                        ),
                                        child: Text(
                                          'Vé giao lưu',
                                          style: AppTypography.labelSmall.bold.colored(colors.warning),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH8,
                                  TextFormField(
                                    controller: _guestFeeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: const [CurrencyThousandsFormatter()],
                                    style: AppTypography.bodyMedium.colored(colors.textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Đơn giá vé khách vãng lai / buổi',
                                      labelStyle: AppTypography.labelSmall.colored(colors.textMuted),
                                      suffixText: 'đ/buổi',
                                      filled: true,
                                      fillColor: colors.inputFill,
                                      border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.gapH16,

                            // Khối 3: Bảng mô phỏng nhanh (Live Fee Preview)
                            _buildLiveFeeSimulationPreview(),
                          ],
                        ),
                        AppSpacing.gapH16,

                        // Section: Tài khoản ngân hàng VietQR
                        _buildSectionCard(
                          title: 'Tài Khoản Ngân Hàng Nhận Tiền (VietQR)',
                          icon: Icons.qr_code_2_rounded,
                          children: [
                            Text(
                              'Ngân hàng thụ hưởng',
                              style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                            ),
                            AppSpacing.gapH8,
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['Vietcombank', 'MB Bank', 'Techcombank', 'ACB', 'BIDV', 'VPBank', 'TPBank'].map((bank) {
                                  final isSelected = _bankName == bank;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(bank),
                                      selected: isSelected,
                                      selectedColor: colors.primary,
                                      labelStyle: AppTypography.labelSmall.copyWith(
                                        color: isSelected ? AppColors.white : colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      backgroundColor: colors.surfaceSubtle,
                                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                                      onSelected: (_) => setState(() => _bankName = bank),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            AppSpacing.gapH12,
                            Text('Số tài khoản ngân hàng', style: AppTypography.labelMedium.colored(colors.textPrimary)),
                            AppSpacing.gapH4,
                            TextFormField(
                              controller: _bankAccountController,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số tài khoản';
                                if (!RegExp(r'^\d{6,20}$').hasMatch(v.trim())) {
                                  return 'Số tài khoản phải gồm 6–20 chữ số';
                                }
                                return null;
                              },
                              style: AppTypography.bodyMedium.colored(colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Ví dụ: 1029384756',
                                filled: true,
                                fillColor: colors.inputFill,
                                border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            AppSpacing.gapH12,
                            Text('Tên chủ tài khoản (In hoa không dấu)', style: AppTypography.labelMedium.colored(colors.textPrimary)),
                            AppSpacing.gapH4,
                            TextFormField(
                              controller: _bankHolderController,
                              textCapitalization: TextCapitalization.characters,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên chủ tài khoản';
                                if (v.trim().length < 3) return 'Tên chủ tài khoản tối thiểu 3 ký tự';
                                return null;
                              },
                              style: AppTypography.bodyMedium.colored(colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Ví dụ: NGUYEN VAN A',
                                filled: true,
                                fillColor: colors.inputFill,
                                border: OutlineInputBorder(borderRadius: AppRadius.input, borderSide: BorderSide(color: colors.inputBorder)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            AppSpacing.gapH12,
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.qr_code_scanner_rounded, size: 28, color: colors.primary),
                                  AppSpacing.gapW12,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('VietQR Tự Động Gạch Nợ', style: AppTypography.labelSmall.bold.colored(colors.textPrimary)),
                                        Text(
                                          'Khi thành viên quét mã VietQR, hệ thống ngân hàng sẽ gửi Webhook để tự động xác nhận đã chuyển khoản 100%.',
                                          style: AppTypography.bodySmall.colored(colors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapH16,

                        // Section 4: Quản lý vai trò (Nếu là Host hoặc có quyền quản lý vai trò)
                        if (isHost || canManageRoles) ...[
                          _buildSectionCard(
                            title: 'Phân Quyền Vai Trò (Discord-Style)',
                            icon: Icons.shield_outlined,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primary.withValues(alpha: 0.08),
                                      colors.surfaceSubtle,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: AppRadius.borderMd,
                                  border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: colors.primary,
                                            borderRadius: AppRadius.tag,
                                          ),
                                          child: Text(
                                            'RBAC PHÂN QUYỀN',
                                            style: AppTypography.labelSmall.bold.colored(AppColors.white),
                                          ),
                                        ),
                                        AppSpacing.gapW8,
                                        Expanded(
                                          child: Text(
                                            'Quản trị đa vai trò',
                                            style: AppTypography.labelSmall.semiBold.colored(colors.textMuted),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSpacing.gapH8,
                                    Text(
                                      'Tùy chỉnh các vai trò (Host, Thủ quỹ, Ban điều hành...) và phân bổ cây quyền hạn chi tiết trong câu lạc bộ.',
                                      style: AppTypography.bodySmall.colored(colors.textSecondary),
                                    ),
                                    AppSpacing.gapH12,
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors.primary,
                                          foregroundColor: AppColors.white,
                                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          elevation: 0,
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
                                  foregroundColor: colors.warning,
                                  side: BorderSide(color: colors.warning),
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                ),
                                icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                                label: const Text('Tạm dừng hoạt động CLB'),
                                onPressed: () => _showLockClubDialog(vm),
                              ),
                              AppSpacing.gapH16,
                            ],
                            if (!isHost) ...[
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
                                  foregroundColor: colors.error,
                                  side: BorderSide(color: colors.error),
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                ),
                                icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                                label: const Text('Rời câu lạc bộ'),
                                onPressed: _showLeaveClubDialog,
                              ),
                            ],
                          ],
                        ),
                        AppSpacing.gapH32,
                      ],
                    ),
                  ),
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
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDanger ? colors.error.withValues(alpha: 0.35) : colors.cardBorder,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (isDanger ? colors.error : colors.primary).withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  icon,
                  color: isDanger ? colors.error : colors.primary,
                  size: 18,
                ),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.bold.colored(
                    isDanger ? colors.error : colors.textPrimary,
                  ),
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

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Widget _buildLiveFeeSimulationPreview() {
    final monthlyMale = int.tryParse(_monthlyFeeController.text.replaceAll('.', '').trim()) ?? 500000;
    final monthlyDisc = int.tryParse(_femaleDiscountMonthlyController.text.replaceAll('.', '').trim()) ?? 50000;
    final monthlyFemale = (monthlyMale - monthlyDisc).clamp(0, 99999999);

    final dailyMale = int.tryParse(_dailyMemberFeeController.text.replaceAll('.', '').trim()) ?? 50000;
    final dailyDisc = int.tryParse(_femaleDiscountController.text.replaceAll('.', '').trim()) ?? 10000;
    final dailyFemale = (dailyMale - dailyDisc).clamp(0, 99999999);

    final guestFee = int.tryParse(_guestFeeController.text.replaceAll('.', '').trim()) ?? 70000;
    final guestFemale = (guestFee - dailyDisc).clamp(0, 99999999);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, size: 17, color: colors.primary),
              AppSpacing.gapW8,
              Flexible(
                child: Text(
                  'Bảng Tóm Tắt Áp Dụng Khi Chốt Sổ Buổi Chơi',
                  style: AppTypography.labelMedium.bold.colored(colors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          _buildPreviewRow(
            label: 'Hội viên Gói Tháng (Nam / Nữ)',
            value: '${_formatCurrency(monthlyMale)} đ / ${_formatCurrency(monthlyFemale)} đ (Ra sân: 0 đ/buổi)',
          ),
          AppSpacing.gapH4,
          _buildPreviewRow(
            label: 'Hội viên Theo buổi (Nam / Nữ)',
            value: '${_formatCurrency(dailyMale)} đ / ${_formatCurrency(dailyFemale)} đ mỗi buổi',
          ),
          AppSpacing.gapH4,
          _buildPreviewRow(
            label: 'Khách vãng lai (Nam / Nữ)',
            value: '${_formatCurrency(guestFee)} đ / ${_formatCurrency(guestFemale)} đ mỗi buổi',
          ),
          AppSpacing.gapH4,
          _buildPreviewRow(
            label: 'Quy tắc làm tròn VietQR',
            value: 'Làm tròn chẵn ${_roundRule ~/ 1000}.000đ',
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: AppTypography.labelSmall.colored(colors.textSecondary),
            ),
          ),
          AppSpacing.gapW8,
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyThousandsFormatter extends TextInputFormatter {
  const CurrencyThousandsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final cleanDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      if (i > 0 && (cleanDigits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanDigits[i]);
    }
    final formatted = buffer.toString();

    final digitsBeforeCursor = newValue.selection.baseOffset >= 0
        ? newValue.text
            .substring(0, newValue.selection.baseOffset.clamp(0, newValue.text.length))
            .replaceAll(RegExp(r'\D'), '')
            .length
        : cleanDigits.length;

    int newCursorOffset = 0;
    int digitsSeen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (formatted[i] != '.') {
        digitsSeen++;
      }
      if (digitsSeen == digitsBeforeCursor) {
        newCursorOffset = i + 1;
        break;
      }
    }
    if (digitsSeen < digitsBeforeCursor) {
      newCursorOffset = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorOffset.clamp(0, formatted.length),
      ),
    );
  }
}
