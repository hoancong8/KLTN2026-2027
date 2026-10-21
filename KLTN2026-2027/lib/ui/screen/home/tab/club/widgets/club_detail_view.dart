// lib/ui/screen/home/tab/club/widgets/club_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../domain/entities/club/my_club.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';
import '../../../../club/club_vm/club_context_vm.dart';
import 'club_join_requests_tab.dart';
import 'club_member_section.dart';
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
    final membersState = ref.watch(clubMembersViewModelProvider);
    final membersVm = ref.read(clubMembersViewModelProvider.notifier);
    final contextVm = ref.read(clubContextViewModelProvider.notifier);
    final isHost = widget.club.role == ClubRole.host ||
        (widget.club.roleName?.toLowerCase().contains('host') ?? false);
    final isDeputy = widget.club.role == ClubRole.deputy ||
        (widget.club.roleName?.toLowerCase().contains('phó') ?? false);
    final canManageJoinRequests = isHost || isDeputy ||
        ref.watch(hasPermissionProvider('MEMBER.JOIN_REQUEST.MANAGE'));
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
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController!,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
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
                    Icon(Icons.share_outlined, size: AppSpacing.iconSm),
                    AppSpacing.gapW8,
                    Text('Thông tin & Mời'),
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
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ClubMemberSection(
                      members: membersState.members,
                      isHost: isHost,
                      vm: membersVm,
                    ),

              // Tab 3: Join Requests (Chỉ hiện khi có quyền duyệt)
              if (canManageJoinRequests)
                ClubJoinRequestsTab(clubId: widget.club.clubId),

              // Tab 4: Invite Friends & About
              _buildInviteAndAboutTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClubHeader(BuildContext context, ClubContextViewModel contextVm) {
    final roleColor = _getRoleColor(widget.club.role);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neutral800,
            AppColors.neutral900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Column(
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
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.2), width: 1.5),
                  image: widget.club.avatarUrl != null && widget.club.avatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.club.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.club.avatarUrl == null || widget.club.avatarUrl!.isEmpty
                    ? const Center(
                        child: Icon(Icons.sports_tennis_rounded, color: AppColors.primaryLight, size: 28),
                      )
                    : null,
              ),
              AppSpacing.gapW12,

              // Name + Role Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.club.clubName,
                      style: AppTypography.titleMedium.bold.colored(AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapH4,
                    Row(
                      children: [
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.25),
                            borderRadius: AppRadius.tag,
                            border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Text(
                            (widget.club.roleName != null && widget.club.roleName!.isNotEmpty)
                                ? widget.club.roleName!
                                : widget.club.role.displayName,
                            style: AppTypography.labelSmall.bold.colored(roleColor),
                          ),
                        ),
                        AppSpacing.gapW8,

                        // Active Context Pill
                        if (widget.isActiveContext)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: AppRadius.tag,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 12),
                                AppSpacing.gapW4,
                                Text(
                                  'Đang kích hoạt',
                                  style: AppTypography.labelSmall.bold.colored(AppColors.primaryLight),
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

          // Action Row: Copy Club Code
          if (widget.club.clubCode.isNotEmpty) ...[
            AppSpacing.gapH12,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: BorderSide(color: AppColors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: AppSpacing.iconXs),
                    label: Text('Mã nhóm: ${widget.club.clubCode}', style: AppTypography.bodySmall.colored(AppColors.white)),
                    onPressed: () => _copyClubCode(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteAndAboutTab(BuildContext context) {
    final code = widget.club.clubCode.isNotEmpty ? widget.club.clubCode : 'CHƯA CÓ';

    return ListView(
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
                          'Chia sẻ mã này để bạn bè tham gia ngay',
                          style: AppTypography.bodySmall.colored(AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH12,

              // Big Code Box
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
                      onPressed: () => _copyClubCode(context),
                    ),
                  ],
                ),
              ),

              AppSpacing.gapH12,
              Text(
                'Hướng dẫn: Bạn bè chỉ cần mở ứng dụng -> vào "Nhóm của tôi" -> bấm biểu tượng (+) -> chọn "Tham gia bằng Code" và dán mã này vào là xong!',
                style: AppTypography.bodySmall.colored(AppColors.roleTeal),
              ),
            ],
          ),
        ),

        AppSpacing.gapH16,

        // 2. Club Info Card
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
                'Thông tin câu lạc bộ',
                style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
              ),
              AppSpacing.gapH12,
              _buildInfoRow('Tên nhóm', widget.club.clubName),
              const Divider(height: AppSpacing.base),
              _buildInfoRow('Mã mời tham gia', code),
              const Divider(height: AppSpacing.base),
              _buildInfoRow('Vai trò của bạn', widget.club.role.displayName),
              const Divider(height: AppSpacing.base),
              _buildInfoRow(
                'Ngày tham gia',
                widget.club.joinedAt != null
                    ? '${widget.club.joinedAt!.day.toString().padLeft(2, "0")}/${widget.club.joinedAt!.month.toString().padLeft(2, "0")}/${widget.club.joinedAt!.year}'
                    : 'Chưa xác định',
              ),
              if (widget.club.description != null && widget.club.description!.isNotEmpty) ...[
                const Divider(height: AppSpacing.base),
                _buildInfoRow('Mô tả', widget.club.description!),
              ],
              AppSpacing.gapH20,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: AppSpacing.verticalMd,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: AppSpacing.iconSm),
                  label: Text(
                    'Hồ Sơ Chi Tiết & Lịch Tuần CLB',
                    style: AppTypography.labelLarge.bold.colored(AppColors.onPrimary),
                  ),
                  onPressed: () {
                    context.push(AppConfig.clubDetailRoutePath(widget.club.clubId));
                  },
                ),
              ),
              AppSpacing.gapH12,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
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
                  onPressed: () {
                    context.push(AppConfig.myBookingsRoutePath);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTypography.bodySmall.colored(AppColors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.semiBold.colored(AppColors.textPrimary),
          ),
        ),
      ],
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
