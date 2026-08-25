// lib/app/consts/permissions.dart

abstract class Permissions {
  static const String systemAdministrator = 'System.Administrator';

  // ===== Roles =====
  static const String rolesRead = 'Roles.Read';
  static const String rolesCreate = 'Roles.Create';
  static const String rolesUpdate = 'Roles.Update';
  static const String rolesDelete = 'Roles.Delete';
  static const String rolesAssignPermissions = 'Roles.AssignPermissions';

  // ===== Users =====
  static const String usersRead = 'Users.Read';
  static const String usersCreate = 'Users.Create';
  static const String usersUpdate = 'Users.Update';
  static const String usersDelete = 'Users.Delete';
  static const String usersLock = 'Users.Lock';
  static const String usersAssignRoles = 'Users.AssignRoles';
  static const String usersResetPassword = 'Users.ResetPassword';

  // ===== Venues =====
  static const String venuesRead = 'Venues.Read';
  static const String venuesCreate = 'Venues.Create';
  static const String venuesUpdate = 'Venues.Update';
  static const String venuesDelete = 'Venues.Delete';

  // ===== Courts =====
  static const String courtsRead = 'Courts.Read';
  static const String courtsCreate = 'Courts.Create';
  static const String courtsUpdate = 'Courts.Update';
  static const String courtsDelete = 'Courts.Delete';

  // ===== VenueSchedules =====
  static const String venueSchedulesRead = 'VenueSchedules.Read';
  static const String venueSchedulesCreate = 'VenueSchedules.Create';
  static const String venueSchedulesUpdate = 'VenueSchedules.Update';
  static const String venueSchedulesDelete = 'VenueSchedules.Delete';

  // ===== CourtPricings =====
  static const String courtPricingsRead = 'CourtPricings.Read';
  static const String courtPricingsCreate = 'CourtPricings.Create';
  static const String courtPricingsUpdate = 'CourtPricings.Update';
  static const String courtPricingsDelete = 'CourtPricings.Delete';
}
