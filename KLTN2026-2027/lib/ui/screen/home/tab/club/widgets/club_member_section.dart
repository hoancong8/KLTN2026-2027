// lib/ui/screen/home/tab/club/widgets/club_member_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../domain/entities/club/club_member.dart';
import '../../../../../../domain/entities/user_profile.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';
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
    final currentProfile = ref.watch(currentUserProfileProvider);

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
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thành viên...',
              hintStyle: AppTypography.bodyMedium.colored(AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: AppSpacing.iconSm, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.borderMd,
                borderSide: BorderSide.none,
              ),
              contentPadding: AppSpacing.verticalSm,
            ),
          ),
        ),

        // Host Only: Role & Permissions Management Card
        if (widget.isHost)
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
                  boxShadow: AppShadows.md,
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
                            'Vai trò & Phân quyền nhóm (FR03)',
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
                    style: AppTypography.bodyMedium.colored(AppColors.textMuted),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                  children: [
                    if (hosts.isNotEmpty) _buildRoleGroup('CHỦ CÂU LẠC BỘ', hosts, AppColors.roleHost, currentProfile),
                    if (deputies.isNotEmpty) _buildRoleGroup('PHÓ NHÓM', deputies, AppColors.roleDeputy, currentProfile),
                    if (treasurers.isNotEmpty) _buildRoleGroup('THỦ QUỸ', treasurers, AppColors.roleTreasurer, currentProfile),
                    ...customGroups.entries.map(
                      (e) => _buildRoleGroup(e.key.toUpperCase(), e.value, AppColors.roleTeal, currentProfile),
                    ),
                    if (regularMembers.isNotEmpty) _buildRoleGroup('THÀNH VIÊN CHÍNH THỨC', regularMembers, AppColors.primary, currentProfile),
                    if (guests.isNotEmpty) _buildRoleGroup('KHÁCH VÃNG LAI', guests, AppColors.roleGuest, currentProfile),
                    AppSpacing.gapH16,
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRoleGroup(String title, List<ClubMember> groupMembers, Color roleColor, UserProfile? currentProfile) {
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
        ...groupMembers.map((m) => _buildMemberTile(m, roleColor, currentProfile)),
      ],
    );
  }

  Widget _buildMemberTile(ClubMember m, Color roleColor, UserProfile? currentProfile) {
    final isMe = _checkIsMe(m, currentProfile);

    final displayName = m.nickname != null && m.nickname!.isNotEmpty
        ? '${m.userName ?? "Thành viên"} (${m.nickname})'
        : m.userName ?? 'Thành viên';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.5),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.5),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isMe ? AppColors.primary.withValues(alpha: 0.6) : AppColors.border,
          width: isMe ? 1.5 : 1.0,
        ),
        boxShadow: isMe ? AppShadows.sm : null,
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
                  border: isMe ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: isMe
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : roleColor.withValues(alpha: 0.15),
                  child: Text(
                    m.userName != null && m.userName!.isNotEmpty
                        ? m.userName![0].toUpperCase()
                        : 'U',
                    style: AppTypography.titleSmall.bold.colored(isMe ? AppColors.primary : roleColor),
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
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
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
                        style: AppTypography.bodyMedium.colored(
                          isMe ? AppColors.neutral900 : AppColors.textPrimary,
                        ).copyWith(fontWeight: isMe ? FontWeight.w700 : FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      AppSpacing.gapW8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.success, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppRadius.tag,
                          boxShadow: AppShadows.sm,
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
                  isMe ? '${m.email ?? "Thành viên"} • (Tài khoản của bạn)' : (m.email ?? 'Thành viên nhóm'),
                  style: AppTypography.bodySmall.colored(
                    isMe ? AppColors.primary : AppColors.textMuted,
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

          // Actions for Host (chỉ hiện cho thành viên khác, không hiện cho chính mình)
          if (widget.isHost && m.role != ClubRole.host && !isMe)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: AppSpacing.iconSm, color: AppColors.textMuted),
              onSelected: (val) {
                if (val == 'role') {
                  _showUpdateRoleDialog(m);
                } else if (val == 'remove') {
                  _showRemoveDialog(m);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      AppSpacing.gapW8,
                      Text('Đổi vai trò', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      const Icon(Icons.person_remove_outlined, size: 16, color: AppColors.error),
                      AppSpacing.gapW8,
                      Text('Xóa khỏi nhóm', style: AppTypography.bodyMedium.colored(AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showUpdateRoleDialog(ClubMember m) {
    ClubRole selected = m.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
          title: Text(
            'Phân quyền: ${m.userName ?? "Thành viên"}',
            style: AppTypography.titleMedium.bold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ClubRole.values.where((r) => r != ClubRole.host).map((role) {
              final isChecked = selected == role;
              return ListTile(
                dense: true,
                title: Text(role.displayName, style: AppTypography.bodyMedium),
                leading: Icon(
                  isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isChecked ? AppColors.primary : AppColors.textMuted,
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
              child: Text('Hủy', style: AppTypography.labelLarge.colored(AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.vm.updateRole(m.userId, selected);
              },
              child: Text('Lưu thay đổi', style: AppTypography.labelLarge.bold.colored(AppColors.onPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(ClubMember m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text('Xác nhận xóa thành viên', style: AppTypography.titleMedium.bold),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${m.userName ?? "thành viên"}" ra khỏi câu lạc bộ?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.vm.removeMember(m.userId);
            },
            child: Text('Xóa', style: AppTypography.labelLarge.bold.colored(AppColors.onError)),
          ),
        ],
      ),
    );
  }
}
