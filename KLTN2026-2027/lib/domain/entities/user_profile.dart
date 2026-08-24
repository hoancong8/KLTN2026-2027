class UserProfile {
  final String id;
  final String email;
  final String userName;
  final String? phoneNumber;
  final bool isLocked;
  final DateTime? lockoutEnd;
  final List<String> roles;
  final List<String> permissions;

  const UserProfile({
    required this.id,
    required this.email,
    required this.userName,
    this.phoneNumber,
    required this.isLocked,
    this.lockoutEnd,
    required this.roles,
    required this.permissions,
  });
}
