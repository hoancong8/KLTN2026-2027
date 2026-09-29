class PermissionItem {
  final String name;
  final String displayName;

  const PermissionItem({
    required this.name,
    required this.displayName,
  });
}

class PermissionGroup {
  final String name;
  final String displayName;
  final List<PermissionGroup> children;
  final List<PermissionItem> permissions;

  const PermissionGroup({
    required this.name,
    required this.displayName,
    this.children = const [],
    this.permissions = const [],
  });

  /// Trích xuất toàn bộ tên quyền (leaf permissions) thuộc nhóm này và các nhóm con
  List<String> get allPermissionNames {
    final List<String> list = permissions.map((p) => p.name).toList();
    for (final child in children) {
      list.addAll(child.allPermissionNames);
    }
    return list;
  }
}
