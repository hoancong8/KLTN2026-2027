import 'permission_group.dart';

class AppRole {
  final String id;
  final String name;
  final String description;
  final List<PermissionGroup> permissions;

  const AppRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });
}
