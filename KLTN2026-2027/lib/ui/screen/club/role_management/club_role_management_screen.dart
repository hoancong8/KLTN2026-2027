// lib/ui/screen/club/role_management/club_role_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/consts/app_color.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../widget/responsive_layout.dart';
import '../club_management_vm/club_members_vm.dart';
import '../club_vm/club_context_vm.dart';
import 'widgets/club_role_management_mobile.dart';
import 'widgets/club_role_management_tablet.dart';

class ClubRoleManagementScreen extends ConsumerStatefulWidget {
  final String? clubId;

  const ClubRoleManagementScreen({
    super.key,
    this.clubId,
  });

  static Future<void> show(BuildContext context, {String? clubId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClubRoleManagementScreen(clubId: clubId),
      ),
    );
  }

  @override
  ConsumerState<ClubRoleManagementScreen> createState() => _ClubRoleManagementScreenState();
}

class _ClubRoleManagementScreenState extends ConsumerState<ClubRoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final vm = ref.read(clubMembersViewModelProvider.notifier);
    if (widget.clubId != null && widget.clubId!.isNotEmpty) {
      vm.loadForClub(widget.clubId!);
    }
    vm.loadRolesAndPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final clubContext = ref.watch(clubContextViewModelProvider);
    final membersState = ref.watch(clubMembersViewModelProvider);
    final vm = ref.read(clubMembersViewModelProvider.notifier);

    final activeContext = clubContext.activeContext;
    final isHost = activeContext?.role == ClubRole.host ||
        (activeContext?.role.displayName.toLowerCase().contains('host') ?? false);

    if (membersState.isLoadingRoles && membersState.roles.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('Vai trò & Phân quyền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          backgroundColor: Colors.white,
          foregroundColor: AppColor.cTitle,
          elevation: 0.5,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColor.cMain),
        ),
      );
    }

    return ResponsiveLayout(
      mobile: ClubRoleManagementMobile(
        roles: membersState.roles,
        allPermissions: membersState.availablePermissions,
        members: membersState.members,
        vm: vm,
        isHost: isHost,
        onRefresh: _loadData,
      ),
      tablet: ClubRoleManagementTablet(
        roles: membersState.roles,
        allPermissions: membersState.availablePermissions,
        members: membersState.members,
        vm: vm,
        isHost: isHost,
        onRefresh: _loadData,
      ),
    );
  }
}
