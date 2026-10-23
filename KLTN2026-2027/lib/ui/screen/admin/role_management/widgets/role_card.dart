import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
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
      return AppColors.roleOrange; // Orange
    }
    return AppColors.roleViolet; // Purple
  }

  Color _getIconBackgroundColor() {
    final nameLower = role.name.toLowerCase();
    if (nameLower == 'admin' || nameLower == 'user') {
      return AppColors.accentLight; // Soft orange background
    }
    return AppColors.violetLight; // Soft purple background
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSysRole = _isSystemRole;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(8),
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
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
                          color: colors.successContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Mặc định',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.success,
                          ),
                        ),
                      ),
                    if (isSysRole)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.warningContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.warningBorder),
                        ),
                        child: const Text(
                          'Hệ thống',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.roleOrange,
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
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.info),
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
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
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
