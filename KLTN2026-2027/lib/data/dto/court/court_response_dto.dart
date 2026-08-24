class CourtResponseDto {
  final String id;
  final String? venueId;
  final String name;
  final String description;
  final double pricePerHour;
  final bool isAvailable;

  CourtResponseDto({
    required this.id,
    this.venueId,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.isAvailable,
  });

  factory CourtResponseDto.fromJson(Map<String, dynamic> json) {
    return CourtResponseDto(
      id: (json['id'] as String?) ?? '',
      venueId: json['venueId'] as String?,
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      pricePerHour: _parseDouble(json['pricePerHour']),
      isAvailable: _parseBool(json['isAvailable']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
