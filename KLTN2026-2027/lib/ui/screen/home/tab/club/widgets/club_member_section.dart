// lib/ui/screen/home/tab/club/widgets/club_member_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/consts/app_color.dart';
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

        // Host Only: Role & Permissions Management Card
        if (widget.isHost)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              onTap: () => ClubRoleManagementScreen.show(context, clubId: widget.vm.clubId),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vai trò & Phân quyền nhóm (FR03)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cấu hình quyền hạn (Vận hành, Thu chi, Thành viên) cho từng vai trò',
                            style: TextStyle(color: Colors.white70, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                  ],
                ),
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
                    if (hosts.isNotEmpty) _buildRoleGroup('👑 CHỦ CÂU LẠC BỘ', hosts, const Color(0xFF9333EA), currentProfile),
                    if (deputies.isNotEmpty) _buildRoleGroup('⭐ PHÓ NHÓM', deputies, const Color(0xFF2563EB), currentProfile),
                    if (treasurers.isNotEmpty) _buildRoleGroup('💰 THỦ QUỸ', treasurers, const Color(0xFFD97706), currentProfile),
                    ...customGroups.entries.map(
                      (e) => _buildRoleGroup('🎖️ ${e.key.toUpperCase()}', e.value, const Color(0xFF0D9488), currentProfile),
                    ),
                    if (regularMembers.isNotEmpty) _buildRoleGroup('🏸 THÀNH VIÊN CHÍNH THỨC', regularMembers, AppColor.cMain, currentProfile),
                    if (guests.isNotEmpty) _buildRoleGroup('👤 KHÁCH VÃNG LAI', guests, const Color(0xFF6B7280), currentProfile),
                    const SizedBox(height: 16),
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: roleColor,
              letterSpacing: 0.6,
            ),
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
        color: isMe ? const Color(0xFFF0FDF4) : AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppColor.cMain.withValues(alpha: 0.6) : AppColor.cDivider,
          width: isMe ? 1.5 : 1.0,
        ),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: AppColor.cMain.withValues(alpha: 0.09),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
                  border: isMe ? Border.all(color: AppColor.cMain, width: 2) : null,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: isMe
                      ? AppColor.cMain.withValues(alpha: 0.15)
                      : roleColor.withValues(alpha: 0.15),
                  child: Text(
                    m.userName != null && m.userName!.isNotEmpty
                        ? m.userName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: isMe ? AppColor.cMain : roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
                      color: AppColor.cMain,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 11),

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
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                          color: isMe ? const Color(0xFF0F172A) : AppColor.cTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_rounded, size: 10, color: Colors.white),
                            SizedBox(width: 2.5),
                            Text(
                              'Bạn',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (m.role == ClubRole.host) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFF9333EA)),
                    ],
                  ],
                ),
                const SizedBox(height: 1.5),
                Text(
                  isMe ? '${m.email ?? "Thành viên"} • (Tài khoản của bạn)' : (m.email ?? 'Thành viên nhóm'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isMe ? AppColor.cMain : AppColor.cMuted,
                    fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
                  ),
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
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: roleColor.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Text(
              (m.roleName != null && m.roleName!.isNotEmpty)
                  ? m.roleName!
                  : m.role.displayName,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),

          // Actions for Host (chỉ hiện cho thành viên khác, không hiện cho chính mình)
          if (widget.isHost && m.role != ClubRole.host && !isMe)
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
