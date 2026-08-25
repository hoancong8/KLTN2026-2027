class UserPermissions {
  final String userId;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  const UserPermissions({
    required this.userId,
    required this.email,
    required this.roles,
    required this.permissions,
  });
}
