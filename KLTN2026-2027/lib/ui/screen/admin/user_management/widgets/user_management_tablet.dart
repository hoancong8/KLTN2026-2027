import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';
import 'package:kltn2026_2027/widget/has_permission.dart';
import '../user_management_vm/user_management_state.dart';
import '../user_management_vm/user_management_vm.dart';
import 'user_card.dart';
import 'user_form_dialog.dart';
import 'user_reset_password_dialog.dart';

class UserManagementTablet extends ConsumerStatefulWidget {
  const UserManagementTablet({super.key});

  @override
  ConsumerState<UserManagementTablet> createState() => _UserManagementTabletState();
}

class _UserManagementTabletState extends ConsumerState<UserManagementTablet> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterTabs = [
    'Tất cả',
    'Đã kích hoạt',
    'Bị khóa',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateUserDialog(BuildContext context, UserManagementState state) {
    showDialog(
      context: context,
      builder: (ctx) => UserFormDialog(
        availableRoles: state.roles,
        onSubmit: ({
          required String email,
          required String password,
          required String userName,
          String? phoneNumber,
          required List<String> roles,
        }) async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await ref.read(userManagementViewModelProvider.notifier).createUser(
                email: email,
                password: password,
                roles: roles,
              );
          if (success) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Tạo tài khoản thành công'),
                backgroundColor: AppColor.cMain,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserProfile user, UserManagementState state) {
    showDialog(
      context: context,
      builder: (ctx) => UserFormDialog(
        user: user,
        availableRoles: state.roles,
        onSubmit: ({
          required String email,
          required String password,
          required String userName,
          String? phoneNumber,
          required List<String> roles,
        }) async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await ref.read(userManagementViewModelProvider.notifier).updateUser(
                id: user.id,
                email: email,
                userName: userName,
                phoneNumber: phoneNumber,
                roles: roles,
              );
          if (success) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Cập nhật tài khoản thành công'),
                backgroundColor: AppColor.cMain,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColor.white,
        title: const Text(
          'Xác nhận xóa tài khoản',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColor.cTitle),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài khoản "${user.userName.isNotEmpty ? user.userName : user.email}"? Hành động này không thể hoàn tác.',
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
                  .read(userManagementViewModelProvider.notifier)
                  .deleteUser(user.id);
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa tài khoản thành công'),
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

  void _showResetPasswordDialog(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => UserResetPasswordDialog(
        user: user,
        onSubmit: (newPassword) async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await ref
              .read(userManagementViewModelProvider.notifier)
              .resetPassword(user.id, newPassword);
          if (success) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Đặt lại mật khẩu thành công'),
                backgroundColor: AppColor.cMain,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userManagementViewModelProvider);
    final vm = ref.read(userManagementViewModelProvider.notifier);
    final filteredUsers = state.filteredUsers;

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
                    'Quản lý nhân viên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cTitle,
                    ),
                  ),
                  const Spacer(),
                  HasPermission(
                    permission: Permissions.usersCreate,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateUserDialog(context, state),
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              color: AppColor.white,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => vm.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Tìm nhân viên...',
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

            // 3. Tab bộ lọc trạng thái
            Container(
              color: AppColor.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(_filterTabs.length, (idx) {
                  final isSelected = state.selectedFilterIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(_filterTabs[idx]),
                      selected: isSelected,
                      onSelected: (_) => vm.setFilter(idx),
                      selectedColor: AppColor.cMain,
                      backgroundColor: const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColor.white : const Color(0xFF4B5563),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColor.cMain : Colors.transparent,
                        ),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, color: AppColor.cDivider),

            // 4. Danh sách Grid trên Tablet
            Expanded(
              child: state.isLoading && state.users.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
                  : RefreshIndicator(
                      onRefresh: () => vm.loadUsers(),
                      color: AppColor.cMain,
                      child: state.errorMessage != null && state.users.isEmpty
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
                                          onPressed: () => vm.loadUsers(),
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
                          : filteredUsers.isEmpty
                              ? ListView(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.people_outline_rounded, size: 56, color: Colors.grey.shade300),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Không tìm thấy nhân viên nào',
                                            style: TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.w700, color: AppColor.cTitle),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
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
                                    mainAxisExtent: 90,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (ctx, idx) {
                                    final user = filteredUsers[idx];
                                    return UserCard(
                                      user: user,
                                      onEdit: () => _showEditUserDialog(context, user, state),
                                      onDelete: () => _showDeleteConfirmDialog(context, user),
                                      onToggleLock: () => vm.toggleLockUser(user.id, user.isLocked),
                                      onResetPassword: () => _showResetPasswordDialog(context, user),
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
