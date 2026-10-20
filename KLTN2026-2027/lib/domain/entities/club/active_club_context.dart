// lib/domain/entities/club/active_club_context.dart

import '../../enums/club_role.dart';

/// Ngữ cảnh Câu lạc bộ đang hoạt động hiện tại (Active Context).
/// Quản lý vai trò và phân quyền độc lập theo Header HTTP `X-Group-Id`.
class ActiveClubContext {
  final String clubId;
  final String clubName;
  final ClubRole role;
  final String? roleName;
  final String? roleId;
  final List<String> permissions;

  /// AccessToken toàn cục được giữ nguyên theo kiến trúc Clean Context-Based Auth;
  /// trường này giữ lại với giá trị mặc định để đảm bảo tương thích ngược hoàn toàn.
  final String accessToken;

  const ActiveClubContext({
    required this.clubId,
    required this.clubName,
    required this.role,
    this.roleName,
    this.roleId,
    required this.permissions,
    this.accessToken = '',
  });

  /// Kiểm tra một quyền hạn cụ thể trong CLB đang kích hoạt
  bool hasPermission(String permissionCode) =>
      permissions.contains(permissionCode);

  /// Kiểm tra có ít nhất một trong các quyền
  bool hasAnyPermission(Iterable<String> permissionCodes) =>
      permissionCodes.any(permissions.contains);

  /// Kiểm tra có toàn bộ các quyền yêu cầu
  bool hasAllPermissions(Iterable<String> permissionCodes) =>
      permissionCodes.every(permissions.contains);

  ActiveClubContext copyWith({
    String? accessToken,
    String? clubId,
    String? clubName,
    ClubRole? role,
    String? roleName,
    String? roleId,
    List<String>? permissions,
  }) {
    return ActiveClubContext(
      accessToken: accessToken ?? this.accessToken,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      roleId: roleId ?? this.roleId,
      permissions: permissions ?? this.permissions,
    );
  }
}
