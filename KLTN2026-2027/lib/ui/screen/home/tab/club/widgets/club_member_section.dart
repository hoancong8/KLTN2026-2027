// lib/ui/screen/home/tab/club/widgets/club_member_section.dart

import 'package:flutter/material.dart';
import '../../../../../../app/consts/app_color.dart';
import '../../../../../../domain/entities/club/club_member.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';

class ClubMemberSection extends StatefulWidget {
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
  State<ClubMemberSection> createState() => _ClubMemberSectionState();
}

class _ClubMemberSectionState extends State<ClubMemberSection> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.members.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return (m.userName?.toLowerCase().contains(q) ?? false) ||
          (m.nickname?.toLowerCase().contains(q) ?? false) ||
          (m.email?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Phân nhóm theo vai trò chuẩn Discord
    final hosts = filtered.where((m) => m.role == ClubRole.host).toList();
    final treasurers = filtered.where((m) => m.role == ClubRole.treasurer).toList();
    final members = filtered.where((m) => m.role == ClubRole.member).toList();
    final guests = filtered.where((m) => m.role == ClubRole.guest).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thành viên...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColor.cMuted),
              filled: true,
              fillColor: const Color(0xFFF2F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),

        // Discord Roles List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy thành viên phù hợp',
                    style: TextStyle(color: AppColor.cMuted, fontSize: 13),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    if (hosts.isNotEmpty) _buildRoleGroup('👑 CHỦ CÂU LẠC BỘ', hosts, const Color(0xFF9333EA)),
                    if (treasurers.isNotEmpty) _buildRoleGroup('💰 THỦ QUỸ', treasurers, const Color(0xFFD97706)),
                    if (members.isNotEmpty) _buildRoleGroup('🏸 THÀNH VIÊN CHÍNH THỨC', members, AppColor.cMain),
                    if (guests.isNotEmpty) _buildRoleGroup('👤 KHÁCH VÃNG LAI', guests, const Color(0xFF6B7280)),
                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRoleGroup(String title, List<ClubMember> groupMembers, Color roleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            '$title — ${groupMembers.length}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: roleColor,
              letterSpacing: 0.6,
            ),
          ),
        ),
        ...groupMembers.map((m) => _buildMemberTile(m, roleColor)),
      ],
    );
  }

  Widget _buildMemberTile(ClubMember m, Color roleColor) {
    final displayName = m.nickname != null && m.nickname!.isNotEmpty
        ? '${m.userName ?? "Thành viên"} (${m.nickname})'
        : m.userName ?? 'Thành viên';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: roleColor.withValues(alpha: 0.15),
            child: Text(
              m.userName != null && m.userName!.isNotEmpty
                  ? m.userName![0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),

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
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColor.cTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (m.role == ClubRole.host) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFF9333EA)),
                    ],
                  ],
                ),
                Text(
                  m.email ?? 'Thành viên nhóm',
                  style: const TextStyle(fontSize: 11.5, color: AppColor.cMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              m.role.displayName,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),

          // Actions for Host
          if (widget.isHost && m.role != ClubRole.host)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: AppColor.cMuted),
              onSelected: (val) {
                if (val == 'role') {
                  _showUpdateRoleDialog(m);
                } else if (val == 'remove') {
                  _showRemoveDialog(m);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: AppColor.cMain),
                      SizedBox(width: 8),
                      Text('Đổi vai trò', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_outlined, size: 16, color: AppColor.cAlert),
                      SizedBox(width: 8),
                      Text('Xóa khỏi nhóm', style: TextStyle(fontSize: 13, color: AppColor.cAlert)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Phân quyền: ${m.userName ?? "Thành viên"}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ClubRole.values.where((r) => r != ClubRole.host).map((role) {
              final isChecked = selected == role;
              return ListTile(
                dense: true,
                title: Text(role.displayName, style: const TextStyle(fontSize: 13.5)),
                leading: Icon(
                  isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isChecked ? AppColor.cMain : AppColor.cMuted,
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
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cMain,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await widget.vm.updateRole(m.userId, selected);
              },
              child: const Text('Lưu thay đổi'),
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
              backgroundColor: AppColor.cAlert,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.vm.removeMember(m.userId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
