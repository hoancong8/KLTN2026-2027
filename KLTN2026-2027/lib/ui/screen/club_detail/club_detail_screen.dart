import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme.dart';
import '../../../app/provider/localization_provider.dart';
import '../../../app/l10n_gen/app_localizations.dart';
import '../../../app/utils/exception_ext.dart';
import '../../../domain/entities/club/club_detail.dart';
import '../../../domain/enums/session_enums.dart';
import '../home/tab/club/widgets/club_schedule_planner.dart';
import '../home/tab/club/widgets/club_sessions_tab.dart';
import 'club_detail_vm/club_detail_vm.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;
  const ClubDetailScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AppThemeColors get colors => context.colors;
  AppLocalizations get l10n => context.l10n;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showJoinRequestDialog() {
    final introController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: colors.primary, size: 26),
            const SizedBox(width: 8),
            Text(l10n.club_join_request_title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.club_join_request_intro_hint,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: introController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.club_join_request_example,
                hintStyle: TextStyle(fontSize: 12, color: colors.textMuted),
                filled: true,
                fillColor: colors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.inputBorder),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(clubDetailViewModelProvider(widget.clubId).notifier)
                  .sendJoinRequest(introController.text.trim());
            },
            child: Text(l10n.club_join_request_send),
          ),
        ],
      ),
    );
  }

  void _showEditInfoDialog(ClubDetail club) {
    final venueController = TextEditingController(text: club.fixedVenueName ?? '');
    final addressController = TextEditingController(text: club.fixedAddress ?? '');
    final descController = TextEditingController(text: club.description ?? '');
    bool isRecruiting = club.isRecruiting;
    SkillLevel minSkill = club.minSkillLevel ?? SkillLevel.nb;
    SkillLevel maxSkill = club.maxSkillLevel ?? SkillLevel.k;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.club_config_venue_recruit,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Text(l10n.club_fixed_venue_name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: venueController,
                  decoration: InputDecoration(
                    hintText: l10n.club_fixed_venue_hint,
                    hintStyle: TextStyle(color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.club_fixed_address, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: l10n.club_fixed_address_hint,
                    hintStyle: TextStyle(color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.role_description_label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n.role_description_hint,
                    hintStyle: TextStyle(color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: colors.primary,
                  title: Text(l10n.club_recruiting_status, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  value: isRecruiting,
                  onChanged: (val) => setSheetState(() => isRecruiting = val),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await ref.read(clubDetailViewModelProvider(widget.clubId).notifier).updateInfo(
                            groupName: club.groupName,
                            fixedVenueName: venueController.text.trim(),
                            fixedAddress: addressController.text.trim(),
                            description: descController.text.trim(),
                            minSkillLevel: minSkill,
                            maxSkillLevel: maxSkill,
                            isRecruiting: isRecruiting,
                          );
                    },
                    child: const Text('Lưu thông tin sân', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showEditSchedulesDialog(ClubDetail club) {
    final initialSchedules = club.schedules
        .where((s) => s.isActive)
        .map((s) => ClubScheduleEntry(
              dayOfWeek: s.dayOfWeek,
              startTime: _parseTimeOfDay(s.startTime, const TimeOfDay(hour: 18, minute: 0)),
              endTime: _parseTimeOfDay(s.endTime, const TimeOfDay(hour: 20, minute: 0)),
            ))
        .toList();

    List<ClubScheduleEntry> currentSchedules = List.from(initialSchedules);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.90,
          ),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.event_repeat_rounded, color: colors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thiết lập lịch sinh hoạt định kỳ',
                            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Lịch tháng, chọn ngày và cài đặt giờ cố định hoặc tùy chỉnh',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.cardBorder),

              // Planner Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ClubSchedulePlanner(
                    initialSchedules: initialSchedules,
                    onChanged: (updated) {
                      currentSchedules = updated;
                    },
                  ),
                ),
              ),

              // Footer Action
              Divider(height: 1, color: colors.cardBorder),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (currentSchedules.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng chọn ít nhất một ngày sinh hoạt trong tuần.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      for (final entry in currentSchedules) {
                        final startMin = entry.startTime.hour * 60 + entry.startTime.minute;
                        final endMin = entry.endTime.hour * 60 + entry.endTime.minute;
                        if (startMin >= endMin) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Giờ bắt đầu phải trước giờ kết thúc.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                      }

                      Navigator.of(ctx).pop();
                      final Map<int, ClubScheduleInput> distinctMap = {};
                      for (final entry in currentSchedules) {
                        final hStart = entry.startTime.hour.toString().padLeft(2, '0');
                        final mStart = entry.startTime.minute.toString().padLeft(2, '0');
                        final hEnd = entry.endTime.hour.toString().padLeft(2, '0');
                        final mEnd = entry.endTime.minute.toString().padLeft(2, '0');
                        distinctMap[entry.dayOfWeek] = ClubScheduleInput(
                          dayOfWeek: entry.dayOfWeek,
                          startTime: '$hStart:$mStart',
                          endTime: '$hEnd:$mEnd',
                        );
                      }
                      final inputList = distinctMap.values.toList();

                      await ref
                          .read(clubDetailViewModelProvider(widget.clubId).notifier)
                          .updateSchedules(inputList);
                    },
                    child: const Text(
                      'Lưu lịch sinh hoạt',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubDetailViewModelProvider(widget.clubId));
    final vm = ref.read(clubDetailViewModelProvider(widget.clubId).notifier);

    ref.listen(clubDetailViewModelProvider(widget.clubId), (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.getDisplayMessage(context.l10n)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final club = state.club;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.cardBackground,
        elevation: 0,
        title: Text(
          club?.groupName ?? 'Chi tiết Câu lạc bộ',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (club != null && club.currentUserStatus.isHost) ...[
            IconButton(
              icon: Icon(Icons.settings_outlined, color: colors.textPrimary, size: 22),
              tooltip: 'Cài đặt CLB',
              onPressed: () => _showEditInfoDialog(club),
            ),
            IconButton(
              icon: Icon(Icons.calendar_month_outlined, color: colors.textPrimary, size: 22),
              tooltip: 'Sửa lịch tuần',
              onPressed: () => _showEditSchedulesDialog(club),
            ),
            IconButton(
              icon: Icon(Icons.people_outline_rounded, color: colors.textPrimary, size: 22),
              tooltip: 'Quản lý thành viên',
              onPressed: () => context.push('/club/${widget.clubId}/roles'),
            ),
          ] else if (club != null && club.currentUserStatus.isMember)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary),
              onSelected: (val) {
                if (val == 'info') {
                  _showEditInfoDialog(club);
                } else if (val == 'schedules') {
                  _showEditSchedulesDialog(club);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.edit_location_alt_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Cấu hình sân & tuyển quân', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'schedules',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Thiết lập lịch tuần', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: colors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Lịch sinh hoạt'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Thông tin CLB'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading && club == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : club == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 56, color: colors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'Không thể tải thông tin câu lạc bộ',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => vm.loadDetail(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Danh sách các buổi tập 14 ngày tới (tự động khởi tạo)
                    ClubSessionsTab(
                      clubId: widget.clubId,
                      clubName: club.groupName,
                      isHost: club.currentUserStatus.isHost,
                    ),

                    // Tab 2: Thông tin chi tiết & sân cố định
                    RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => vm.loadDetail(),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildClubHeaderCard(club),
                          const SizedBox(height: 16),
                          _buildVenueCard(club),
                          const SizedBox(height: 16),
                          _buildSchedulesCard(club),
                          const SizedBox(height: 16),
                          _buildHostCard(club),
                          const SizedBox(height: 16),
                          _buildIntroCard(club),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: club != null ? _buildBottomActionBar(club, vm, state.isSubmitting) : null,
    );
  }

  Widget _buildClubHeaderCard(ClubDetail club) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                      ? Image.network(
                          club.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.sports_tennis_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.sports_tennis_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.groupName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Code chip with copy button
                    InkWell(
                      onTap: () => _copyToClipboard(club.code, 'Đã sao chép mã nhóm: ${club.code}'),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mã: ${club.code}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.copy_rounded, size: 12, color: colors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    if (club.currentUserStatus.isHost) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.roleHost.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.roleHost.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded, size: 12, color: AppColors.roleHost),
                            SizedBox(width: 4),
                            Text(
                              'CHỦ NHÓM (HOST)',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.roleHost,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('Thành viên', '${club.memberCount}', Icons.groups_rounded, AppColors.roleDeputy),
              _buildHeaderStat('Chất lượng', club.qualityScore.toStringAsFixed(1), Icons.star_rounded, AppColors.warning),
              _buildHeaderStat(
                'Tuyển quân',
                club.isRecruiting ? 'Đang mở' : 'Đã đủ',
                Icons.how_to_reg_rounded,
                club.isRecruiting ? AppColors.success : colors.textMuted,
              ),
            ],
          ),
          if (club.schedulesSummary != null && club.schedulesSummary!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_repeat_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lịch sinh hoạt: ${club.schedulesSummary!}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.textMuted),
        ),
      ],
    );
  }

  Widget _buildVenueCard(ClubDetail club) {
    final hasVenue = club.fixedVenueName != null && club.fixedVenueName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stadium_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Sân sinh hoạt cố định',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neutral900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasVenue) ...[
            Text(
              club.fixedVenueName!,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
            ),
            if (club.fixedAddress != null && club.fixedAddress!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      club.fixedAddress!,
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                final query = club.lat != null && club.lng != null
                    ? '${club.lat},${club.lng}'
                    : club.fixedAddress ?? club.fixedVenueName!;
                _copyToClipboard(
                  'https://www.google.com/maps/search/?api=1&query=$query',
                  'Đã sao chép liên kết chỉ đường Google Maps!',
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.infoContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.infoBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_rounded, size: 16, color: AppColors.roleDeputy),
                    SizedBox(width: 6),
                    Text(
                      'Sao chép link Google Maps chỉ đường',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.roleDeputy),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text(
              'CLB chưa thiết lập sân cố định',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedulesCard(ClubDetail club) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Lịch sinh hoạt định kỳ hàng tuần',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neutral900),
              ),
              const Spacer(),
              if (club.currentUserStatus.isMember)
                InkWell(
                  onTap: () => _showEditSchedulesDialog(club),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_calendar_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Thiết lập',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (club.schedules.isEmpty)
            const Text(
              'Chưa có lịch sinh hoạt cố định trong tuần.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else
            ...club.schedules.where((s) => s.isActive).map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s.dayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.infoContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${s.startTime} - ${s.endTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.roleSky,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHostCard(ClubDetail club) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Thông tin Chủ nhiệm / Host',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neutral900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage: club.host.avatarUrl != null && club.host.avatarUrl!.isNotEmpty
                    ? NetworkImage(club.host.avatarUrl!)
                    : null,
                child: club.host.avatarUrl == null || club.host.avatarUrl!.isEmpty
                    ? Text(
                        club.host.fullName.isNotEmpty ? club.host.fullName[0].toUpperCase() : 'H',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.host.fullName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.neutral900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      club.host.phoneNumber != null && club.host.phoneNumber!.isNotEmpty
                          ? club.host.phoneNumber!
                          : 'Chưa cập nhật số điện thoại',
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              if (club.host.phoneNumber != null && club.host.phoneNumber!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.phone_rounded, color: AppColors.success),
                  tooltip: 'Sao chép SĐT Host',
                  onPressed: () => _copyToClipboard(
                    club.host.phoneNumber!,
                    'Đã sao chép SĐT Trưởng nhóm: ${club.host.phoneNumber}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(ClubDetail club) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Giới thiệu & Tiêu chuẩn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neutral900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            club.description != null && club.description!.isNotEmpty
                ? club.description!
                : 'Nhóm sinh hoạt phong trào cầu lông lành mạnh, đoàn kết, vui khỏe.',
            style: TextStyle(fontSize: 13, height: 1.4, color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Khoảng trình độ: ', style: TextStyle(fontSize: 12, color: colors.textMuted)),
              Text(
                '${club.minSkillLevel?.code ?? "NB"} - ${club.maxSkillLevel?.code ?? "G"}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ClubDetail club, ClubDetailViewModel vm, bool isSubmitting) {
    final status = club.currentUserStatus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(top: BorderSide(color: colors.cardBorder)),
        boxShadow: AppShadows.bottomBar,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: status.isMember
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final success = await vm.switchContext();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã chuyển sang CLB ${club.groupName}!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            context.pop();
                          }
                        },
                  icon: const Icon(Icons.login_rounded),
                  label: isSubmitting
                      ? const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                      : const Text(
                          'Vào sinh hoạt CLB',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                )
              : status.hasPendingJoinRequest
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningContainer,
                        foregroundColor: AppColors.tierBronze,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.hourglass_top_rounded, color: AppColors.tierBronze),
                      label: const Text(
                        'Đơn xin gia nhập đang chờ duyệt [WAITING]',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.tierBronze),
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isSubmitting ? null : _showJoinRequestDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: isSubmitting
                          ? const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                          : const Text(
                              'Gửi đơn xin gia nhập CLB',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
        ),
      ),
    );
  }
}
