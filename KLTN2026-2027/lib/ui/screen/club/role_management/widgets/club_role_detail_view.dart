// lib/ui/screen/club/role_management/widgets/club_role_detail_view.dart

import 'package:flutter/material.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../domain/entities/club/club_member.dart';
import '../../../../../domain/entities/club/club_role_item.dart';
import '../../../../../domain/enums/club_role.dart';
import '../../club_management_vm/club_members_vm.dart';
import 'club_role_color_helper.dart';

class ClubRoleDetailView extends StatefulWidget {
  final ClubRoleItem role;
  final List<ClubRolePermission> allPermissions;
  final List<ClubMember> allMembers;
  final ClubMembersViewModel vm;
  final bool isHost;
  final VoidCallback? onBack;
  final VoidCallback? onRoleDeleted;

  const ClubRoleDetailView({
    super.key,
    required this.role,
    required this.allPermissions,
    required this.allMembers,
    required this.vm,
    required this.isHost,
    this.onBack,
    this.onRoleDeleted,
  });

  @override
  State<ClubRoleDetailView> createState() => _ClubRoleDetailViewState();
}

class _ClubRoleDetailViewState extends State<ClubRoleDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Set<String> _selectedPermissionIds;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final TextEditingController _permSearchController = TextEditingController();
  final TextEditingController _memberSearchController = TextEditingController();

  String _permSearchQuery = '';
  String _memberSearchQuery = '';
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedPermissionIds = widget.role.permissions.map((p) => p.id).toSet();
    _nameController = TextEditingController(text: widget.role.roleName);
    _descController = TextEditingController(text: widget.role.description ?? '');
  }

  @override
  void didUpdateWidget(covariant ClubRoleDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role.id != widget.role.id) {
      _selectedPermissionIds = widget.role.permissions.map((p) => p.id).toSet();
      _nameController.text = widget.role.roleName;
      _descController.text = widget.role.description ?? '';
      _permSearchQuery = '';
      _memberSearchQuery = '';
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _permSearchController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _handleSavePermissions() async {
    setState(() => _isSaving = true);
    final ok = await widget.vm.updateRolePermissions(widget.role.id, _selectedPermissionIds.toList());
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (ok) _hasChanges = false;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu phân quyền cho "${widget.role.roleName}"!'),
            backgroundColor: AppColor.cMain,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    final canDelete = !widget.role.isHostRole && !widget.role.isDefault;
    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa vai trò mặc định hoặc Chủ nhóm!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa vai trò', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Bạn có chắc chắn muốn xóa vai trò "${widget.role.roleName}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa vai trò'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await widget.vm.deleteRole(widget.role.id);
      if (ok && mounted) {
        widget.onRoleDeleted?.call();
      }
    }
  }

  List<ClubMember> get _membersWithRole {
    return widget.allMembers.where((m) {
      if (m.roleId != null && m.roleId!.isNotEmpty) {
        return m.roleId == widget.role.id;
      }
      return m.roleName?.toLowerCase().trim() == widget.role.roleName.toLowerCase().trim();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = ClubRoleColorHelper.getRoleColor(widget.role.roleName, isHost: widget.role.isHostRole);
    final isHostRole = widget.role.isHostRole;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColor.cTitle),
                onPressed: widget.onBack,
              )
            : null,
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: roleColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'CHỈNH SỬA VAI TRÒ - ${widget.role.roleName.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColor.cTitle,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isHost && !isHostRole && !widget.role.isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              tooltip: 'Xóa vai trò',
              onPressed: _showDeleteConfirmDialog,
            ),
          if (!isHostRole && widget.isHost)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cMain,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSaving ? null : _handleSavePermissions,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Lưu thay đổi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColor.cMain,
          unselectedLabelColor: AppColor.cMuted,
          indicatorColor: AppColor.cMain,
          indicatorWeight: 2.5,
          tabs: [
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.palette_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Hiển thị'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('Phân quyền (${_selectedPermissionIds.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_alt_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('Thành viên (${_membersWithRole.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDisplayTab(roleColor),
          _buildPermissionsTab(isHostRole),
          _buildMembersTab(roleColor),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: HIỂN THỊ (DISPLAY / INFO)
  // ==========================================
  Widget _buildDisplayTab(Color roleColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Role Preview Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_rounded, color: roleColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.role.roleName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.cTitle),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.role.description?.isNotEmpty == true
                          ? widget.role.description!
                          : 'Chưa có mô tả cho vai trò này',
                      style: const TextStyle(fontSize: 12.5, color: AppColor.cMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Role Name Field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tên vai trò', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                enabled: !widget.role.isHostRole && widget.isHost,
                decoration: InputDecoration(
                  hintText: 'Nhập tên vai trò',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                enabled: !widget.role.isHostRole && widget.isHost,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Mô tả vai trò trong câu lạc bộ',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              // Default Role Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vai trò mặc định', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      SizedBox(height: 2),
                      Text('Tự động cấp vai trò này khi có thành viên mới', style: TextStyle(color: AppColor.cMuted, fontSize: 11.5)),
                    ],
                  ),
                  Switch(
                    value: widget.role.isDefault,
                    activeThumbColor: AppColor.cMain,
                    activeTrackColor: AppColor.cMain.withValues(alpha: 0.3),
                    onChanged: null, // Default is managed at creation
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Color Palette (Preset theme colors like Discord)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Màu sắc nhận diện vai trò', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 4),
              const Text('Màu hiển thị của chấm đại diện và huy hiệu thành viên', style: TextStyle(color: AppColor.cMuted, fontSize: 11.5)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ClubRoleColorHelper.palette.map((color) {
                  final isCurrent = color == roleColor;
                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: AppColor.cTitle, width: 3) : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isCurrent ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: PHÂN QUYỀN (DISCORD TOGGLES)
  // ==========================================
  Widget _buildPermissionsTab(bool isHostRole) {
    // Group permissions by module
    final Map<String, List<ClubRolePermission>> moduleMap = {};
    for (final p in widget.allPermissions) {
      if (_permSearchQuery.isNotEmpty) {
        final q = _permSearchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.code.toLowerCase().contains(q) &&
            !p.displayDescription.toLowerCase().contains(q)) {
          continue;
        }
      }
      final key = p.moduleGroup.isNotEmpty ? p.moduleGroup.toUpperCase() : 'KHÁC';
      moduleMap.putIfAbsent(key, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // Host Role Notice Banner
        if (isHostRole)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.violetLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.violetBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: AppColors.roleHost, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vai trò Chủ câu lạc bộ sở hữu toàn bộ 18 quyền hạn tối cao của hệ thống. Các quyền này được kích hoạt vĩnh viễn và không thể tắt.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.roleHost,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Search Permissions Input
        TextField(
          controller: _permSearchController,
          onChanged: (val) => setState(() => _permSearchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm quyền hạn...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColor.cMuted),
            suffixIcon: _permSearchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16, color: AppColor.cMuted),
                    onPressed: () {
                      _permSearchController.clear();
                      setState(() => _permSearchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick Action Shortcuts: Select All / Clear All (like Discord's "Clear permissions")
        if (!isHostRole && widget.isHost)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedPermissionIds.length}/${widget.allPermissions.length} quyền đã bật',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColor.cTitle),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPermissionIds.addAll(widget.allPermissions.map((p) => p.id));
                        _markChanged();
                      });
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Chọn tất cả', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPermissionIds.clear();
                        _markChanged();
                      });
                    },
                    icon: const Icon(Icons.remove_done_rounded, size: 16, color: Colors.red),
                    label: const Text('Bỏ tất cả', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 8),

        // Permission Groups (Discord Style Category Sections)
        if (moduleMap.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Không tìm thấy quyền hạn phù hợp',
                style: TextStyle(color: AppColor.cMuted, fontSize: 13),
              ),
            ),
          )
        else
          ...moduleMap.entries.map((entry) {
            String title;
            IconData icon;
            Color color;

            switch (entry.key) {
              case 'OPERATIONS':
                title = 'VẬN HÀNH & BUỔI TẬP';
                icon = Icons.sports_tennis_rounded;
                color = AppColors.roleSky;
                break;
              case 'FINANCE':
                title = 'TÀI CHÍNH & SỔ QUỸ';
                icon = Icons.account_balance_wallet_outlined;
                color = AppColors.roleTreasurer;
                break;
              case 'MEMBER':
                title = 'THÀNH VIÊN & NHÓM';
                icon = Icons.people_alt_outlined;
                color = AppColor.cMain;
                break;
              default:
                title = entry.key;
                icon = Icons.tune_rounded;
                color = Colors.grey;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header (Discord style header)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColor.cDivider),

                  // Permission Rows with SwitchListTile
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entry.value.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.borderSubtle),
                    itemBuilder: (ctx, idx) {
                      final perm = entry.value[idx];
                      final isChecked = isHostRole || _selectedPermissionIds.contains(perm.id);

                      return SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        title: Text(
                          perm.name.isNotEmpty ? perm.name : perm.code,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isChecked ? AppColor.cTitle : AppColors.roleGuest,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            perm.displayDescription,
                            style: const TextStyle(fontSize: 12, color: AppColor.cMuted, height: 1.3),
                          ),
                        ),
                        value: isChecked,
                        activeThumbColor: AppColor.cMain,
                        activeTrackColor: AppColor.cMain.withValues(alpha: 0.35),
                        onChanged: isHostRole || !widget.isHost
                            ? null
                            : (val) {
                                setState(() {
                                  if (val) {
                                    _selectedPermissionIds.add(perm.id);
                                  } else {
                                    _selectedPermissionIds.remove(perm.id);
                                  }
                                  _markChanged();
                                });
                              },
                      );
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // TAB 3: THÀNH VIÊN (MANAGE MEMBERS)
  // ==========================================
  Widget _buildMembersTab(Color roleColor) {
    final members = _membersWithRole.where((m) {
      if (_memberSearchQuery.isEmpty) return true;
      final q = _memberSearchQuery.toLowerCase();
      return (m.userName?.toLowerCase().contains(q) ?? false) ||
          (m.nickname?.toLowerCase().contains(q) ?? false) ||
          (m.email?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      children: [
        // Header & Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberSearchController,
                  onChanged: (val) => setState(() => _memberSearchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Tìm thành viên trong vai trò này...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColor.cMuted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              if (widget.isHost) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showAddMemberToRoleDialog,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Gán vai trò', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cMain,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),

        const Divider(height: 12, color: AppColor.cDivider),

        // Member List
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có thành viên nào nắm giữ vai trò "${widget.role.roleName}"',
                          style: const TextStyle(color: AppColor.cMuted, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final member = members[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: roleColor.withValues(alpha: 0.15),
                            child: Text(
                              (member.userName?.isNotEmpty == true ? member.userName![0] : 'U').toUpperCase(),
                              style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.nickname ?? member.userName ?? 'Người dùng',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                    if (member.nickname != null && member.userName != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(@${member.userName})',
                                        style: const TextStyle(fontSize: 11.5, color: AppColor.cMuted),
                                      ),
                                    ],
                                  ],
                                ),
                                if (member.email != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    member.email!,
                                    style: const TextStyle(fontSize: 11.5, color: AppColor.cMuted),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddMemberToRoleDialog() {
    // Pick from club members who don't already have this role
    final available = widget.allMembers.where((m) => m.roleId != widget.role.id).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Gán vai trò: ${widget.role.roleName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 360,
          child: available.isEmpty
              ? const Center(child: Text('Tất cả thành viên đã nắm giữ vai trò này'))
              : ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (ctx, idx) {
                    final m = available[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text((m.userName ?? 'U')[0].toUpperCase()),
                      ),
                      title: Text(m.nickname ?? m.userName ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      subtitle: Text(m.roleName ?? m.role.displayName, style: const TextStyle(fontSize: 11.5)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cMain,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final ok = await widget.vm.updateRole(m.userId, ClubRole.member);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã cập nhật vai trò cho ${m.userName}!'),
                                backgroundColor: AppColor.cMain,
                              ),
                            );
                          }
                        },
                        child: const Text('Gán', style: TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
