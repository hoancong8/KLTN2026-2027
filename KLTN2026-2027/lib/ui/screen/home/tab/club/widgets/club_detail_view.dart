// lib/ui/screen/home/tab/club/widgets/club_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../domain/entities/club/my_club.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';
import '../../../../club/club_vm/club_context_vm.dart';
import 'club_join_requests_tab.dart';
import 'club_member_section.dart';
import 'club_overview_tab.dart';
import 'club_qr_dialog.dart';
import 'club_sessions_tab.dart';

class ClubDetailView extends ConsumerStatefulWidget {
  final MyClub club;
  final bool isActiveContext;

  const ClubDetailView({
    super.key,
    required this.club,
    required this.isActiveContext,
  });

  @override
  ConsumerState<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends ConsumerState<ClubDetailView> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _canManageJoinRequests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubMembersViewModelProvider.notifier).loadForClub(widget.club.clubId);
    });
  }

  void _onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      if (_canManageJoinRequests && _tabController!.index == 2) {
        ref.read(clubContextViewModelProvider.notifier).switchClub(widget.club.clubId);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ClubDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.clubId != widget.club.clubId) {
      ref.read(clubMembersViewModelProvider.notifier).loadForClub(widget.club.clubId);
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _copyClubCode(BuildContext context) {
    if (widget.club.clubCode.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: widget.club.clubCode));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã sao chép mã nhóm: ${widget.club.clubCode}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final membersState = ref.watch(clubMembersViewModelProvider);
    final membersVm = ref.read(clubMembersViewModelProvider.notifier);
    final contextVm = ref.read(clubContextViewModelProvider.notifier);
    final activeContext = ref.watch(activeClubContextProvider);

    // Dynamic RBAC without hardcoded Vietnamese role strings
    final isHost = activeContext?.role == ClubRole.host || widget.club.role == ClubRole.host;
    final canManageJoinRequests = isHost || ref.hasClubPermission('MEMBER.JOIN_REQUEST.MANAGE');
    _canManageJoinRequests = canManageJoinRequests;

    final expectedLength = canManageJoinRequests ? 4 : 3;
    if (_tabController == null || _tabController!.length != expectedLength) {
      _tabController?.removeListener(_onTabChanged);
      _tabController?.dispose();
      _tabController = TabController(length: expectedLength, vsync: this);
      _tabController!.addListener(_onTabChanged);
    }

    return Column(
      children: [
        // 1. Club Header Banner (Discord Style)
        _buildClubHeader(context, contextVm),

        // 2. Tab Bar
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.cardBorder)),
          ),
          child: TabBar(
            controller: _tabController!,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: colors.primary,
            unselectedLabelColor: colors.textMuted,
            indicatorColor: colors.primary,
            indicatorWeight: 3,
            tabs: [
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: AppSpacing.iconSm),
                    AppSpacing.gapW8,
                    Text('Buổi tập'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_outlined, size: AppSpacing.iconSm),
                    AppSpacing.gapW8,
                    Text('Thành viên (${membersState.members.length})'),
                  ],
                ),
              ),
              if (canManageJoinRequests)
                const Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.how_to_reg_outlined, size: AppSpacing.iconSm),
                      AppSpacing.gapW8,
                      Text('Duyệt đơn'),
                    ],
                  ),
                ),
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded, size: AppSpacing.iconSm),
                    AppSpacing.gapW8,
                    Text('Thông tin & Lịch'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController!,
            children: [
              // Tab 1: Sessions (FR13)
              ClubSessionsTab(
                clubId: widget.club.clubId,
                clubName: widget.club.clubName,
                isHost: isHost,
              ),

              // Tab 2: Member List (Discord Roles)
              membersState.isLoading
                  ? Center(child: CircularProgressIndicator(color: colors.primary))
                  : ClubMemberSection(
                      members: membersState.members,
                      isHost: isHost,
                      vm: membersVm,
                    ),

              // Tab 3: Join Requests (Chỉ hiện khi có quyền duyệt)
              if (canManageJoinRequests)
                ClubJoinRequestsTab(clubId: widget.club.clubId),

              // Tab 4: Overview & Schedules (FR07, FR13)
              ClubOverviewTab(
                clubId: widget.club.clubId,
                clubCode: widget.club.clubCode,
                userRole: widget.club.role,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClubHeader(BuildContext context, ClubContextViewModel contextVm) {
    final colors = context.colors;
    final roleColor = _getRoleColor(widget.club.role);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDark ? colors.surface : colors.primaryContainer.withValues(alpha: 0.35),
        border: Border(bottom: BorderSide(color: colors.cardBorder)),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.2),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3), width: 1.5),
                  image: widget.club.avatarUrl != null && widget.club.avatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.club.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.club.avatarUrl == null || widget.club.avatarUrl!.isEmpty
                    ? Center(
                        child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 28),
                      )
                    : null,
              ),
              AppSpacing.gapW12,

              // Name + Role Badge
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.club.clubName,
                      style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapH4,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.2),
                            borderRadius: AppRadius.tag,
                            border: Border.all(color: roleColor.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            (widget.club.roleName != null && widget.club.roleName!.isNotEmpty)
                                ? widget.club.roleName!
                                : widget.club.role.displayName,
                            style: AppTypography.labelSmall.bold.colored(roleColor),
                          ),
                        ),

                        // Active Context Pill
                        if (widget.isActiveContext)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              borderRadius: AppRadius.tag,
                              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: colors.primary, size: 12),
                                AppSpacing.gapW4,
                                Text(
                                  'Đang kích hoạt',
                                  style: AppTypography.labelSmall.bold.colored(colors.primary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action Row: Copy Club Code & View QR
          if (widget.club.clubCode.isNotEmpty) ...[
            AppSpacing.gapH12,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.cardBorder),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: Icon(Icons.copy_rounded, size: AppSpacing.iconXs, color: colors.textSecondary),
                    label: Text('Mã nhóm: ${widget.club.clubCode}', style: AppTypography.bodySmall.colored(colors.textPrimary)),
                    onPressed: () => _copyClubCode(context),
                  ),
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
                  label: Text('Mã QR', style: AppTypography.bodySmall.bold.colored(colors.primary)),
                  onPressed: () => ClubQrDialog.show(
                    context: context,
                    clubName: widget.club.clubName,
                    clubCode: widget.club.clubCode,
                    avatarUrl: widget.club.avatarUrl,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor(ClubRole role) {
    switch (role) {
      case ClubRole.host:
        return AppColors.roleHost;
      case ClubRole.deputy:
        return AppColors.roleDeputy;
      case ClubRole.treasurer:
        return AppColors.roleTreasurer;
      case ClubRole.member:
        return AppColors.roleMember;
      case ClubRole.guest:
        return AppColors.roleGuest;
    }
  }
}
