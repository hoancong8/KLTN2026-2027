// lib/ui/screen/club/role_management/widgets/club_role_detail_view.dart

import 'package:flutter/material.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../app/provider/localization_provider.dart';
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
            backgroundColor: context.colors.primary,
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
        SnackBar(
          content: Text(context.l10n.role_delete_prevent_default),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.role_delete_confirm_title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.colors.textPrimary)),
        content: Text(context.l10n.role_delete_confirm_content, style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.com_cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.role_delete_button),
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
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.cardBackground,
        elevation: 0.5,
        leading: widget.onBack != null
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
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
                '${l10n.role_edit_title.toUpperCase()} - ${widget.role.roleName.toUpperCase()}',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
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
              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
              tooltip: l10n.role_delete_button,
              onPressed: _showDeleteConfirmDialog,
            ),
          if (!isHostRole && widget.isHost)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSaving ? null : _handleSavePermissions,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                      )
                    : Text(l10n.role_save_changes, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textMuted,
          indicatorColor: colors.primary,
          indicatorWeight: 2.5,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.palette_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(l10n.role_tab_display),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('${l10n.role_tab_permissions} (${_selectedPermissionIds.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_alt_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text('${l10n.role_tab_members} (${_membersWithRole.length})'),
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
    final colors = context.colors;
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Role Preview Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.cardBorder),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.role.description?.isNotEmpty == true
                          ? widget.role.description!
                          : 'Chưa có mô tả cho vai trò này',
                      style: TextStyle(fontSize: 12.5, color: colors.textMuted),
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
            color: colors.cardBackground,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.role_name_label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: colors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                enabled: !widget.role.isHostRole && widget.isHost,
                decoration: InputDecoration(
                  hintText: l10n.role_name_hint,
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.inputFill,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              Text(l10n.role_description_label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: colors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                enabled: !widget.role.isHostRole && widget.isHost,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: l10n.role_description_hint,
                  hintStyle: TextStyle(color: colors.textMuted),
                  filled: true,
                  fillColor: colors.inputFill,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              // Default Role Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.role_default_label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(l10n.role_default_sub, style: TextStyle(color: colors.textMuted, fontSize: 11.5)),
                    ],
                  ),
                  Switch(
                    value: widget.role.isDefault,
                    activeThumbColor: colors.primary,
                    activeTrackColor: colors.primary.withValues(alpha: 0.3),
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
            color: colors.cardBackground,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.role_color_palette, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: colors.textPrimary)),
              const SizedBox(height: 4),
              Text(l10n.role_color_sub, style: TextStyle(color: colors.textMuted, fontSize: 11.5)),
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
                      border: isCurrent ? Border.all(color: colors.textPrimary, width: 3) : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isCurrent ? const Icon(Icons.check, color: AppColors.white, size: 20) : null,
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
    final colors = context.colors;
    final l10n = context.l10n;
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
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.roleHost, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.role_host_notice,
                    style: const TextStyle(
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
            hintText: l10n.role_search_permissions,
            hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.textMuted),
            suffixIcon: _permSearchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, size: 16, color: colors.textMuted),
                    onPressed: () {
                      _permSearchController.clear();
                      setState(() => _permSearchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: colors.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.inputBorder),
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
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
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
                    label: Text(l10n.role_select_all, style: TextStyle(fontSize: 12, color: colors.primary)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedPermissionIds.clear();
                        _markChanged();
                      });
                    },
                    icon: Icon(Icons.remove_done_rounded, size: 16, color: colors.error),
                    label: Text(l10n.role_clear_all, style: TextStyle(fontSize: 12, color: colors.error)),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(height: 8),

        // Permission Groups (Discord Style Category Sections)
        if (moduleMap.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                l10n.role_no_permissions_found,
                style: TextStyle(color: colors.textMuted, fontSize: 13),
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
                title = l10n.role_module_operations;
                icon = Icons.sports_tennis_rounded;
                color = colors.primary;
                break;
              case 'FINANCE':
                title = l10n.role_module_finance;
                icon = Icons.account_balance_wallet_outlined;
                color = AppColors.roleTreasurer;
                break;
              case 'MEMBER':
                title = l10n.role_module_member;
                icon = Icons.people_alt_outlined;
                color = colors.primary;
                break;
              default:
                title = entry.key;
                icon = Icons.tune_rounded;
                color = colors.textMuted;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.cardBorder),
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
                  Divider(height: 1, color: colors.cardBorder),

                  // Permission Rows with SwitchListTile
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entry.value.length,
                    separatorBuilder: (_, _) => Divider(height: 1, indent: 16, endIndent: 16, color: colors.cardBorder),
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
                            color: isChecked ? colors.textPrimary : colors.textMuted,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            perm.displayDescription,
                            style: TextStyle(fontSize: 12, color: colors.textMuted, height: 1.3),
                          ),
                        ),
                        value: isChecked,
                        activeThumbColor: colors.primary,
                        activeTrackColor: colors.primary.withValues(alpha: 0.35),
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
    final colors = context.colors;
    final l10n = context.l10n;
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
                    hintText: l10n.role_search_members,
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                  ),
                ),
              ),
              if (widget.isHost) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showAddMemberToRoleDialog,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: Text(l10n.role_assign_button, style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),

        Divider(height: 12, color: colors.cardBorder),

        // Member List
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 48, color: colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          l10n.role_no_members,
                          style: TextStyle(color: colors.textMuted, fontSize: 13),
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
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
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
                                        style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                                      ),
                                    ],
                                  ],
                                ),
                                if (member.email != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    member.email!,
                                    style: TextStyle(fontSize: 11.5, color: colors.textMuted),
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
    final colors = context.colors;
    final l10n = context.l10n;
    final available = widget.allMembers.where((m) => m.roleId != widget.role.id).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${l10n.role_assign_dialog_title}: ${widget.role.roleName}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary)),
        content: SizedBox(
          width: double.maxFinite,
          height: 360,
          child: available.isEmpty
              ? Center(child: Text(l10n.role_all_members_assigned, style: TextStyle(color: colors.textMuted)))
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
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final ok = await widget.vm.updateRole(m.userId, ClubRole.member);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã cập nhật vai trò cho ${m.userName}!'),
                                backgroundColor: colors.primary,
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
            child: Text(l10n.com_close),
          ),
        ],
      ),
    );
  }
}
