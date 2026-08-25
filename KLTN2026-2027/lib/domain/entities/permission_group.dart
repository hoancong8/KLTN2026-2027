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
  final List<PermissionItem> permissions;

  const PermissionGroup({
    required this.name,
    required this.displayName,
    required this.permissions,
  });
}
