class CourtPricing {
  final String id;
  final String venueId;
  final String startTime;
  final String endTime;
  final double pricePerHour;
  final int dayOfWeek;
  final bool isPeakHour;

  const CourtPricing({
    required this.id,
    required this.venueId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.dayOfWeek,
    required this.isPeakHour,
  });
}
