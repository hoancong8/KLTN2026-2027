class UserPermissionsResponseDto {
  final String userId;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  UserPermissionsResponseDto({
    required this.userId,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  factory UserPermissionsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = (rawRoles is List)
        ? rawRoles.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final permissions = _extractPermissions(json['permissions']);

    return UserPermissionsResponseDto(
      userId: (json['userId'] as String?) ?? (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      roles: roles,
      permissions: permissions,
    );
  }

  /// Trích xuất đệ quy tất cả tên nhóm cha, nhóm con và tên quyền (permissions) từ cây phân quyền
  static List<String> _extractPermissions(dynamic data) {
    final List<String> result = [];
    if (data == null) return result;

    void traverse(dynamic node) {
      if (node is String) {
        if (node.isNotEmpty) result.add(node);
      } else if (node is List) {
        for (final item in node) {
          traverse(item);
        }
      } else if (node is Map) {
        final name = node['name'];
        final permissions = node['permissions'];
        final children = node['children'];

        // Lấy tên của node hiện tại (bao gồm cả nhóm cha, nhóm con, và quyền lá)
        if (name is String && name.isNotEmpty) {
          result.add(name);
        }

        if (children != null) {
          traverse(children);
        }
        if (permissions != null) {
          traverse(permissions);
        }
      }
    }

    traverse(data);
    return result.toSet().toList();
  }
}
