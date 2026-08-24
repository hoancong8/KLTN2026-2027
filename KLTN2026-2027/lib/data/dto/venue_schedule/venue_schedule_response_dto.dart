class VenueScheduleResponseDto {
  final String id;
  final String venueId;
  final int dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  VenueScheduleResponseDto({
    required this.id,
    required this.venueId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory VenueScheduleResponseDto.fromJson(Map<String, dynamic> json) {
    return VenueScheduleResponseDto(
      id: (json['id'] as String?) ?? '',
      venueId: (json['venueId'] as String?) ?? '',
      dayOfWeek: _parseInt(json['dayOfWeek']),
      openTime: (json['openTime'] as String?) ?? '06:00:00',
      closeTime: (json['closeTime'] as String?) ?? '22:00:00',
      isClosed: _parseBool(json['isClosed']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
