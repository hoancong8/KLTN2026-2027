// lib/ui/screen/club/role_management/widgets/club_role_management_mobile.dart

import 'package:flutter/material.dart';
import '../../../../../app/consts/app_color.dart';
import '../../../../../domain/entities/club/club_member.dart';
import '../../../../../domain/entities/club/club_role_item.dart';
import '../../club_management_vm/club_members_vm.dart';
import 'club_create_role_dialog.dart';
import 'club_role_detail_view.dart';
import 'club_role_list_view.dart';

class ClubRoleManagementMobile extends StatefulWidget {
  final List<ClubRoleItem> roles;
  final List<ClubRolePermission> allPermissions;
  final List<ClubMember> members;
  final ClubMembersViewModel vm;
  final bool isHost;
  final VoidCallback onRefresh;

  const ClubRoleManagementMobile({
    super.key,
    required this.roles,
    required this.allPermissions,
    required this.members,
    required this.vm,
    required this.isHost,
    required this.onRefresh,
  });

  @override
  State<ClubRoleManagementMobile> createState() => _ClubRoleManagementMobileState();
}

class _ClubRoleManagementMobileState extends State<ClubRoleManagementMobile> {
  ClubRoleItem? _selectedRole;

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
    if (_selectedRole != null) {
      // Find latest updated instance of selected role
      final updatedRole = widget.roles.firstWhere(
        (r) => r.id == _selectedRole!.id,
        orElse: () => _selectedRole!,
      );

      return ClubRoleDetailView(
        role: updatedRole,
        allPermissions: widget.allPermissions,
        allMembers: widget.members,
        vm: widget.vm,
        isHost: widget.isHost,
        onBack: () => setState(() => _selectedRole = null),
        onRoleDeleted: () => setState(() => _selectedRole = null),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Vai trò & Phân quyền',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.cTitle,
        elevation: 0.5,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColor.cTitle),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.cMain),
            tooltip: 'Tải lại',
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: ClubRoleListView(
        roles: widget.roles,
        members: widget.members,
        selectedRole: null,
        isHost: widget.isHost,
        onRoleSelected: (role) => setState(() => _selectedRole = role),
        onAddRolePressed: _showAddRoleDialog,
      ),
    );
  }
}
