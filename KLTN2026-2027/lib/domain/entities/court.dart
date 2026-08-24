class Court {
  final String id;
  final String? venueId;
  final String name;
  final String description;
  final double pricePerHour;
  final bool isAvailable;

  const Court({
    required this.id,
    this.venueId,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.isAvailable,
  });
}
