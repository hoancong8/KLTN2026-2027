// lib/ui/screen/home/tab/club/widgets/club_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_color.dart';
import '../../../../../../app/consts/app_config.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubMembersViewModelProvider.notifier).loadForClub(widget.club.clubId);
    });
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
    _tabController.dispose();
    super.dispose();
  }

  void _copyClubCode(BuildContext context) {
    if (widget.club.clubCode.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: widget.club.clubCode));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã sao chép mã nhóm: ${widget.club.clubCode}'),
          backgroundColor: AppColor.cMain,
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

    return Column(
      children: [
        // 1. Club Header Banner (Discord Style)
        _buildClubHeader(context, contextVm),

        // 2. Tab Bar
        Container(
          color: AppColor.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.cMain,
            unselectedLabelColor: AppColor.cMuted,
            indicatorColor: AppColor.cMain,
            indicatorWeight: 3,
            tabs: [
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Buổi tập'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Thành viên (${membersState.members.length})'),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.how_to_reg_outlined, size: 18),
                    SizedBox(width: 6),
                    Text('Duyệt đơn'),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_outlined, size: 18),
                    SizedBox(width: 6),
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
            controller: _tabController,
            children: [
              // Tab 1: Sessions (FR13)
              ClubSessionsTab(
                clubId: widget.club.clubId,
                clubName: widget.club.clubName,
                isHost: isHost,
              ),

              // Tab 2: Member List (Discord Roles)
              membersState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
                  : ClubMemberSection(
                      members: membersState.members,
                      isHost: isHost,
                      vm: membersVm,
                    ),

              // Tab 3: Join Requests
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  color: AppColor.cMain.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  image: widget.club.avatarUrl != null && widget.club.avatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.club.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.club.avatarUrl == null || widget.club.avatarUrl!.isEmpty
                    ? const Center(
                        child: Icon(Icons.sports_tennis_rounded, color: AppColor.cGreen_50, size: 28),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name + Role Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.club.clubName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Text(
                            (widget.club.roleName != null && widget.club.roleName!.isNotEmpty)
                                ? widget.club.roleName!
                                : widget.club.role.displayName,
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Active Context Pill
                        if (widget.isActiveContext)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColor.cGreen_50.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColor.cGreen_50, size: 12),
                                SizedBox(width: 3),
                                Text(
                                  'Đang kích hoạt',
                                  style: TextStyle(
                                    color: AppColor.cGreen_50,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
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
            ],
          ),

          const SizedBox(height: 12),

          // Actions Row: Switch Context + Copy Code
          Row(
            children: [
              // Switch Context Button (nếu chưa kích hoạt)
              if (!widget.isActiveContext)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text('Kích hoạt nhóm này', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final success = await contextVm.switchClub(widget.club.clubId);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã kích hoạt nhóm ${widget.club.clubName} làm ngữ cảnh chính!'),
                            backgroundColor: AppColor.cMain,
                          ),
                        );
                      }
                    },
                  ),
                )
              else
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '✓ Ngữ cảnh hoạt động hiện tại',
                        style: TextStyle(color: AppColor.cGreen_50, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // Copy Code Button
              if (widget.club.clubCode.isNotEmpty)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: Text('Mã: ${widget.club.clubCode}', style: const TextStyle(fontSize: 12)),
                  onPressed: () => _copyClubCode(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteAndAboutTab(BuildContext context) {
    final code = widget.club.clubCode.isNotEmpty ? widget.club.clubCode : 'CHƯA CÓ';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Invite Friends Card (Discord Style)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF8F4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.cMain.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.cMain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mời bạn bè vào nhóm',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColor.cTitle,
                          ),
                        ),
                        Text(
                          'Chia sẻ mã này để bạn bè tham gia ngay',
                          style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Big Code Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.cDivider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tag_rounded, color: AppColor.cMain, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColor.cTitle,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cMain,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('Sao chép', style: TextStyle(fontSize: 12)),
                      onPressed: () => _copyClubCode(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                '💡 Hướng dẫn: Bạn bè chỉ cần mở ứng dụng -> vào "Nhóm của tôi" -> bấm biểu tượng (+) -> chọn "Tham gia bằng Code" và dán mã này vào là xong!',
                style: TextStyle(fontSize: 12, color: Color(0xFF0F766E), height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Club Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColor.cDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin câu lạc bộ',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColor.cTitle),
              ),
              const SizedBox(height: 10),
              _buildInfoRow('Tên nhóm', widget.club.clubName),
              const Divider(height: 16),
              _buildInfoRow('Mã mời tham gia', code),
              const Divider(height: 16),
              _buildInfoRow('Vai trò của bạn', widget.club.role.displayName),
              const Divider(height: 16),
              _buildInfoRow(
                'Ngày tham gia',
                widget.club.joinedAt != null
                    ? '${widget.club.joinedAt!.day.toString().padLeft(2, "0")}/${widget.club.joinedAt!.month.toString().padLeft(2, "0")}/${widget.club.joinedAt!.year}'
                    : 'Chưa xác định',
              ),
              if (widget.club.description != null && widget.club.description!.isNotEmpty) ...[
                const Divider(height: 16),
                _buildInfoRow('Mô tả', widget.club.description!),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cMain,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text(
                    'Hồ Sơ Chi Tiết & Lịch Tuần CLB',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  onPressed: () {
                    context.push(AppConfig.clubDetailRoutePath(widget.club.clubId));
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.cMain,
                    side: const BorderSide(color: AppColor.cMain, width: 1.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.event_available_rounded, size: 18),
                  label: const Text(
                    'Lịch Tôi Đã Đăng Ký (Vé & Điểm Danh)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
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
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppColor.cMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(ClubRole role) {
    switch (role) {
      case ClubRole.host:
        return const Color(0xFFC084FC); // Light Purple
      case ClubRole.deputy:
        return const Color(0xFF60A5FA); // Light Blue
      case ClubRole.treasurer:
        return const Color(0xFFFBBF24); // Light Amber
      case ClubRole.member:
        return AppColor.cGreen_50; // Green
      case ClubRole.guest:
        return const Color(0xFF9CA3AF); // Gray
    }
  }
}
