import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
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
    final colors = context.colors;
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
              SnackBar(
                content: const Text('Tạo vai trò thành công'),
                backgroundColor: colors.primary,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, AppRole role, RoleManagementState state) {
    final colors = context.colors;
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
              SnackBar(
                content: const Text('Cập nhật vai trò thành công'),
                backgroundColor: colors.primary,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppRole role) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colors.surface,
        title: Text(
          'Xác nhận xóa vai trò',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa vai trò "${role.name}"? Hành động này không thể hoàn tác.',
          style: TextStyle(fontSize: 14, color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: TextStyle(color: colors.textMuted)),
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
                  SnackBar(
                    content: const Text('Đã xóa vai trò thành công'),
                    backgroundColor: colors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
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
    final colors = context.colors;
    final state = ref.watch(roleManagementViewModelProvider);
    final vm = ref.read(roleManagementViewModelProvider.notifier);
    final filteredRoles = state.filteredRoles;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar (Tiêu đề + Nút Thêm)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: colors.surface,
              child: Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    'Quản lý vai trò',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
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
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
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
            Divider(height: 1, color: colors.cardBorder),

            // 2. Thanh tìm kiếm
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              color: colors.surface,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => vm.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Tìm vai trò...',
                  hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18, color: colors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            vm.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: colors.cardBorder),

            // 3. Danh sách Grid trên Tablet
            Expanded(
              child: state.isLoading && state.roles.isEmpty
                  ? Center(child: CircularProgressIndicator(color: colors.primary))
                  : RefreshIndicator(
                      onRefresh: () => vm.loadRoles(),
                      color: colors.primary,
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
                                        Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
                                        const SizedBox(height: 12),
                                        Text(
                                          state.errorMessage!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () => vm.loadRoles(),
                                          icon: const Icon(Icons.refresh_rounded, size: 18),
                                          label: const Text('Thử lại'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colors.primary,
                                            foregroundColor: AppColors.white,
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
                                          Icon(Icons.shield_outlined, size: 56, color: AppColors.neutral300),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Không tìm thấy vai trò nào',
                                            style: TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Thử thay đổi từ khóa tìm kiếm',
                                            style: TextStyle(fontSize: 13, color: colors.textMuted),
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
