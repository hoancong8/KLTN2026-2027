class VenueRequestDto {
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String openTime;
  final String closeTime;

  VenueRequestDto({
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }
}
