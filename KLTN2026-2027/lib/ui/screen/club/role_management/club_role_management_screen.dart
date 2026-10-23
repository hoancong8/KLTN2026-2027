// lib/ui/screen/club/role_management/club_role_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
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
    final colors = context.colors;
    final clubContext = ref.watch(clubContextViewModelProvider);
    final membersState = ref.watch(clubMembersViewModelProvider);
    final vm = ref.read(clubMembersViewModelProvider.notifier);

    final activeContext = clubContext.activeContext;
    final isSameClub = widget.clubId == null || widget.clubId!.isEmpty || activeContext?.clubId == widget.clubId;
    final isHost = isSameClub && activeContext?.role == ClubRole.host;
    final canManageRoles = isHost || (isSameClub && ref.hasClubPermission('MEMBER.ROLE.MANAGE'));

    if (!canManageRoles) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Vai trò & Phân quyền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          elevation: 0.5,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 54, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Không Có Quyền Truy Cập',
                  style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn không có quyền quản lý vai trò và phân quyền trong câu lạc bộ này.',
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (membersState.isLoadingRoles && membersState.roles.isEmpty) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Vai trò & Phân quyền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          elevation: 0.5,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
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
