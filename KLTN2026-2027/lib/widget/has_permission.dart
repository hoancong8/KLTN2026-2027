import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider.dart';

/// Widget phân quyền giao diện (Permission Guard)
/// Dựa trên danh sách permissions thu được khi người dùng đăng nhập (/api/v1/user/me).
class HasPermission extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const HasPermission({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(userPermissionsProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final isAdmin = userProfile?.roles.contains('Admin') == true ||
        userProfile?.permissions.contains('System.Administrator') == true;

    if (isAdmin || perms.contains(permission)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
