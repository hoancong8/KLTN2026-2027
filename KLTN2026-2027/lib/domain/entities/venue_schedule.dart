class VenueSchedule {
  final String id;
  final String venueId;
  final int dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  const VenueSchedule({
    required this.id,
    required this.venueId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });
}
