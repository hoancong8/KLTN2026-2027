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

  // ===== 2. Nhóm Quản lý Câu lạc bộ (Clubs) =====
  static const String clubs = 'Clubs';
  static const String clubsRead = 'Clubs.Read';
  static const String clubsCreate = 'Clubs.Create';
  static const String clubsUpdate = 'Clubs.Update';
  static const String clubsDelete = 'Clubs.Delete';
  static const String clubsManageMembers = 'Clubs.ManageMembers';
}

/// Alias dùng chung tương thích
typedef AppPermissions = Permissions;
