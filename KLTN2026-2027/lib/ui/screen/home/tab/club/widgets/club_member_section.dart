// lib/ui/screen/home/tab/club/widgets/club_member_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../domain/entities/club/club_member.dart';
import '../../../../../../domain/entities/user_profile.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';
import '../../../../club/club_vm/club_context_vm.dart';
import '../../../../club/role_management/club_role_management_screen.dart';

class ClubMemberSection extends ConsumerStatefulWidget {
  final List<ClubMember> members;
  final bool isHost;
  final ClubMembersViewModel vm;

  const ClubMemberSection({
    super.key,
    required this.members,
    required this.isHost,
    required this.vm,
  });

  @override
  ConsumerState<ClubMemberSection> createState() => _ClubMemberSectionState();
}

class _ClubMemberSectionState extends ConsumerState<ClubMemberSection> {
  String _searchQuery = '';

  bool _checkIsMe(ClubMember m, UserProfile? profile) {
    if (profile == null) return false;
    final profileId = profile.id.trim().toLowerCase();
    final memberUserId = m.userId.trim().toLowerCase();
    final memberId = m.id.trim().toLowerCase();

    if (profileId.isNotEmpty && (memberUserId == profileId || memberId == profileId)) {
      return true;
    }

    final profileEmail = profile.email.trim().toLowerCase();
    final memberEmail = m.email?.trim().toLowerCase();
    if (profileEmail.isNotEmpty && memberEmail != null && memberEmail == profileEmail) {
      return true;
    }

    final profileUserName = profile.userName.trim().toLowerCase();
    final memberUserName = m.userName?.trim().toLowerCase();
    if (profileUserName.isNotEmpty && memberUserName != null && memberUserName == profileUserName) {
      return true;
    }

    return false;
  }

