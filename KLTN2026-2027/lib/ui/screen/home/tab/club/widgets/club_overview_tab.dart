// lib/ui/screen/home/tab/club/widgets/club_overview_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../domain/entities/club/club_detail.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../../../domain/enums/session_enums.dart';
import '../../../../club/role_management/club_role_management_screen.dart';
import '../../../../club_detail/club_detail_vm/club_detail_vm.dart';
import 'club_schedule_planner.dart';

class ClubOverviewTab extends ConsumerStatefulWidget {
  final String clubId;
  final String clubCode;
  final ClubRole userRole;

  const ClubOverviewTab({
    super.key,
    required this.clubId,
    required this.clubCode,
    required this.userRole,
  });

  @override
  ConsumerState<ClubOverviewTab> createState() => _ClubOverviewTabState();
}

class _ClubOverviewTabState extends ConsumerState<ClubOverviewTab> {
  void _copyToClipboard(String text, String message) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditInfoDialog(ClubDetail club, ClubDetailViewModel vm) {
    final venueController = TextEditingController(text: club.fixedVenueName ?? '');
    final addressController = TextEditingController(text: club.fixedAddress ?? '');
    final descController = TextEditingController(text: club.description ?? '');
    SkillLevel? minSkill = club.minSkillLevel;
    SkillLevel? maxSkill = club.maxSkillLevel;
    bool isRecruiting = club.isRecruiting;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.bottomSheet,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cấu hình sân & tuyển quân', style: AppTypography.titleMedium.bold),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                AppSpacing.gapH8,
                Text('Tên sân cố định', style: AppTypography.labelMedium.bold.colored(AppColors.textPrimary)),
                AppSpacing.gapH8,
                TextField(
                  controller: venueController,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Sân Cầu Lông Kỳ Hòa',
                    hintStyle: AppTypography.bodyMedium.colored(AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    border: const OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
                    contentPadding: AppSpacing.allMd,
                  ),
                ),
                AppSpacing.gapH12,
                Text('Địa chỉ sân', style: AppTypography.labelMedium.bold.colored(AppColors.textPrimary)),
                AppSpacing.gapH8,
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: 238 Đường 3/2, Phường 12, Quận 10',
                    hintStyle: AppTypography.bodyMedium.colored(AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    border: const OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
                    contentPadding: AppSpacing.allMd,
                  ),
                ),
                AppSpacing.gapH12,
                Text('Mô tả nhóm', style: AppTypography.labelMedium.bold.colored(AppColors.textPrimary)),
                AppSpacing.gapH8,
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Giới thiệu về không khí, chi phí hoặc yêu cầu...',
                    hintStyle: AppTypography.bodyMedium.colored(AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    border: const OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
                    contentPadding: AppSpacing.allMd,
                  ),
                ),
                AppSpacing.gapH12,
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: Text('Mở tuyển thành viên mới', style: AppTypography.titleSmall.bold),
                  subtitle: Text('Cho phép người chơi khác tìm thấy và nộp đơn xin gia nhập', style: AppTypography.bodySmall.colored(AppColors.textMuted)),
                  value: isRecruiting,
                  onChanged: (val) => setSheetState(() => isRecruiting = val),
                ),
                AppSpacing.gapH16,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: AppSpacing.verticalMd,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await vm.updateInfo(
                        groupName: club.groupName,
                        fixedVenueName: venueController.text.trim(),
                        fixedAddress: addressController.text.trim(),
                        description: descController.text.trim(),
                        minSkillLevel: minSkill,
                        maxSkillLevel: maxSkill,
                        isRecruiting: isRecruiting,
                      );
                    },
                    child: Text('Lưu thông tin sân', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String timeStr, TimeOfDay fallback) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.isEmpty) return fallback;
      final h = int.parse(parts[0]);
      final m = parts.length > 1 ? int.parse(parts[1]) : 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return fallback;
    }
  }

  void _showEditSchedulesDialog(ClubDetail club, ClubDetailViewModel vm) {
    final initialSchedules = club.schedules
        .where((s) => s.isActive)
        .map((s) => ClubScheduleEntry(
              dayOfWeek: s.dayOfWeek,
              startTime: _parseTimeOfDay(s.startTime, const TimeOfDay(hour: 18, minute: 0)),
              endTime: _parseTimeOfDay(s.endTime, const TimeOfDay(hour: 20, minute: 0)),
            ))
        .toList();

    List<ClubScheduleEntry> updatedSchedules = List.from(initialSchedules);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.bottomSheet,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Thiết lập lịch tuần', style: AppTypography.titleMedium.bold),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border),
                AppSpacing.gapH8,
                ClubSchedulePlanner(
                  initialSchedules: initialSchedules,
                  onChanged: (list) {
                    updatedSchedules = list;
                  },
                ),
                AppSpacing.gapH16,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: AppSpacing.verticalMd,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      String formatTime(TimeOfDay t) =>
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

                      final inputs = updatedSchedules
                          .map((e) => ClubScheduleInput(
                                dayOfWeek: e.dayOfWeek,
                                startTime: formatTime(e.startTime),
                                endTime: formatTime(e.endTime),
                              ))
                          .toList();

                      await vm.updateSchedules(inputs);
                    },
                    child: Text('Lưu lịch tuần', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubDetailViewModelProvider(widget.clubId));
    final vm = ref.read(clubDetailViewModelProvider(widget.clubId).notifier);
    final activeContext = ref.watch(activeClubContextProvider);

    final isHost = activeContext?.role == ClubRole.host || widget.userRole == ClubRole.host;
    final canManageSchedule = isHost || ref.hasClubPermission('OPERATIONS.SCHEDULE.MANAGE');
    final canManageInfo = isHost || ref.hasClubPermission('MEMBER.INFO.UPDATE');
    final canManageRoles = isHost || ref.hasClubPermission('MEMBER.ROLE.MANAGE');

    if (state.isLoading && state.club == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final club = state.club;
    final code = widget.clubCode.isNotEmpty ? widget.clubCode : (club?.code ?? 'CHƯA CÓ');

    return RefreshIndicator(
      onRefresh: () => vm.loadDetail(),
      color: AppColors.primary,
      child: ListView(
        padding: AppSpacing.allBase,
        children: [
          // 1. Invite Friends Card (Discord Style)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.allSm,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: const Icon(Icons.group_add_rounded, color: AppColors.white, size: 20),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mời bạn bè vào nhóm',
                            style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                          ),
                          Text(
                            'Chia sẻ mã này để bạn bè tham gia ngay không cần duyệt',
                            style: AppTypography.bodySmall.colored(AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag_rounded, color: AppColors.primary, size: 20),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Text(
                          code,
                          style: AppTypography.headlineMedium.bold.colored(AppColors.textPrimary).copyWith(letterSpacing: 2),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                        icon: const Icon(Icons.copy, size: AppSpacing.iconXs),
                        label: Text('Sao chép', style: AppTypography.labelMedium.colored(AppColors.onPrimary)),
                        onPressed: () => _copyToClipboard(code, 'Đã sao chép mã nhóm: $code'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 2. Fixed Venue & Location Card (FR07)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stadium_rounded, color: AppColors.primary, size: 20),
                        AppSpacing.gapW8,
                        Text(
                          'Sân sinh hoạt cố định',
                          style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                        ),
                      ],
                    ),
                    if (canManageInfo && club != null)
                      TextButton.icon(
                        onPressed: () => _showEditInfoDialog(club, vm),
                        icon: const Icon(Icons.edit_outlined, size: AppSpacing.iconXs),
                        label: Text('Chỉnh sửa', style: AppTypography.labelSmall.colored(AppColors.primary)),
                      ),
                  ],
                ),
                AppSpacing.gapH8,
                Text(
                  club?.fixedVenueName != null && club!.fixedVenueName!.isNotEmpty
                      ? club.fixedVenueName!
                      : 'Chưa thiết lập sân cố định',
                  style: AppTypography.titleMedium.bold.colored(AppColors.textPrimary),
                ),
                AppSpacing.gapH4,
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: AppSpacing.iconXs, color: AppColors.textMuted),
                    AppSpacing.gapW4,
                    Expanded(
                      child: Text(
                        club?.fixedAddress != null && club!.fixedAddress!.isNotEmpty
                            ? club.fixedAddress!
                            : 'Chưa cập nhật địa chỉ sân',
                        style: AppTypography.bodySmall.colored(AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 3. Regular Weekly Schedules Card (FR07, FR13)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                        AppSpacing.gapW8,
                        Text(
                          'Lịch sinh hoạt định kỳ tuần',
                          style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                        ),
                      ],
                    ),
                    if (canManageSchedule && club != null)
                      TextButton.icon(
                        onPressed: () => _showEditSchedulesDialog(club, vm),
                        icon: const Icon(Icons.edit_calendar_outlined, size: AppSpacing.iconXs),
                        label: Text('Sửa lịch', style: AppTypography.labelSmall.colored(AppColors.primary)),
                      ),
                  ],
                ),
                AppSpacing.gapH8,
                if (club?.schedules == null || club!.schedules.isEmpty)
                  Text(
                    'Chưa thiết lập lịch định kỳ tuần',
                    style: AppTypography.bodySmall.colored(AppColors.textMuted),
                  )
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: club.schedules
                        .where((s) => s.isActive)
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                                AppSpacing.gapW8,
                                Text(
                                  '${s.dayName}: ${s.startTime} - ${s.endTime}',
                                  style: AppTypography.labelMedium.bold.colored(AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 4. Club Quality & Details Card (FR23)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hồ sơ & Đánh giá câu lạc bộ',
                  style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                ),
                AppSpacing.gapH12,
                _buildInfoRow(
                  'Điểm chất lượng CLB',
                  club != null ? '${club.qualityScore.toStringAsFixed(1)} / 5.0' : '5.0 / 5.0',
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                ),
                const Divider(height: AppSpacing.base, color: AppColors.border),
                _buildInfoRow(
                  'Sĩ số thành viên',
                  club != null ? '${club.memberCount} thành viên' : 'Đang tải...',
                  icon: Icons.people_outline_rounded,
                ),
                const Divider(height: AppSpacing.base, color: AppColors.border),
                _buildInfoRow(
                  'Trình độ tiếp nhận',
                  (club?.minSkillLevel != null && club?.maxSkillLevel != null)
                      ? '${club!.minSkillLevel!.code} -> ${club.maxSkillLevel!.code}'
                      : 'Mọi trình độ',
                  icon: Icons.speed_rounded,
                ),
                const Divider(height: AppSpacing.base, color: AppColors.border),
                _buildInfoRow(
                  'Tuyển thành viên mới',
                  (club?.isRecruiting ?? false) ? 'Đang mở tuyển' : 'Tạm đóng',
                  icon: Icons.how_to_reg_rounded,
                  valueColor: (club?.isRecruiting ?? false) ? AppColors.success : AppColors.textMuted,
                ),
                if (club?.host != null) ...[
                  const Divider(height: AppSpacing.base, color: AppColors.border),
                  _buildInfoRow(
                    'Chủ nhiệm (Host)',
                    club!.host.fullName,
                    icon: Icons.person_outline_rounded,
                  ),
                ],
                if (club?.description != null && club!.description!.isNotEmpty) ...[
                  const Divider(height: AppSpacing.base, color: AppColors.border),
                  _buildInfoRow(
                    'Mô tả nhóm',
                    club.description!,
                    icon: Icons.notes_rounded,
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 5. Host Quick Action Shortcuts
          if (canManageRoles) ...[
            Container(
              padding: AppSpacing.allBase,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản trị ban điều hành',
                    style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                  ),
                  AppSpacing.gapH12,
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roleHost,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.shield_rounded, size: AppSpacing.iconSm),
                    label: Text(
                      'Vai Trò & Cây Phân Quyền Nhóm (FR03)',
                      style: AppTypography.labelLarge.bold.colored(AppColors.white),
                    ),
                    onPressed: () {
                      ClubRoleManagementScreen.show(context, clubId: widget.clubId);
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
          ],

          // 6. My Bookings Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.3),
              padding: AppSpacing.verticalMd,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            icon: const Icon(Icons.event_available_rounded, size: AppSpacing.iconSm),
            label: Text(
              'Lịch Tôi Đã Đăng Ký (Vé & Điểm Danh)',
              style: AppTypography.labelLarge.bold.colored(AppColors.primary),
            ),
            onPressed: () => context.push(AppConfig.myBookingsRoutePath),
          ),
          AppSpacing.gapH24,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: iconColor ?? AppColors.textMuted),
          AppSpacing.gapW8,
        ],
        SizedBox(
          width: 140,
          child: Text(label, style: AppTypography.bodySmall.colored(AppColors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.semiBold.colored(valueColor ?? AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
