// lib/domain/entities/club/my_club.dart

import '../../enums/club_member_status.dart';
import '../../enums/club_role.dart';

/// Đại diện cho Câu lạc bộ mà tài khoản người dùng đang tham gia
/// kèm theo vai trò và trạng thái độc lập của họ trong CLB đó.
class MyClub {
  final String clubId;
  final String clubName;
  final String clubCode;
  final String? description;
  final String? avatarUrl;
  final ClubRole role;
  final String? roleName;
  final String? roleId;
  final ClubMemberStatus status;
  final DateTime? joinedAt;
  final List<String> permissions;

  const MyClub({
    required this.clubId,
    required this.clubName,
    required this.clubCode,
    this.description,
    this.avatarUrl,
    required this.role,
    this.roleName,
    this.roleId,
    required this.status,
    this.joinedAt,
    this.permissions = const [],
  });

  /// Kiểm tra xem CLB hiện tại có quyền hạn cụ thể hay không
  bool hasPermission(String permissionCode) =>
      permissions.contains(permissionCode);

  /// Kiểm tra có ít nhất một trong các quyền
  bool hasAnyPermission(Iterable<String> permissionCodes) =>
      permissionCodes.any(permissions.contains);

  /// Kiểm tra có toàn bộ các quyền yêu cầu
  bool hasAllPermissions(Iterable<String> permissionCodes) =>
      permissionCodes.every(permissions.contains);
}
