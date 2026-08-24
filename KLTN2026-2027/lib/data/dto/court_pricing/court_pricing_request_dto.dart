class CourtPricingCreateRequestDto {
  final String venueId;
  final String startTime;
  final String endTime;
  final double pricePerHour;
  final int dayOfWeek;
  final bool isPeakHour;

  CourtPricingCreateRequestDto({
    required this.venueId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.dayOfWeek,
    required this.isPeakHour,
  });

  Map<String, dynamic> toJson() {
    return {
      'venueId': venueId,
      'startTime': startTime,
      'endTime': endTime,
      'pricePerHour': pricePerHour,
      'dayOfWeek': dayOfWeek,
      'isPeakHour': isPeakHour,
    };
  }
}

class CourtPricingUpdateRequestDto {
  final String startTime;
  final String endTime;
  final double pricePerHour;
  final int dayOfWeek;
  final bool isPeakHour;

  CourtPricingUpdateRequestDto({
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.dayOfWeek,
    required this.isPeakHour,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'pricePerHour': pricePerHour,
      'dayOfWeek': dayOfWeek,
      'isPeakHour': isPeakHour,
    };
  }
}
