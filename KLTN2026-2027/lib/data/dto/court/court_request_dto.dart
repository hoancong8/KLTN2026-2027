class CourtCreateRequestDto {
  final String name;
  final String description;
  final double pricePerHour;

  CourtCreateRequestDto({
    required this.name,
    required this.description,
    required this.pricePerHour,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
    };
  }
}

class CourtUpdateRequestDto {
  final String name;
  final String description;
  final double pricePerHour;
  final bool isAvailable;

  CourtUpdateRequestDto({
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
      'isAvailable': isAvailable,
    };
  }
}
