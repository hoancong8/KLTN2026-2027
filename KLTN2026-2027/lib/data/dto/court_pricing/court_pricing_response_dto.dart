class CourtPricingResponseDto {
  final String id;
  final String venueId;
  final String startTime;
  final String endTime;
  final double pricePerHour;
  final int dayOfWeek;
  final bool isPeakHour;

  CourtPricingResponseDto({
    required this.id,
    required this.venueId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.dayOfWeek,
    required this.isPeakHour,
  });

  factory CourtPricingResponseDto.fromJson(Map<String, dynamic> json) {
    return CourtPricingResponseDto(
      id: (json['id'] as String?) ?? '',
      venueId: (json['venueId'] as String?) ?? '',
      startTime: (json['startTime'] as String?) ?? '00:00:00',
      endTime: (json['endTime'] as String?) ?? '23:59:59',
      pricePerHour: _parseDouble(json['pricePerHour']),
      dayOfWeek: _parseInt(json['dayOfWeek']),
      isPeakHour: _parseBool(json['isPeakHour']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
