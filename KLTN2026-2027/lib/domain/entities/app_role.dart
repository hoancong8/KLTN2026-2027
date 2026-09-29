import 'permission_group.dart';

class AppRole {
  final String id;
  final String name;
  final String description;
  final bool isDefault;
  final bool isStatic;
  final List<PermissionGroup> permissions;

  const AppRole({
    required this.id,
    required this.name,
    required this.description,
    this.isDefault = false,
    this.isStatic = false,
    required this.permissions,
  });

  /// Trích xuất toàn bộ tên các quyền đã được gán cho vai trò này
  List<String> get assignedPermissionNames {
    final List<String> list = [];
    for (final group in permissions) {
      list.addAll(group.allPermissionNames);
    }
    return list.toSet().toList();
  }
}
