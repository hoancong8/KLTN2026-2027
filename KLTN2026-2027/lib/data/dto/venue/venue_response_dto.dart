class VenueResponseDto {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String openTime;
  final String closeTime;
  final bool isActive;

  VenueResponseDto({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
    required this.isActive,
  });

  factory VenueResponseDto.fromJson(Map<String, dynamic> json) {
    return VenueResponseDto(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      openTime: (json['openTime'] as String?) ?? '06:00:00',
      closeTime: (json['closeTime'] as String?) ?? '22:00:00',
      isActive: _parseBool(json['isActive']),
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
