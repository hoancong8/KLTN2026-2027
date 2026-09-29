import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/domain/entities/app_role.dart';
import 'package:kltn2026_2027/widget/has_permission.dart';

class RoleCard extends StatelessWidget {
  final AppRole role;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoleCard({
    super.key,
    required this.role,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isSystemRole {
    final nameLower = role.name.toLowerCase();
    return role.isStatic || nameLower == 'admin' || nameLower == 'user';
  }

  Color _getIconColor() {
    final nameLower = role.name.toLowerCase();
    if (nameLower == 'admin' || nameLower == 'user') {
      return const Color(0xFFE65100); // Orange
    }
    return const Color(0xFF673AB7); // Purple
  }

  Color _getIconBackgroundColor() {
    final nameLower = role.name.toLowerCase();
    if (nameLower == 'admin' || nameLower == 'user') {
      return const Color(0xFFFFF3E0); // Soft orange background
    }
    return const Color(0xFFEDE7F6); // Soft purple background
  }

  @override
  Widget build(BuildContext context) {
    final isSysRole = _isSystemRole;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider.withAlpha(140)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon khiên (Shield)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: _getIconColor(),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // 2. Tên vai trò và Badges (Hệ thống, Mặc định)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.cTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (role.isDefault || role.name.toLowerCase() == 'user')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: const Text(
                          'Mặc định',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    if (isSysRole)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFCC80)),
                        ),
                        child: const Text(
                          'Hệ thống',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Nút Sửa & Xóa (Được bảo vệ bằng HasPermission)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HasPermission(
                permission: Permissions.rolesUpdate,
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1976D2)),
                  tooltip: 'Chỉnh sửa vai trò & quyền',
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              if (!isSysRole)
                HasPermission(
                  permission: Permissions.rolesDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFE53935)),
                      tooltip: 'Xóa vai trò',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
