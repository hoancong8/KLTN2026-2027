// lib/ui/screen/club/role_management/widgets/club_create_role_dialog.dart

import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../domain/entities/club/club_role_item.dart';
import 'club_role_color_helper.dart';

class ClubCreateRoleDialog extends StatefulWidget {
  final List<ClubRolePermission> availablePermissions;
  final Future<bool> Function({
    required String roleName,
    String? description,
    List<String> permissionIds,
    bool isDefault,
  }) onCreate;

  const ClubCreateRoleDialog({
    super.key,
    required this.availablePermissions,
    required this.onCreate,
  });

  static Future<bool?> show(
    BuildContext context, {
    required List<ClubRolePermission> availablePermissions,
    required Future<bool> Function({
      required String roleName,
      String? description,
      List<String> permissionIds,
      bool isDefault,
    }) onCreate,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ClubCreateRoleDialog(
        availablePermissions: availablePermissions,
        onCreate: onCreate,
      ),
    );
  }

  @override
  State<ClubCreateRoleDialog> createState() => _ClubCreateRoleDialogState();
}

class _ClubCreateRoleDialogState extends State<ClubCreateRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isDefault = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final ok = await widget.onCreate(
      roleName: _nameController.text.trim(),
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      permissionIds: [],
      isDefault: _isDefault,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final previewColor = ClubRoleColorHelper.getRoleColor(_nameController.text);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colors.cardBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: previewColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield_outlined, color: previewColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tạo vai trò mới',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Thêm vai trò và cấu hình quyền hạn cho thành viên',
                            style: TextStyle(fontSize: 12, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: colors.textMuted),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: colors.cardBorder),
                const SizedBox(height: 18),

                // Role Name
                Text(
                  'Tên vai trò *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Ban trọng tài, HLV, Hậu cần...',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên vai trò';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Mô tả vai trò',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Mô tả nhiệm vụ của vai trò này trong câu lạc bộ',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Switch: Is Default
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vai trò mặc định',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            ),
                            Text(
                              'Tự động cấp vai trò này khi có thành viên mới',
                              style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        activeThumbColor: colors.primary,
                        activeTrackColor: colors.primary.withValues(alpha: 0.3),
                        onChanged: (val) => setState(() => _isDefault = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Hủy', style: TextStyle(color: colors.textMuted)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                            )
                          : const Text('Tạo vai trò', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
