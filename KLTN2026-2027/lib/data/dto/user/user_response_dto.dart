class UserResponseDto {
  final String id;
  final String email;
  final String userName;
  final String? phoneNumber;
  final bool isLocked;
  final String? lockoutEnd;
  final List<String> roles;
  final List<String> permissions;

  UserResponseDto({
    required this.id,
    required this.email,
    required this.userName,
    this.phoneNumber,
    required this.isLocked,
    this.lockoutEnd,
    required this.roles,
    required this.permissions,
  });

  factory UserResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return UserResponseDto(
        id: '',
        email: '',
        userName: '',
        phoneNumber: null,
        isLocked: false,
        lockoutEnd: null,
        roles: const [],
        permissions: const [],
      );
    }

    final rawRoles = rawJson['roles'];
    final roles = (rawRoles is List)
        ? rawRoles.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final permissions = _extractPermissions(rawJson['permissions']);

    return UserResponseDto(
      id: rawJson['id']?.toString() ?? '',
      email: rawJson['email']?.toString() ?? '',
      userName: rawJson['userName']?.toString() ?? '',
      phoneNumber: rawJson['phoneNumber']?.toString(),
      isLocked: _parseBool(rawJson['isLocked']),
      lockoutEnd: rawJson['lockoutEnd']?.toString(),
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

        // 1. Duyệt xuống nhóm con (children) nếu có
        if (children != null) {
          traverse(children);
        }

        // 2. Duyệt xuống danh sách quyền con (permissions) nếu có
        if (permissions != null) {
          traverse(permissions);
        }
      }
    }

    traverse(data);
    return result.toSet().toList();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
