// lib/ui/screen/club/role_management/widgets/club_role_management_tablet.dart

import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../domain/entities/club/club_member.dart';
import '../../../../../domain/entities/club/club_role_item.dart';
import '../../club_management_vm/club_members_vm.dart';
import 'club_create_role_dialog.dart';
import 'club_role_detail_view.dart';
import 'club_role_list_view.dart';

class ClubRoleManagementTablet extends StatefulWidget {
  final List<ClubRoleItem> roles;
  final List<ClubRolePermission> allPermissions;
  final List<ClubMember> members;
  final ClubMembersViewModel vm;
  final bool isHost;
  final VoidCallback onRefresh;

  const ClubRoleManagementTablet({
    super.key,
    required this.roles,
    required this.allPermissions,
    required this.members,
    required this.vm,
    required this.isHost,
    required this.onRefresh,
  });

  @override
  State<ClubRoleManagementTablet> createState() => _ClubRoleManagementTabletState();
}

class _ClubRoleManagementTabletState extends State<ClubRoleManagementTablet> {
  ClubRoleItem? _selectedRole;

  @override
  void initState() {
    super.initState();
    if (widget.roles.isNotEmpty) {
      _selectedRole = widget.roles.first;
    }
  }

  @override
  void didUpdateWidget(covariant ClubRoleManagementTablet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedRole == null && widget.roles.isNotEmpty) {
      _selectedRole = widget.roles.first;
    } else if (_selectedRole != null) {
      final exists = widget.roles.any((r) => r.id == _selectedRole!.id);
      if (!exists && widget.roles.isNotEmpty) {
        _selectedRole = widget.roles.first;
      }
    }
  }

  void _showAddRoleDialog() {
    ClubCreateRoleDialog.show(
      context,
      availablePermissions: widget.allPermissions,
      onCreate: ({
        required String roleName,
        String? description,
        List<String> permissionIds = const [],
        bool isDefault = false,
      }) async {
        final ok = await widget.vm.createRole(
          roleName: roleName,
          description: description,
          permissionIds: permissionIds,
          isDefault: isDefault,
        );
        return ok;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text(
          'Quản lý Vai trò & Phân quyền',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Tải lại',
            onPressed: widget.onRefresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar: Role List (Discord style side column)
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: ClubRoleListView(
              roles: widget.roles,
              members: widget.members,
              selectedRole: _selectedRole,
              isHost: widget.isHost,
              onRoleSelected: (role) => setState(() => _selectedRole = role),
              onAddRolePressed: _showAddRoleDialog,
            ),
          ),

          // Right Editor Pane
          Expanded(
            child: _selectedRole != null
                ? ClubRoleDetailView(
                    key: ValueKey(_selectedRole!.id),
                    role: widget.roles.firstWhere(
                      (r) => r.id == _selectedRole!.id,
                      orElse: () => _selectedRole!,
                    ),
                    allPermissions: widget.allPermissions,
                    allMembers: widget.members,
                    vm: widget.vm,
                    isHost: widget.isHost,
                    onRoleDeleted: () {
                      setState(() {
                        _selectedRole = widget.roles.isNotEmpty ? widget.roles.first : null;
                      });
                    },
                  )
                : const Center(
                    child: Text(
                      'Chọn một vai trò từ danh sách bên trái để chỉnh sửa',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
