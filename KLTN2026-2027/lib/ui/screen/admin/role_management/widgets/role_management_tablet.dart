import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/domain/entities/app_role.dart';
import 'package:kltn2026_2027/widget/has_permission.dart';
import '../role_management_vm/role_management_state.dart';
import '../role_management_vm/role_management_vm.dart';
import 'role_card.dart';
import 'role_form_dialog.dart';

class RoleManagementTablet extends ConsumerStatefulWidget {
  const RoleManagementTablet({super.key});

  @override
  ConsumerState<RoleManagementTablet> createState() => _RoleManagementTabletState();
}

class _RoleManagementTabletState extends ConsumerState<RoleManagementTablet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateRoleDialog(BuildContext context, RoleManagementState state) {
    showDialog(
      context: context,
      builder: (ctx) => RoleFormDialog(
        allPermissionGroups: state.allPermissionGroups,
        onSubmit: ({
          required String name,
          required String description,
          required List<String> permissions,
        }) async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await ref.read(roleManagementViewModelProvider.notifier).createRole(
                name: name,
                description: description,
                permissions: permissions,
              );
          if (success) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Tạo vai trò thành công'),
                backgroundColor: AppColor.cMain,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, AppRole role, RoleManagementState state) {
    showDialog(
      context: context,
      builder: (ctx) => RoleFormDialog(
        role: role,
        allPermissionGroups: state.allPermissionGroups,
        onSubmit: ({
          required String name,
          required String description,
          required List<String> permissions,
        }) async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await ref.read(roleManagementViewModelProvider.notifier).updateRole(
                id: role.id,
                name: name,
                description: description,
                permissions: permissions,
              );
          if (success) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Cập nhật vai trò thành công'),
                backgroundColor: AppColor.cMain,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppRole role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColor.white,
        title: const Text(
          'Xác nhận xóa vai trò',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColor.cTitle),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa vai trò "${role.name}"? Hành động này không thể hoàn tác.',
          style: const TextStyle(fontSize: 14, color: AppColor.cMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: AppColor.cMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(roleManagementViewModelProvider.notifier)
                  .deleteRole(role.id);
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa vai trò thành công'),
                    backgroundColor: AppColor.cMain,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roleManagementViewModelProvider);
    final vm = ref.read(roleManagementViewModelProvider.notifier);
    final filteredRoles = state.filteredRoles;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar (Tiêu đề + Nút Thêm)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColor.white,
              child: Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColor.cTitle),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'Quản lý vai trò',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cTitle,
                    ),
                  ),
                  const Spacer(),
                  HasPermission(
                    permission: Permissions.rolesCreate,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateRoleDialog(context, state),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.cMain,
                        foregroundColor: AppColor.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColor.cDivider),

            // 2. Thanh tìm kiếm
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              color: AppColor.white,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => vm.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Tìm vai trò...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColor.cMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColor.cMuted),
                          onPressed: () {
                            _searchController.clear();
                            vm.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColor.cDivider),

            // 3. Danh sách Grid trên Tablet
            Expanded(
              child: state.isLoading && state.roles.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
                  : RefreshIndicator(
                      onRefresh: () => vm.loadRoles(),
                      color: AppColor.cMain,
                      child: state.errorMessage != null && state.roles.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.error_outline_rounded, size: 56, color: Colors.red.shade300),
                                        const SizedBox(height: 12),
                                        Text(
                                          state.errorMessage!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () => vm.loadRoles(),
                                          icon: const Icon(Icons.refresh_rounded, size: 18),
                                          label: const Text('Thử lại'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColor.cMain,
                                            foregroundColor: AppColor.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : filteredRoles.isEmpty
                              ? ListView(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.shield_outlined, size: 56, color: Colors.grey.shade300),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Không tìm thấy vai trò nào',
                                            style: TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.w700, color: AppColor.cTitle),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Thử thay đổi từ khóa tìm kiếm',
                                            style: TextStyle(fontSize: 13, color: AppColor.cMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(20),
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 440,
                                    mainAxisExtent: 80,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filteredRoles.length,
                                  itemBuilder: (ctx, idx) {
                                    final role = filteredRoles[idx];
                                    return RoleCard(
                                      role: role,
                                      onEdit: () => _showEditRoleDialog(context, role, state),
                                      onDelete: () => _showDeleteConfirmDialog(context, role),
                                    );
                                  },
                                ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