  List<ClubMember> _sortGroup(List<ClubMember> list, UserProfile? profile) {
    final copy = List<ClubMember>.from(list);
    copy.sort((a, b) {
      final aMe = _checkIsMe(a, profile);
      final bMe = _checkIsMe(b, profile);
      if (aMe && !bMe) return -1;
      if (!aMe && bMe) return 1;
      return (a.userName ?? '').compareTo(b.userName ?? '');
    });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentProfile = ref.watch(currentUserProfileProvider);
    final activeContext = ref.watch(activeClubContextProvider);

    // Dynamic RBAC with strict Context Isolation
    final isSameClub = activeContext?.clubId == widget.vm.clubId;
    final isHost = widget.isHost || (isSameClub && activeContext?.role == ClubRole.host);
    final canManageRoles = isHost || (isSameClub && ref.hasClubPermission('MEMBER.ROLE.MANAGE'));
    final canRemoveMember = isHost || (isSameClub && ref.hasClubPermission('MEMBER.REMOVE'));

    final filtered = widget.members.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return (m.userName?.toLowerCase().contains(q) ?? false) ||
          (m.nickname?.toLowerCase().contains(q) ?? false) ||
          (m.email?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Phân nhóm theo vai trò chuẩn Discord và ưu tiên đưa tài khoản của mình lên đầu mỗi nhóm
    final hosts = _sortGroup(filtered.where((m) => m.role == ClubRole.host).toList(), currentProfile);
    final deputies = _sortGroup(filtered.where((m) => m.role == ClubRole.deputy).toList(), currentProfile);
    final treasurers = _sortGroup(filtered.where((m) => m.role == ClubRole.treasurer).toList(), currentProfile);
    final guests = _sortGroup(filtered.where((m) => m.role == ClubRole.guest).toList(), currentProfile);

    // Thành viên thông thường
    final regularMembers = _sortGroup(filtered.where((m) {
      if (m.role != ClubRole.member) return false;
      final rn = m.roleName?.trim().toLowerCase();
      return rn == null || rn.isEmpty || rn == 'thành viên' || rn == 'member' || rn == 'hội viên';
    }).toList(), currentProfile);

    // Các vai trò tùy chỉnh khác do CLB tạo (ví dụ: Trọng tài, Cố vấn, Trưởng ban...)
    final customRoleMembers = filtered.where((m) {
      if (m.role != ClubRole.member) return false;
      final rn = m.roleName?.trim().toLowerCase();
      return rn != null && rn.isNotEmpty && rn != 'thành viên' && rn != 'member' && rn != 'hội viên';
    }).toList();

    final Map<String, List<ClubMember>> customGroups = {};
    for (final m in customRoleMembers) {
      final key = m.roleName!.trim();
      customGroups.putIfAbsent(key, () => []).add(m);
    }
    // Sort từng group custom
    for (final key in customGroups.keys) {
      customGroups[key] = _sortGroup(customGroups[key]!, currentProfile);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: AppTypography.bodyMedium.colored(colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thành viên...',
              hintStyle: AppTypography.bodyMedium.colored(colors.textMuted),
              prefixIcon: Icon(Icons.search, size: AppSpacing.iconSm, color: colors.textMuted),
              filled: true,
              fillColor: colors.inputFill,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: AppSpacing.verticalSm,
            ),
          ),
        ),

        // Role & Permissions Management Card (Host & Manager)
        if (canManageRoles)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
            child: InkWell(
              onTap: () => ClubRoleManagementScreen.show(context, clubId: widget.vm.clubId),
              borderRadius: AppRadius.card,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.roleViolet, AppColors.roleHost],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.card,
                  boxShadow: context.isDark ? AppShadows.none : AppShadows.md,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: AppColors.white, size: 22),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vai trò & Phân quyền nhóm',
                            style: AppTypography.titleSmall.bold.colored(AppColors.white),
                          ),
                          Text(
                            'Cấu hình quyền hạn (Vận hành, Thu chi, Thành viên) cho từng vai trò',
                            style: AppTypography.bodySmall.colored(AppColors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: AppSpacing.iconXs),
                  ],
                ),
              ),
            ),
          ),

        // Discord Roles List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'Không tìm thấy thành viên phù hợp',
                    style: AppTypography.bodyMedium.colored(colors.textMuted),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                  children: [
                    if (hosts.isNotEmpty) _buildRoleGroup(context, 'CHỦ CÂU LẠC BỘ', hosts, AppColors.roleHost, currentProfile, canManageRoles: canManageRoles, canRemoveMember: canRemoveMember),
                    if (deputies.isNotEmpty) _buildRoleGroup(context, 'PHÓ NHÓM', deputies, AppColors.roleDeputy, currentProfile, canManageRoles: canManageRoles, canRemoveMember: canRemoveMember),
                    if (treasurers.isNotEmpty) _buildRoleGroup(context, 'THỦ QUỸ', treasurers, AppColors.roleTreasurer, currentProfile, canManageRoles: canManageRoles, canRemoveMember: canRemoveMember),
                    ...customGroups.entries.map(
                      (e) => _buildRoleGroup(context, e.key.toUpperCase(), e.value, AppColors.roleTeal, currentProfile, canManageRoles: canManageRoles, canRemoveMember: canRemoveMember),
                    ),
                    if (regularMembers.isNotEmpty) _buildRoleGroup(context, 'THÀNH VIÊN CHÍNH THỨC', regularMembers, colors.primary, currentProfile, canManageRoles: canManageRoles, canRemoveMember: canRemoveMember),
                    if (guests.isNotEmpty) _buildRoleGroup(context, 'KHÁCH VÃNG LAI', guests, AppColors.roleGuest, currentProfile, canManageRoles: canManageRoles, canRemoveMember: canRemoveMember),
                    AppSpacing.gapH16,
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRoleGroup(
    BuildContext context,
    String title,
    List<ClubMember> groupMembers,
    Color roleColor,
    UserProfile? currentProfile, {
    required bool canManageRoles,
    required bool canRemoveMember,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            '$title — ${groupMembers.length}',
            style: AppTypography.labelSmall.bold.colored(roleColor).copyWith(letterSpacing: 0.6),
          ),
        ),
        ...groupMembers.map((m) => _buildMemberTile(
              context,
              m,
              roleColor,
              currentProfile,
              canManageRoles: canManageRoles,
              canRemoveMember: canRemoveMember,
            )),
      ],
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    ClubMember m,
    Color roleColor,
    UserProfile? currentProfile, {
    required bool canManageRoles,
    required bool canRemoveMember,
  }) {
    final colors = context.colors;
    final isMe = _checkIsMe(m, currentProfile);

    final displayName = m.nickname != null && m.nickname!.isNotEmpty
        ? '${m.userName ?? "Thành viên"} (${m.nickname})'
        : m.userName ?? 'Thành viên';

    return InkWell(
      onTap: () => _showMemberActionSheet(m, isMe, canManageRoles, canRemoveMember),
      borderRadius: AppRadius.borderMd,
      child: Container(
      margin: const EdgeInsets.symmetric(vertical: 3.5),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.5),
      decoration: BoxDecoration(
        color: isMe ? colors.primaryContainer.withValues(alpha: context.isDark ? 0.35 : 0.7) : colors.cardBackground,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isMe ? colors.primary.withValues(alpha: 0.6) : colors.cardBorder,
          width: isMe ? 1.5 : 1.0,
        ),
        boxShadow: isMe ? (context.isDark ? AppShadows.none : AppShadows.sm) : null,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isMe ? Border.all(color: colors.primary, width: 2) : null,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: isMe
                      ? colors.primary.withValues(alpha: 0.15)
                      : roleColor.withValues(alpha: 0.15),
                  child: Text(
                    m.userName != null && m.userName!.isNotEmpty
                        ? m.userName![0].toUpperCase()
                        : 'U',
                    style: AppTypography.titleSmall.bold.colored(isMe ? colors.primary : roleColor),
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.gapW12,

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: AppTypography.bodyMedium.colored(colors.textPrimary).copyWith(
                              fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      AppSpacing.gapW8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.success, colors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppRadius.tag,
                          boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_rounded, size: 10, color: AppColors.white),
                            AppSpacing.gapW4,
                            Text(
                              'Bạn',
                              style: AppTypography.labelSmall.bold.colored(AppColors.white).copyWith(fontSize: 9.5, letterSpacing: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (m.role == ClubRole.host) ...[
                      AppSpacing.gapW4,
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.roleHost),
                    ],
                  ],
                ),
                const SizedBox(height: 1.5),
                Text(
                  '${m.role == ClubRole.guest ? "Khách vãng lai" : (m.isMonthlyMember ? "Gói Tháng (Cố định)" : "Đóng theo buổi")} • ${isMe ? "Tài khoản của bạn" : (m.email ?? "Thành viên")}',
                  style: AppTypography.bodySmall.colored(
                    isMe ? colors.primary : colors.textMuted,
                  ).copyWith(fontWeight: isMe ? FontWeight.w500 : FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.tag,
              border: Border.all(color: roleColor.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Text(
              (m.roleName != null && m.roleName!.isNotEmpty)
                  ? m.roleName!
                  : m.role.displayName,
              style: AppTypography.labelSmall.bold.colored(roleColor),
            ),
          ),

          if ((canManageRoles || canRemoveMember || isMe) && m.role != ClubRole.host) ...[
            AppSpacing.gapW4,
            IconButton(
              icon: Icon(Icons.more_horiz_rounded, size: 20, color: colors.textMuted),
              tooltip: 'Tùy chọn thành viên',
              onPressed: () => _showMemberActionSheet(m, isMe, canManageRoles, canRemoveMember),
            ),
          ],
        ],
      ),
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
        return context.colors.primary;
      case ClubRole.guest:
        return AppColors.roleGuest;
    }
  }

  void _showMemberActionSheet(ClubMember m, bool isMe, bool canManageRoles, bool canRemoveMember) {
    final colors = context.colors;
    final roleColor = _getRoleColor(m.role);
    final displayName = (m.nickname != null && m.nickname!.isNotEmpty) ? m.nickname! : (m.userName ?? 'Thành viên');

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: colors.borderStrong, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              AppSpacing.gapH16,
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: roleColor.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: AppTypography.titleLarge.bold.colored(roleColor),
                      ),
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
                        AppSpacing.gapH4,
                        Text(m.email ?? 'Thành viên câu lạc bộ', style: AppTypography.bodySmall.colored(colors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.tag,
                      border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      (m.roleName != null && m.roleName!.isNotEmpty) ? m.roleName! : m.role.displayName,
                      style: AppTypography.labelSmall.bold.colored(roleColor),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              const Divider(height: 1),
              AppSpacing.gapH12,

              if (canManageRoles && m.role != ClubRole.host && !isMe)
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: AppRadius.borderSm),
                    child: Icon(Icons.manage_accounts_rounded, color: colors.primary, size: 20),
                  ),
                  title: Text('Phân quyền / Đổi vai trò', style: AppTypography.bodyMedium.bold.colored(colors.textPrimary)),
                  subtitle: Text('Bổ nhiệm Host, Phó nhóm, Thủ quỹ hoặc Thành viên', style: AppTypography.labelSmall.colored(colors.textMuted)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showUpdateRoleDialog(m);
                  },
                ),
              if (canManageRoles && m.role != ClubRole.guest)
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.success.withValues(alpha: 0.1), borderRadius: AppRadius.borderSm),
                    child: Icon(Icons.card_membership_rounded, color: colors.success, size: 20),
                  ),
                  title: Text('Chuyển gói sinh hoạt (Tháng / Ngày)', style: AppTypography.bodyMedium.bold.colored(colors.textPrimary)),
                  subtitle: Text(
                    m.isMonthlyMember
                        ? 'Hiện tại: Hội viên Cố định (Gói Tháng - 0đ/buổi)'
                        : 'Hiện tại: Hội viên Đóng theo buổi (DAILY)',
                    style: AppTypography.labelSmall.colored(colors.textMuted),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showUpdateMemberFeePlanDialog(m);
                  },
                ),
              if (canRemoveMember && m.role != ClubRole.host && !isMe)
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.1), borderRadius: AppRadius.borderSm),
                    child: Icon(Icons.person_remove_rounded, color: colors.error, size: 20),
                  ),
                  title: Text('Xóa khỏi câu lạc bộ', style: AppTypography.bodyMedium.bold.colored(colors.error)),
                  subtitle: Text('Hủy tư cách thành viên của người này tại CLB', style: AppTypography.labelSmall.colored(colors.textMuted)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showRemoveDialog(m);
                  },
                ),
              if (isMe && m.role != ClubRole.host)
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.1), borderRadius: AppRadius.borderSm),
                    child: Icon(Icons.exit_to_app_rounded, color: colors.error, size: 20),
                  ),
                  title: Text('Rời khỏi câu lạc bộ', style: AppTypography.bodyMedium.bold.colored(colors.error)),
                  subtitle: Text('Rút lui khỏi danh sách thành viên của nhóm', style: AppTypography.labelSmall.colored(colors.textMuted)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showLeaveDialog(m);
                  },
                ),
              ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: colors.surfaceSubtle, borderRadius: AppRadius.borderSm),
                  child: Icon(Icons.copy_rounded, color: colors.textSecondary, size: 20),
                ),
                title: Text('Sao chép thông tin liên hệ', style: AppTypography.bodyMedium.colored(colors.textPrimary)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Clipboard.setData(ClipboardData(text: m.email ?? m.userName ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã sao chép thông tin liên hệ'),
                      backgroundColor: colors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateRoleDialog(ClubMember m) {
    final colors = context.colors;
    ClubRole selected = m.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
          title: Text(
            'Phân quyền: ${m.userName ?? "Thành viên"}',
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ClubRole.values.where((r) => r != ClubRole.host).map((role) {
              final isChecked = selected == role;
              return ListTile(
                dense: true,
                title: Text(role.displayName, style: AppTypography.bodyMedium.colored(colors.textPrimary)),
                leading: Icon(
                  isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isChecked ? colors.primary : colors.textMuted,
                  size: 20,
                ),
                onTap: () {
                  setDialogState(() => selected = role);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.vm.updateRole(m.userId, selected);
              },
              child: Text('Lưu thay đổi', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateMemberFeePlanDialog(ClubMember m) {
    final colors = context.colors;
    String selectedType = m.isMonthlyMember ? 'MONTHLY' : 'DAILY';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: colors.cardBackground,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
          title: Text(
            'Gói sinh hoạt: ${m.userName ?? "Thành viên"}',
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  selectedType == 'MONTHLY' ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selectedType == 'MONTHLY' ? colors.primary : colors.textMuted,
                ),
                title: Text('Hội viên Cố định (Gói Tháng)', style: AppTypography.bodyMedium.bold.colored(colors.textPrimary)),
                subtitle: Text(
                  'Đóng quỹ cố định đầu tháng. Khi tham gia các buổi sinh hoạt sẽ được tính 0đ/buổi.',
                  style: AppTypography.labelSmall.colored(colors.textMuted),
                ),
                onTap: () => setDialogState(() => selectedType = 'MONTHLY'),
              ),
              const Divider(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  selectedType == 'DAILY' ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selectedType == 'DAILY' ? colors.primary : colors.textMuted,
                ),
                title: Text('Hội viên Đóng theo buổi (DAILY)', style: AppTypography.bodyMedium.bold.colored(colors.textPrimary)),
                subtitle: Text(
                  'Tham gia buổi nào tính phí buổi đó theo biểu phí thành viên ngày (có áp dụng ưu đãi Nữ).',
                  style: AppTypography.labelSmall.colored(colors.textMuted),
                ),
                onTap: () => setDialogState(() => selectedType = 'DAILY'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.vm.updateMemberFeePlan(
                  m.userId,
                  memberType: selectedType,
                  monthlyExpiryDate: selectedType == 'MONTHLY'
                      ? DateTime.now().add(const Duration(days: 30))
                      : null,
                );
              },
              child: Text('Lưu gói', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(ClubMember m) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text('Xác nhận xóa thành viên', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${m.userName ?? "thành viên"}" ra khỏi câu lạc bộ?',
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
              await widget.vm.removeMember(m.userId);
            },
            child: Text('Xóa', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(ClubMember m) {
    final colors = context.colors;
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
              final ok = await widget.vm.removeMember(m.userId);
              if (ok && mounted) {
                ref.read(clubContextViewModelProvider.notifier).loadMyClubs();
              }
            },
            child: Text('Rời nhóm', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
        ],
      ),
    );
  }
}
