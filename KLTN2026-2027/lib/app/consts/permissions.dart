// lib/app/consts/permissions.dart

abstract class Permissions {
  static const String systemAdministrator = 'System.Administrator';

  // Courts
  static const String courtsCreate = 'Courts.Create';
  static const String courtsUpdate = 'Courts.Update';
  static const String courtsDelete = 'Courts.Delete';
  static const String courtsRead = 'Courts.Read';

  // Venues
  static const String venuesCreate = 'Venues.Create';
  static const String venuesUpdate = 'Venues.Update';
  static const String venuesDelete = 'Venues.Delete';
  static const String venuesRead = 'Venues.Read';

  // VenueSchedules
  static const String venueSchedulesCreate = 'VenueSchedules.Create';
  static const String venueSchedulesUpdate = 'VenueSchedules.Update';
  static const String venueSchedulesDelete = 'VenueSchedules.Delete';
  static const String venueSchedulesRead = 'VenueSchedules.Read';

  // CourtPricings
  static const String courtPricingsCreate = 'CourtPricings.Create';
  static const String courtPricingsUpdate = 'CourtPricings.Update';
  static const String courtPricingsDelete = 'CourtPricings.Delete';
  static const String courtPricingsRead = 'CourtPricings.Read';
}
