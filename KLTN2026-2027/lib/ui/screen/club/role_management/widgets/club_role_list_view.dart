// lib/ui/screen/club/role_management/widgets/club_role_list_view.dart

import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../domain/entities/club/club_member.dart';
import '../../../../../domain/entities/club/club_role_item.dart';
import 'club_role_color_helper.dart';

class ClubRoleListView extends StatefulWidget {
  final List<ClubRoleItem> roles;
  final List<ClubMember> members;
  final ClubRoleItem? selectedRole;
  final ValueChanged<ClubRoleItem> onRoleSelected;
  final VoidCallback onAddRolePressed;
  final bool isHost;

  const ClubRoleListView({
    super.key,
    required this.roles,
    required this.members,
    required this.selectedRole,
    required this.onRoleSelected,
    required this.onAddRolePressed,
    required this.isHost,
  });

  @override
  State<ClubRoleListView> createState() => _ClubRoleListViewState();
}

class _ClubRoleListViewState extends State<ClubRoleListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getMemberCountForRole(ClubRoleItem role) {
    return widget.members.where((m) {
      if (m.roleId != null && m.roleId!.isNotEmpty) {
        return m.roleId == role.id;
      }
      final rName = m.roleName?.toLowerCase().trim();
      final target = role.roleName.toLowerCase().trim();
      return rName == target;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoles = widget.roles.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.roleName.toLowerCase().contains(q) ||
          (r.description?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      children: [
        // Header & Add Role Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vai trò nội bộ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.roles.length} vai trò trong câu lạc bộ',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (widget.isHost)
                ElevatedButton.icon(
                  onPressed: widget.onAddRolePressed,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Thêm vai trò', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
            ],
          ),
        ),

        // Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm vai trò...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const Divider(height: 12, color: AppColors.border),

        // Role List
        Expanded(
          child: filteredRoles.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Không tìm thấy vai trò phù hợp',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  itemCount: filteredRoles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final role = filteredRoles[index];
                    final isSelected = widget.selectedRole?.id == role.id;
                    final roleColor = ClubRoleColorHelper.getRoleColor(role.roleName, isHost: role.isHostRole);
                    final memberCount = _getMemberCountForRole(role);

                    return Material(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => widget.onRoleSelected(role),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Discord Role Colored Dot / Badge
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: roleColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: roleColor.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name & Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          role.roleName,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (role.isHostRole) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.roleHost.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Chủ nhóm',
                                              style: TextStyle(
                                                color: AppColors.roleHost,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ] else if (role.isDefault) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.roleMember.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Mặc định',
                                              style: TextStyle(
                                                color: AppColors.roleMember,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${role.permissions.length} quyền • $memberCount thành viên',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: isSelected ? AppColors.primary : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
