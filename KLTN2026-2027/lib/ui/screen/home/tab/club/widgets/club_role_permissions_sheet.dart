import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/consts/app_color.dart';
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
    if (rn.contains('host') || rn.contains('chủ')) return const Color(0xFF9333EA);
    if (rn.contains('phó') || rn.contains('deputy')) return const Color(0xFF2563EB);
    if (rn.contains('quỹ') || rn.contains('treasurer')) return const Color(0xFFD97706);
    if (rn.contains('khách') || rn.contains('guest')) return const Color(0xFF6B7280);
    return AppColor.cMain;
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role.roleName).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shield_outlined, color: _getRoleColor(role.roleName), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân quyền: ${role.roleName}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${selectedIds.length}/${allPerms.length} quyền đã cấp',
                        style: const TextStyle(fontSize: 12, color: AppColor.cMuted),
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
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          '👑 Vai trò Chủ câu lạc bộ (Host) có toàn quyền quản trị cao nhất, không thể thu hồi hoặc điều chỉnh.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF9333EA), fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        const SizedBox(height: 8),
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
                              label: const Text('Chọn tất cả', style: TextStyle(fontSize: 12)),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  selectedIds.clear();
                                });
                              },
                              icon: const Icon(Icons.remove_done, size: 16),
                              label: const Text('Bỏ chọn tất cả', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(height: 12),

                        // List by Modules
                        ...moduleMap.entries.map((entry) {
                          String moduleTitle;
                          IconData moduleIcon;
                          Color moduleColor;

                          switch (entry.key.toUpperCase()) {
                            case 'OPERATIONS':
                              moduleTitle = '🎾 VẬN HÀNH & BUỔI TẬP';
                              moduleIcon = Icons.sports_tennis_rounded;
                              moduleColor = const Color(0xFF0284C7);
                              break;
                            case 'FINANCE':
                              moduleTitle = '💰 TÀI CHÍNH & SỔ QUỸ';
                              moduleIcon = Icons.account_balance_wallet_outlined;
                              moduleColor = const Color(0xFFD97706);
                              break;
                            case 'MEMBER':
                              moduleTitle = '👥 THÀNH VIÊN & NHÓM';
                              moduleIcon = Icons.people_alt_outlined;
                              moduleColor = AppColor.cMain;
                              break;
                            default:
                              moduleTitle = '⚙️ ${entry.key}';
                              moduleIcon = Icons.tune_rounded;
                              moduleColor = Colors.grey;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(moduleIcon, size: 16, color: moduleColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      moduleTitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: moduleColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...entry.value.map((p) {
                                final isChecked = selectedIds.contains(p.id);
                                return CheckboxListTile(
                                  value: isChecked,
                                  dense: true,
                                  activeColor: AppColor.cMain,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    p.name.isNotEmpty ? p.name : p.code,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    p.code,
                                    style: const TextStyle(fontSize: 11, color: AppColor.cMuted),
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
                child: const Text('Hủy'),
              ),
              if (!isHost)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cMain,
                    foregroundColor: AppColor.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final ok = await widget.vm.updateRolePermissions(role.id, selectedIds.toList());
                    if (ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã cập nhật phân quyền cho vai trò "${role.roleName}"!'),
                          backgroundColor: AppColor.cMain,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Lưu phân quyền'),
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
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6D28D9), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Vai Trò & Phân Quyền Nhóm',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColor.cTitle,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColor.cMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Text(
              'Thiết lập quyền hạn cụ thể (Vận hành, Thu chi, Thành viên) cho từng vai trò',
              style: TextStyle(fontSize: 12.5, color: AppColor.cMuted),
            ),
            const Divider(height: 20),

            // Content
            state.isLoadingRoles
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: AppColor.cMain)),
                  )
                : roles.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Chưa có dữ liệu vai trò nội bộ',
                            style: TextStyle(color: AppColor.cMuted, fontSize: 13),
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
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final role = roles[index];
                            final roleColor = _getRoleColor(role.roleName);
                            final isHost = role.isHostRole || role.roleName.toLowerCase().contains('host');

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              role.roleName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.cTitle,
                                              ),
                                            ),
                                            if (isHost) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF9333EA).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Chủ nhóm',
                                                  style: TextStyle(
                                                    color: Color(0xFF9333EA),
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
                                          isHost
                                              ? 'Toàn bộ ${allPerms.isNotEmpty ? allPerms.length : 18} quyền sở hữu cao nhất'
                                              : '${role.permissions.length}/${allPerms.isNotEmpty ? allPerms.length : 18} quyền được cấp',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isHost ? const Color(0xFF9333EA) : AppColor.cMuted,
                                            fontWeight: isHost ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: roleColor,
                                      side: BorderSide(color: roleColor.withValues(alpha: 0.5)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    onPressed: () => _openEditPermissionsDialog(role, allPerms),
                                    icon: Icon(
                                      isHost ? Icons.visibility_outlined : Icons.edit_outlined,
                                      size: 15,
                                    ),
                                    label: Text(
                                      isHost ? 'Xem' : 'Cấp quyền',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
