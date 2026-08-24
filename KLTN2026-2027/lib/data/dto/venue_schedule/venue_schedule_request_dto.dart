class VenueScheduleCreateRequestDto {
  final String venueId;
  final int dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  VenueScheduleCreateRequestDto({
    required this.venueId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  Map<String, dynamic> toJson() {
    return {
      'venueId': venueId,
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}

class VenueScheduleUpdateRequestDto {
  final String openTime;
  final String closeTime;
  final bool isClosed;

  VenueScheduleUpdateRequestDto({
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  Map<String, dynamic> toJson() {
    return {
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}
