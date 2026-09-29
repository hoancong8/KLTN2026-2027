import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';
import 'package:kltn2026_2027/widget/has_permission.dart';

class UserCard extends ConsumerWidget {
  final UserProfile user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleLock;
  final VoidCallback onResetPassword;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleLock,
    required this.onResetPassword,
  });

  String _getInitials(String name, String email) {
    final text = name.trim().isNotEmpty ? name.trim() : email.trim();
    if (text.isEmpty) return 'U';
    final parts = text.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return text.substring(0, text.length.clamp(1, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = _getInitials(user.userName, user.email);
    final rolesDisplay = user.roles.isNotEmpty ? user.roles.join(', ') : 'Nhân viên';

    final canLock = ref.watch(hasPermissionProvider(Permissions.usersLock));
    final canResetPassword = ref.watch(hasPermissionProvider(Permissions.usersResetPassword));
    final hasAnyMenuAction = canLock || canResetPassword;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider.withAlpha(150)),
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
          // 1. Avatar tròn với chữ cái đầu
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF0F1E36), // Dark Navy như ảnh mẫu
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // 2. Thông tin nhân viên (Tên, Email, Tag vai trò, Trạng thái Khóa)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hàng 1: Tên & Badge Bị khóa (nếu có)
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isLocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 10, color: Colors.red.shade700),
                            const SizedBox(width: 2),
                            Text(
                              'Đã khóa',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),

                // Hàng 2: Email
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColor.cMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Hàng 3: Chip hiển thị Vai trò (Roles)
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 13, color: AppColor.cMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rolesDisplay,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: user.roles.contains('Admin') ? AppColor.cMain : AppColor.cMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 3. Action Buttons (Sửa & Xóa & Menu phụ)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Sửa
              HasPermission(
                permission: Permissions.usersUpdate,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF90CAF9)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sửa',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              // Nút Xóa
              HasPermission(
                permission: Permissions.usersDelete,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      side: const BorderSide(color: Color(0xFFEF9A9A)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              // Menu phụ (Khóa / Mở khóa / Đặt lại mật khẩu)
              if (hasAnyMenuAction)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColor.cMuted),
                  padding: EdgeInsets.zero,
                  tooltip: 'Thao tác khác',
                  onSelected: (value) {
                    if (value == 'lock') {
                      onToggleLock();
                    } else if (value == 'reset_password') {
                      onResetPassword();
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (canLock)
                      PopupMenuItem(
                        value: 'lock',
                        child: Row(
                          children: [
                            Icon(
                              user.isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                              size: 18,
                              color: user.isLocked ? Colors.green : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              user.isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                              style: TextStyle(
                                fontSize: 13,
                                color: user.isLocked ? Colors.green.shade800 : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (canResetPassword)
                      const PopupMenuItem(
                        value: 'reset_password',
                        child: Row(
                          children: [
                            Icon(Icons.key_rounded, size: 18, color: AppColor.cMain),
                            SizedBox(width: 10),
                            Text('Đặt lại mật khẩu', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
