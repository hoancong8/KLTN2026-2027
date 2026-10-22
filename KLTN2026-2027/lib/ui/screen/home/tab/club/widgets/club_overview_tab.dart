// lib/ui/screen/home/tab/club/widgets/club_overview_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../../../../../../app/l10n_gen/app_localizations.dart';
import '../../../../../../domain/entities/club/club_detail.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../../../domain/enums/session_enums.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';
import '../../../../club/club_vm/club_context_vm.dart';
import '../../../../club/role_management/club_role_management_screen.dart';
import '../../../../club_detail/club_detail_vm/club_detail_vm.dart';
import 'club_qr_dialog.dart';
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

  AppThemeColors get colors => context.colors;
  AppLocalizations get l10n => context.l10n;

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
      backgroundColor: AppColors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colors.cardBackground,
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
                    Text(l10n.club_config_venue_recruit, style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                Divider(color: colors.cardBorder),
                AppSpacing.gapH8,
                Text(l10n.club_fixed_venue_name, style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                AppSpacing.gapH8,
                TextField(
                  controller: venueController,
                  decoration: InputDecoration(
                    hintText: l10n.club_fixed_venue_hint,
                    hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                    contentPadding: AppSpacing.allMd,
                  ),
                ),
                AppSpacing.gapH12,
                Text(l10n.club_fixed_address, style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                AppSpacing.gapH8,
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: l10n.club_fixed_address_hint,
                    hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                    contentPadding: AppSpacing.allMd,
                  ),
                ),
                AppSpacing.gapH12,
                Text(l10n.role_description_label, style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
                AppSpacing.gapH8,
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n.role_description_hint,
                    hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
                    contentPadding: AppSpacing.allMd,
                  ),
                ),
                AppSpacing.gapH12,
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: colors.primary,
                  title: Text(l10n.club_recruiting_status, style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                  subtitle: Text('Cho phép người chơi khác tìm thấy và nộp đơn xin gia nhập', style: AppTypography.bodySmall.colored(colors.textMuted)),
                  value: isRecruiting,
                  onChanged: (val) => setSheetState(() => isRecruiting = val),
                ),
                AppSpacing.gapH16,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
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
      backgroundColor: AppColors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: colors.cardBackground,
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
                    Text(l10n.club_schedule_setup_title, style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                Divider(color: colors.cardBorder),
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
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
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
                    child: Text(l10n.club_schedule_save, style: AppTypography.labelLarge.bold.colored(AppColors.white)),
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
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                          ),
                          Text(
                            'Chia sẻ mã này để bạn bè tham gia ngay không cần duyệt',
                            style: AppTypography.bodySmall.colored(colors.textMuted),
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
                    color: colors.cardBackground,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag_rounded, color: AppColors.primary, size: 20),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Text(
                          code,
                          style: AppTypography.headlineMedium.bold.colored(colors.textPrimary).copyWith(letterSpacing: 2),
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
                      AppSpacing.gapW8,
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                        icon: const Icon(Icons.qr_code_rounded, size: AppSpacing.iconXs),
                        label: Text('Mã QR', style: AppTypography.labelMedium.bold.colored(colors.primary)),
                        onPressed: () => ClubQrDialog.show(
                          context: context,
                          clubName: club?.groupName ?? 'Câu Lạc Bộ',
                          clubCode: code,
                          avatarUrl: club?.avatarUrl,
                        ),
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
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
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
                          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
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
                  style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                ),
                AppSpacing.gapH4,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: AppSpacing.iconXs, color: colors.textMuted),
                    AppSpacing.gapW4,
                    Expanded(
                      child: Text(
                        club?.fixedAddress != null && club!.fixedAddress!.isNotEmpty
                            ? club.fixedAddress!
                            : 'Chưa cập nhật địa chỉ sân',
                        style: AppTypography.bodySmall.colored(colors.textMuted),
                      ),
                    ),
                    if (club?.fixedAddress != null && club!.fixedAddress!.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.content_copy_rounded, size: 16, color: colors.primary),
                        tooltip: 'Sao chép địa chỉ',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => _copyToClipboard(club.fixedAddress!, 'Đã sao chép địa chỉ sân'),
                      ),
                  ],
                ),
                if (club?.lat != null && club?.lng != null) ...[
                  AppSpacing.gapH4,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed_rounded, size: 12, color: colors.primary),
                        AppSpacing.gapW4,
                        Text(
                          'Tọa độ GPS: ${club!.lat!.toStringAsFixed(4)}, ${club.lng!.toStringAsFixed(4)}',
                          style: AppTypography.labelSmall.colored(colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 3. Regular Weekly Schedules Card (FR07, FR13)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
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
                          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
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
                    style: AppTypography.bodySmall.colored(colors.textMuted),
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
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                                AppSpacing.gapW8,
                                Text(
                                  '${s.dayName}: ${s.startTime} - ${s.endTime}',
                                  style: AppTypography.labelMedium.bold.colored(colors.primary),
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
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hồ sơ & Đánh giá câu lạc bộ',
                  style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                ),
                AppSpacing.gapH12,
                _buildInfoRow(
                  'Điểm chất lượng CLB',
                  club != null ? '${club.qualityScore.toStringAsFixed(1)} / 5.0' : '5.0 / 5.0',
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Sĩ số thành viên',
                  club != null ? '${club.memberCount} thành viên' : 'Đang tải...',
                  icon: Icons.people_outline_rounded,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Trình độ tiếp nhận',
                  (club?.minSkillLevel != null && club?.maxSkillLevel != null)
                      ? '${club!.minSkillLevel!.code} -> ${club.maxSkillLevel!.code}'
                      : 'Mọi trình độ',
                  icon: Icons.speed_rounded,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Tuyển thành viên mới',
                  (club?.isRecruiting ?? false) ? 'Đang mở tuyển' : 'Tạm đóng',
                  icon: Icons.how_to_reg_rounded,
                  valueColor: (club?.isRecruiting ?? false) ? AppColors.success : colors.textMuted,
                ),
                if (club?.host != null) ...[
                  Divider(height: AppSpacing.base, color: colors.cardBorder),
                  _buildInfoRow(
                    'Chủ nhiệm (Host)',
                    club!.host.fullName,
                    icon: Icons.person_outline_rounded,
                  ),
                ],
                if (club?.description != null && club!.description!.isNotEmpty) ...[
                  Divider(height: AppSpacing.base, color: colors.cardBorder),
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

          // 5. Club Finance & Treasury Card (FR22, UC19)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
                        AppSpacing.gapW8,
                        Text(
                          'Sổ quỹ & Tài chính CLB (FR22)',
                          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadius.tag,
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Minh bạch',
                        style: AppTypography.labelSmall.bold.colored(AppColors.success),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                _buildInfoRow(
                  'Nguyên tắc thu chi',
                  'Công khai theo từng buổi chơi & định kỳ tháng',
                  icon: Icons.receipt_long_rounded,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Quy chế quỹ nhóm',
                  'Tự động đối soát chuyển khoản VietQR',
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 6. Host Quick Action Shortcuts
          if (canManageRoles) ...[
            Container(
              padding: AppSpacing.allBase,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản trị ban điều hành',
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
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

          // 7. My Bookings Button
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

          // 8. Leave Club Button (Only for non-Host members)
          if (!isHost) ...[
            AppSpacing.gapH16,
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                padding: AppSpacing.verticalMd,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              icon: const Icon(Icons.exit_to_app_rounded, size: AppSpacing.iconSm),
              label: Text(
                'Rời khỏi câu lạc bộ',
                style: AppTypography.labelLarge.bold.colored(colors.error),
              ),
              onPressed: () => _confirmLeaveClub(context),
            ),
          ],
          AppSpacing.gapH24,
        ],
      ),
    );
  }

  void _confirmLeaveClub(BuildContext context) {
    final currentProfile = ref.read(currentUserProfileProvider);
    if (currentProfile == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text('Xác nhận rời câu lạc bộ', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
        content: Text(
          'Bạn có chắc chắn muốn rời khỏi câu lạc bộ này? Bạn sẽ mất quyền truy cập vào các buổi tập và thông tin nội bộ của nhóm.',
          style: AppTypography.bodyMedium.colored(colors.textSecondary),
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
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ref.read(clubMembersViewModelProvider.notifier).removeMember(currentProfile.id);
              if (ok && context.mounted) {
                await ref.read(clubContextViewModelProvider.notifier).loadMyClubs();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã rời khỏi câu lạc bộ thành công.'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Rời nhóm', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
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
          Icon(icon, size: 16, color: iconColor ?? colors.textMuted),
          AppSpacing.gapW8,
        ],
        SizedBox(
          width: 140,
          child: Text(label, style: AppTypography.bodySmall.colored(colors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.semiBold.colored(valueColor ?? colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
