import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/domain/entities/app_role.dart';
import 'package:kltn2026_2027/domain/entities/permission_group.dart';
import 'permission_tree_view.dart';

class RoleFormDialog extends StatefulWidget {
  final AppRole? role; // null = Thêm mới, khác null = Sửa
  final List<PermissionGroup> allPermissionGroups;
  final Function({
    required String name,
    required String description,
    required List<String> permissions,
  }) onSubmit;

  const RoleFormDialog({
    super.key,
    this.role,
    required this.allPermissionGroups,
    required this.onSubmit,
  });

  @override
  State<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<RoleFormDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late Set<String> _selectedPermissions;

  bool _isDefaultRole = false;
  bool _isDefaultMember = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _descController = TextEditingController(text: widget.role?.description ?? '');
    _selectedPermissions = Set<String>.from(widget.role?.assignedPermissionNames ?? []);
    _isDefaultRole = widget.role?.isDefault ?? false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        permissions: _selectedPermissions.toList(),
      );
      Navigator.of(context).pop();
    } else {
      // Nếu có lỗi ở tab Thông tin, tự động chuyển về Tab 0
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.role != null;
    final isStatic = widget.role?.isStatic ?? false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColor.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Column(
          children: [
            // 1. Header: Nút X, Tiêu đề, Nút Lưu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF4B5563)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        isEditing ? 'Sửa vai trò' : 'Thêm vai trò',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cTitle,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1E36), // Navy button như ảnh mẫu
                      foregroundColor: AppColor.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColor.cDivider),

            // 2. Tab Bar: Thông tin & Quyền hạn
            TabBar(
              controller: _tabController,
              indicatorColor: AppColor.cMain,
              indicatorWeight: 2.5,
              labelColor: AppColor.cTitle,
              unselectedLabelColor: AppColor.cMuted,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Thông tin'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Quyền hạn'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1, color: AppColor.cDivider),

            // 3. Tab Bar View Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ===== TAB 1: THÔNG TIN =====
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tên vai trò *',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              enabled: !isStatic,
                              decoration: InputDecoration(
                                hintText: 'Nhập tên vai trò',
                                hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColor.cDivider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColor.cDivider),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColor.cMain, width: 1.5),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên vai trò';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            const Text(
                              'Mô tả',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Nhập mô tả vai trò (tùy chọn)',
                                hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColor.cDivider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColor.cDivider),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1, color: AppColor.cDivider),
                            const SizedBox(height: 16),

                            // Switch: Vai trò mặc định
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vai trò mặc định',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Tự động gán cho người dùng mới',
                                      style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isDefaultRole,
                                  activeThumbColor: AppColor.cMain,
                                  activeTrackColor: AppColor.cMain.withAlpha(120),
                                  onChanged: (val) => setState(() => _isDefaultRole = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColor.cDivider),
                            const SizedBox(height: 16),

                            // Switch: Thành viên mặc định
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Thành viên mặc định',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Vai trò thành viên mặc định của hệ thống',
                                      style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isDefaultMember,
                                  activeThumbColor: AppColor.cMain,
                                  activeTrackColor: AppColor.cMain.withAlpha(120),
                                  onChanged: (val) => setState(() => _isDefaultMember = val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ===== TAB 2: QUYỀN HẠN (TREE VIEW) =====
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: PermissionTreeView(
                      allGroups: widget.allPermissionGroups,
                      selectedPermissions: _selectedPermissions,
                      onSelectionChanged: (updated) {
                        setState(() {
                          _selectedPermissions = updated;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
