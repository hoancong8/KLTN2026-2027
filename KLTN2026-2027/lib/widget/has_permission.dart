import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider.dart';

/// Widget phân quyền giao diện dùng chung (Permission Guard Component).
///
/// Hỗ trợ kiểm tra:
/// 1. Một quyền duy nhất: [permission]
/// 2. Có ít nhất một trong các quyền (OR): [anyPermissions]
/// 3. Bắt buộc có đầy đủ tất cả quyền (AND): [allPermissions]
///
/// Tự động hỗ trợ Admin Bypass (tài khoản Admin tự động xem được toàn bộ).
class HasPermission extends ConsumerWidget {
  final String? permission;
  final List<String>? anyPermissions;
  final List<String>? allPermissions;
  final Widget child;
  final Widget? fallback;

  const HasPermission({
    super.key,
    this.permission,
    this.anyPermissions,
    this.allPermissions,
    required this.child,
    this.fallback,
  }) : assert(
          permission != null || anyPermissions != null || allPermissions != null,
          'HasPermission cần ít nhất một trong các tham số: permission, anyPermissions hoặc allPermissions',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isAllowed = false;

    if (permission != null) {
      isAllowed = ref.watch(hasPermissionProvider(permission!));
    } else if (anyPermissions != null && anyPermissions!.isNotEmpty) {
      isAllowed = anyPermissions!.any((p) => ref.watch(hasPermissionProvider(p)));
    } else if (allPermissions != null && allPermissions!.isNotEmpty) {
      isAllowed = allPermissions!.every((p) => ref.watch(hasPermissionProvider(p)));
    }

    if (isAllowed) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
