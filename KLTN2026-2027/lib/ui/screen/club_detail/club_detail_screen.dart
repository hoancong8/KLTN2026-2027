import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/provider.dart';
import '../../../app/theme/theme.dart';
import '../../../domain/enums/club_role.dart';
import '../../../app/provider/localization_provider.dart';
import '../../../app/l10n_gen/app_localizations.dart';
import '../../../app/utils/exception_ext.dart';
import '../../../domain/entities/club/club_detail.dart';
import '../home/tab/club/widgets/club_qr_dialog.dart';
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
        backgroundColor: colors.primary,
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubDetailViewModelProvider(widget.clubId));
    final vm = ref.read(clubDetailViewModelProvider(widget.clubId).notifier);

    ref.listen(clubDetailViewModelProvider(widget.clubId), (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.getDisplayMessage(context.l10n)),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final club = state.club;
    final currentProfile = ref.watch(currentUserProfileProvider);
    final activeContext = ref.watch(activeClubContextProvider);
    final isSameClub = activeContext?.clubId == widget.clubId;
    final isHostOwner = club != null && currentProfile != null && club.host.userId == currentProfile.id;
    final isHost = isHostOwner || (club?.currentUserStatus.isHost ?? false) || (isSameClub && activeContext?.role == ClubRole.host);
    final canManageRoles = isHost || (isSameClub && ref.hasClubPermission('MEMBER.ROLE.MANAGE'));
    final canManageSchedule = isHost || (isSameClub && ref.hasClubPermission('OPERATIONS.SCHEDULE.MANAGE'));
    final canManageClub = isHost ||
        (isSameClub &&
            (ref.hasClubPermission('MEMBER.INFO.UPDATE') ||
                ref.hasClubPermission('OPERATIONS.SCHEDULE.MANAGE') ||
                ref.hasClubPermission('MEMBER.ROLE.MANAGE')));

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
          if (club != null && canManageClub)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: colors.textPrimary, size: 22),
              tooltip: 'Cài đặt CLB',
              onPressed: () => context.push('/club/${widget.clubId}/settings'),
            ),
          if (club != null && canManageRoles)
            IconButton(
              icon: Icon(Icons.people_outline_rounded, color: colors.textPrimary, size: 22),
              tooltip: 'Quản lý thành viên',
              onPressed: () => context.push('/club/${widget.clubId}/roles'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: colors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              unselectedLabelColor: colors.textMuted,
              indicatorColor: colors.primary,
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
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: TabBarView(
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
                          _buildSchedulesCard(club, canManageSchedule),
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
              ),
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
                  color: colors.primary.withValues(alpha: 0.1),
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
                    // Code chip with copy & QR button
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => ClubQrDialog.show(
                            context: context,
                            clubName: club.groupName,
                            clubCode: club.code,
                            avatarUrl: club.avatarUrl,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.qr_code_rounded, size: 12, color: colors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Mã QR',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_repeat_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lịch sinh hoạt: ${club.schedulesSummary!}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
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
          Row(
            children: [
              Icon(Icons.stadium_rounded, color: colors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Sân sinh hoạt cố định',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
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
            if (club.lat != null && club.lng != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed_rounded, size: 12, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Tọa độ GPS: ${club.lat!.toStringAsFixed(4)}, ${club.lng!.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 11.5, color: colors.primary),
                    ),
                  ],
                ),
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
                  color: colors.infoContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_rounded, size: 16, color: colors.info),
                    const SizedBox(width: 6),
                    Text(
                      'Sao chép link Google Maps chỉ đường',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.info),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(
              'CLB chưa thiết lập sân cố định',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedulesCard(ClubDetail club, bool canManageSchedule) {
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
              Icon(Icons.calendar_month_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Lịch sinh hoạt định kỳ hàng tuần',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
              const Spacer(),
              if (canManageSchedule)
                InkWell(
                  onTap: () => context.push('/club/${widget.clubId}/settings'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
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
            Text(
              'Chưa có lịch sinh hoạt cố định trong tuần.',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
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
                        color: colors.primary.withValues(alpha: 0.1),
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
          Row(
            children: [
              Icon(Icons.person_pin_rounded, color: colors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Thông tin Chủ nhiệm / Host',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
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
          Row(
            children: [
              Icon(Icons.notes_rounded, color: colors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Giới thiệu & Tiêu chuẩn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
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
                    backgroundColor: colors.success,
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
                        backgroundColor: colors.warningContainer,
                        foregroundColor: colors.warning,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: null,
                      icon: Icon(Icons.hourglass_top_rounded, color: colors.warning),
                      label: Text(
                        'Đơn xin gia nhập đang chờ duyệt',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.warning),
                      ),
                    )
                  : !club.isRecruiting
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.inputFill,
                            foregroundColor: colors.textMuted,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: null,
                          icon: const Icon(Icons.lock_outline_rounded),
                          label: const Text(
                            'CLB đang tạm dừng nhận đơn mới',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
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
