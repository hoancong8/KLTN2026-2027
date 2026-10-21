import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../../domain/entities/club/club_role_item.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';

class ClubRolePermissionsSheet extends ConsumerStatefulWidget {
  final ClubMembersViewModel vm;

  const ClubRolePermissionsSheet({
    super.key,
    required this.vm,
  });

  static Future<void> show(BuildContext context, ClubMembersViewModel vm) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClubRolePermissionsSheet(vm: vm),
    );
  }

  @override
  ConsumerState<ClubRolePermissionsSheet> createState() => _ClubRolePermissionsSheetState();
}

class _ClubRolePermissionsSheetState extends ConsumerState<ClubRolePermissionsSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.vm.loadRolesAndPermissions();
    });
  }

  Color _getRoleColor(String roleName) {
    final rn = roleName.toLowerCase();
    if (rn.contains('host') || rn.contains('chủ')) return AppColors.roleHost;
    if (rn.contains('phó') || rn.contains('deputy')) return AppColors.roleDeputy;
    if (rn.contains('quỹ') || rn.contains('treasurer')) return AppColors.roleTreasurer;
    if (rn.contains('khách') || rn.contains('guest')) return AppColors.roleGuest;
    return AppColors.primary;
  }

  void _openEditPermissionsDialog(ClubRoleItem role, List<ClubRolePermission> allPerms) {
    final selectedIds = role.permissions.map((p) => p.id).toSet();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isHost = role.isHostRole || role.roleName.toLowerCase().contains('host');

          // Nhóm permissions theo moduleGroup
          final Map<String, List<ClubRolePermission>> moduleMap = {};
          for (final p in allPerms) {
            final key = p.moduleGroup.isNotEmpty ? p.moduleGroup : 'KHÁC';
            moduleMap.putIfAbsent(key, () => []).add(p);
          }

          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
            titlePadding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            contentPadding: AppSpacing.horizontalBase,
            title: Row(
              children: [
                Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    color: _getRoleColor(role.roleName).withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(Icons.shield_outlined, color: _getRoleColor(role.roleName), size: 22),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân quyền: ${role.roleName}',
                        style: AppTypography.titleMedium.bold,
                      ),
                      Text(
                        '${selectedIds.length}/${allPerms.length} quyền đã cấp',
                        style: AppTypography.bodySmall.colored(AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 480,
              child: isHost
                  ? Center(
                      child: Padding(
                        padding: AppSpacing.allLg,
                        child: Text(
                          'Vai trò Chủ câu lạc bộ (Host) có toàn quyền quản trị cao nhất, không thể thu hồi hoặc điều chỉnh.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.semiBold.colored(AppColors.roleHost),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        AppSpacing.gapH8,
                        // Quick Toggle All
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  selectedIds.addAll(allPerms.map((p) => p.id));
                                });
                              },
                              icon: const Icon(Icons.done_all, size: 16),
                              label: Text('Chọn tất cả', style: AppTypography.labelMedium),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  selectedIds.clear();
                                });
                              },
                              icon: const Icon(Icons.remove_done, size: 16),
                              label: Text('Bỏ chọn tất cả', style: AppTypography.labelMedium),
                            ),
                          ],
                        ),
                        const Divider(height: AppSpacing.md),

                        // List by Modules
                        ...moduleMap.entries.map((entry) {
                          String moduleTitle;
                          IconData moduleIcon;
                          Color moduleColor;

                          switch (entry.key.toUpperCase()) {
                            case 'OPERATIONS':
                              moduleTitle = 'VẬN HÀNH & BUỔI TẬP';
                              moduleIcon = Icons.sports_tennis_rounded;
                              moduleColor = AppColors.roleSky;
                              break;
                            case 'FINANCE':
                              moduleTitle = 'TÀI CHÍNH & SỔ QUỸ';
                              moduleIcon = Icons.account_balance_wallet_outlined;
                              moduleColor = AppColors.roleTreasurer;
                              break;
                            case 'MEMBER':
                              moduleTitle = 'THÀNH VIÊN & NHÓM';
                              moduleIcon = Icons.people_alt_outlined;
                              moduleColor = AppColors.primary;
                              break;
                            default:
                              moduleTitle = entry.key;
                              moduleIcon = Icons.tune_rounded;
                              moduleColor = AppColors.neutral500;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(moduleIcon, size: 16, color: moduleColor),
                                    AppSpacing.gapW8,
                                    Text(
                                      moduleTitle,
                                      style: AppTypography.labelSmall.bold.colored(moduleColor).copyWith(letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                              ...entry.value.map((p) {
                                final isChecked = selectedIds.contains(p.id);
                                return CheckboxListTile(
                                  value: isChecked,
                                  dense: true,
                                  activeColor: AppColors.primary,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    p.name.isNotEmpty ? p.name : p.code,
                                    style: AppTypography.bodyMedium.semiBold,
                                  ),
                                  subtitle: Text(
                                    p.code,
                                    style: AppTypography.labelSmall.colored(AppColors.textMuted),
                                  ),
                                  onChanged: (val) {
                                    setDialogState(() {
                                      if (val == true) {
                                        selectedIds.add(p.id);
                                      } else {
                                        selectedIds.remove(p.id);
                                      }
                                    });
                                  },
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Hủy', style: AppTypography.labelLarge.colored(AppColors.textMuted)),
              ),
              if (!isHost)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final ok = await widget.vm.updateRolePermissions(role.id, selectedIds.toList());
                    if (ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã cập nhật phân quyền cho vai trò "${role.roleName}"!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text('Lưu phân quyền', style: AppTypography.labelLarge.bold.colored(AppColors.onPrimary)),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubMembersViewModelProvider);
    final roles = state.roles;
    final allPerms = state.availablePermissions;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.bottomSheet,
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.base,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderXs,
                ),
              ),
            ),
            AppSpacing.gapH16,

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: AppColors.roleHost, size: 24),
                    AppSpacing.gapW8,
                    Text(
                      'Vai Trò & Phân Quyền Nhóm',
                      style: AppTypography.titleMedium.bold.colored(AppColors.textPrimary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              'Thiết lập quyền hạn cụ thể (Vận hành, Thu chi, Thành viên) cho từng vai trò',
              style: AppTypography.bodySmall.colored(AppColors.textMuted),
            ),
            const Divider(height: AppSpacing.lg),

            // Content
            state.isLoadingRoles
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                : roles.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.error != null
                                    ? 'Không thể tải vai trò: ${state.error?.message}'
                                    : 'Chưa có dữ liệu vai trò nội bộ',
                                style: AppTypography.bodyMedium.colored(AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                              if (state.error != null) ...[
                                AppSpacing.gapH12,
                                TextButton.icon(
                                  onPressed: widget.vm.loadRolesAndPermissions,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text('Thử lại', style: AppTypography.labelLarge),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.55,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: roles.length,
                          separatorBuilder: (_, _) => AppSpacing.gapH8,
                          itemBuilder: (ctx, index) {
                            final role = roles[index];
                            final roleColor = _getRoleColor(role.roleName);
                            final isHost = role.isHostRole || role.roleName.toLowerCase().contains('host');

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: roleColor.withValues(alpha: 0.15),
                                    child: Icon(
                                      isHost ? Icons.workspace_premium_rounded : Icons.shield_rounded,
                                      color: roleColor,
                                      size: 18,
                                    ),
                                  ),
                                  AppSpacing.gapW12,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              role.roleName,
                                              style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                                            ),
                                            if (isHost) ...[
                                              AppSpacing.gapW8,
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.roleHost.withValues(alpha: 0.1),
                                                  borderRadius: AppRadius.borderXs,
                                                ),
                                                child: Text(
                                                  'Chủ nhóm',
                                                  style: AppTypography.labelSmall.bold.colored(AppColors.roleHost),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        AppSpacing.gapH4,
                                        Text(
                                          isHost
                                              ? 'Toàn bộ ${allPerms.isNotEmpty ? allPerms.length : 18} quyền sở hữu cao nhất'
                                              : '${role.permissions.length}/${allPerms.isNotEmpty ? allPerms.length : 18} quyền được cấp',
                                          style: AppTypography.labelSmall.colored(isHost ? AppColors.roleHost : AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: roleColor,
                                      side: BorderSide(color: roleColor.withValues(alpha: 0.5)),
                                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                                    ),
                                    onPressed: () => _openEditPermissionsDialog(role, allPerms),
                                    icon: Icon(
                                      isHost ? Icons.visibility_outlined : Icons.edit_outlined,
                                      size: 15,
                                    ),
                                    label: Text(
                                      isHost ? 'Xem' : 'Cấp quyền',
                                      style: AppTypography.labelSmall.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
