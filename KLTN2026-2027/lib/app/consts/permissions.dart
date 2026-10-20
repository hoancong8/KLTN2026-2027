// lib/app/consts/permissions.dart

/// Hằng số phân quyền tập trung cho toàn ứng dụng.
/// Đồng bộ 100% với hệ thống phân quyền Backend:
/// LegendsTeamVN.Core.Identity.Authorization.AppPermissions
abstract class Permissions {
  // ===== 1. Nhóm Quản trị hệ thống (System) =====
  static const String system = 'System';
  static const String systemAdministrator = 'System.Administrator';

  // --- Vai trò & Quyền hạn (Roles) ---
  static const String roles = 'Roles';
  static const String rolesRead = 'Roles.Read';
  static const String rolesCreate = 'Roles.Create';
  static const String rolesUpdate = 'Roles.Update';
  static const String rolesDelete = 'Roles.Delete';
  static const String rolesAssignPermissions = 'Roles.AssignPermissions';

  // --- Tài khoản người dùng (Users) ---
  static const String users = 'Users';
  static const String usersRead = 'Users.Read';
  static const String usersCreate = 'Users.Create';
  static const String usersUpdate = 'Users.Update';
  static const String usersDelete = 'Users.Delete';
  static const String usersLock = 'Users.Lock';
  static const String usersAssignRoles = 'Users.AssignRoles';
  static const String usersResetPassword = 'Users.ResetPassword';

  // ===== 2. Nhóm Quản lý Câu lạc bộ (Clubs - System Level) =====
  static const String clubs = 'Clubs';
  static const String clubsRead = 'Clubs.Read';
  static const String clubsCreate = 'Clubs.Create';
  static const String clubsUpdate = 'Clubs.Update';
  static const String clubsDelete = 'Clubs.Delete';
  static const String clubsManageMembers = 'Clubs.ManageMembers';
}

/// Hằng số mã quyền hạn trong Câu lạc bộ (Contextual Club Permissions).
/// Trả về trong mảng `permissions` của `GET /api/v1/clubs/my-clubs`.
abstract class ClubPermissions {
  // ===== Operations (Vận hành & Buổi tập) =====
  static const String scheduleManage = 'OPERATIONS.SCHEDULE.MANAGE';
  static const String sessionView = 'OPERATIONS.SESSION.VIEW';
  static const String sessionCreate = 'OPERATIONS.SESSION.CREATE';
  static const String sessionUpdate = 'OPERATIONS.SESSION.UPDATE';
  static const String sessionDelete = 'OPERATIONS.SESSION.DELETE';
  static const String bookingManage = 'OPERATIONS.BOOKING.MANAGE';
  static const String matchManage = 'OPERATIONS.MATCH.MANAGE';
  static const String recruitManage = 'OPERATIONS.RECRUIT.MANAGE';

  // ===== Finance (Thu chi & Quỹ CLB) =====
  static const String ledgerView = 'FINANCE.LEDGER.VIEW';
  static const String ledgerManage = 'FINANCE.LEDGER.MANAGE';
  static const String feeView = 'FINANCE.FEE.VIEW';
  static const String feeManage = 'FINANCE.FEE.MANAGE';
  static const String bankManage = 'FINANCE.BANK.MANAGE';

  // ===== Member (Thành viên & Cấu hình nhóm) =====
  static const String memberView = 'MEMBER.VIEW';
  static const String joinRequestManage = 'MEMBER.JOIN_REQUEST.MANAGE';
  static const String roleManage = 'MEMBER.ROLE.MANAGE';
  static const String memberRemove = 'MEMBER.REMOVE';
  static const String memberInfoUpdate = 'MEMBER.INFO.UPDATE';
}

/// Alias dùng chung tương thích
typedef AppPermissions = Permissions;
