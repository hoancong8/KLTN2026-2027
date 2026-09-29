import 'sport_type.dart';

class VenueRecommendation {
  final String idVenue;
  final String nameVenue;
  final String address;
  final double latitude;
  final double longitude;
  final String? primaryImageUrl;
  final double? distanceKm;
  final double averageRating;
  final int reviewCount;
  final int favouriteCount;
  final double? minPricePerHour;
  final List<SportType> sportTypes;
  final double recommendationScore;
  final bool isFavourite;

  const VenueRecommendation({
    required this.idVenue,
    required this.nameVenue,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.primaryImageUrl,
    this.distanceKm,
    required this.averageRating,
    required this.reviewCount,
    required this.favouriteCount,
    this.minPricePerHour,
    required this.sportTypes,
    required this.recommendationScore,
    required this.isFavourite,
  });
}
