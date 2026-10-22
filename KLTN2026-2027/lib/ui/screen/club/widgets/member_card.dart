// lib/ui/screen/club/widgets/member_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../domain/entities/club/club_member.dart';
import '../../../../domain/enums/club_role.dart';
import '../club_management_vm/club_members_vm.dart';
import '../club_vm/club_context_vm.dart';

class MemberCard extends ConsumerWidget {
  final ClubMember member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final clubContext = ref.watch(clubContextViewModelProvider);
    final vm = ref.read(clubMembersViewModelProvider.notifier);
    final isHost = clubContext.isCurrentHost;
    final initials = (member.userName?.isNotEmpty == true)
        ? member.userName!.substring(0, 1).toUpperCase()
        : 'U';

    final roleColor = _getRoleColor(member.role);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Initials
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withAlpha(30),
            child: Text(
              initials,
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.userName ?? 'Thành viên',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: roleColor.withAlpha(80)),
                      ),
                      child: Text(
                        member.role.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                if (member.nickname != null && member.nickname!.isNotEmpty)
                  Text(
                    'Biệt danh: ${member.nickname}',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                if (member.email != null && member.email!.isNotEmpty)
                  Text(
                    member.email!,
                    style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Actions for Host
          if (isHost && member.role != ClubRole.host)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colors.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'role') {
                  _showChangeRoleDialog(context, vm, member);
                } else if (val == 'remove') {
                  _showRemoveConfirmDialog(context, vm, member);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Đổi vai trò', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_outlined, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Xóa khỏi nhóm', style: TextStyle(fontSize: 13, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, ClubMembersViewModel vm, ClubMember m) {
    ClubRole selected = m.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Đổi vai trò: ${m.userName ?? ""}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chọn vai trò mới cho thành viên:', style: TextStyle(fontSize: 13, color: context.colors.textMuted)),
              const SizedBox(height: 12),
              ...ClubRole.values.where((r) => r != ClubRole.host).map((role) {
                return RadioListTile<ClubRole>(
                  dense: true,
                  title: Text(role.displayName, style: const TextStyle(fontSize: 13.5)),
                  value: role,
                  // ignore: deprecated_member_use
                  groupValue: selected,
                  activeColor: AppColors.primary,
                  // ignore: deprecated_member_use
                  onChanged: (val) {
                    if (val != null) setState(() => selected = val);
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await vm.updateRole(m.userId, selected);
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmDialog(BuildContext context, ClubMembersViewModel vm, ClubMember m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa thành viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa "${m.userName ?? "thành viên"}" ra khỏi câu lạc bộ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await vm.removeMember(m.userId);
            },
            child: const Text('Xóa'),
          ),
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
        return AppColors.success;
      case ClubRole.guest:
        return AppColors.roleGuest;
    }
  }
}
