import 'sport_type_dto.dart';

class VenueRecommendationResponseDto {
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
  final List<SportTypeDto> sportTypes;
  final double recommendationScore;
  final bool isFavourite;

  VenueRecommendationResponseDto({
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

  factory VenueRecommendationResponseDto.fromJson(dynamic rawJson) {
    if (rawJson is! Map) {
      return VenueRecommendationResponseDto(
        idVenue: '',
        nameVenue: '',
        address: '',
        latitude: 0.0,
        longitude: 0.0,
        averageRating: 0.0,
        reviewCount: 0,
        favouriteCount: 0,
        sportTypes: [],
        recommendationScore: 0.0,
        isFavourite: false,
      );
    }

    final json = rawJson;
    final rawSportTypes = json['sportTypes'];
    final List<SportTypeDto> sportTypesList = (rawSportTypes is List)
        ? rawSportTypes.map((item) => SportTypeDto.fromJson(item)).toList()
        : [];

    return VenueRecommendationResponseDto(
      idVenue: (json['idVenue'] as String?) ?? '',
      nameVenue: (json['nameVenue'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      primaryImageUrl: json['primaryImageUrl'] as String?,
      distanceKm: _parseDoubleOrNull(json['distanceKm']),
      averageRating: _parseDouble(json['averageRating']),
      reviewCount: _parseInt(json['reviewCount']),
      favouriteCount: _parseInt(json['favouriteCount']),
      minPricePerHour: _parseDoubleOrNull(json['minPricePerHour']),
      sportTypes: sportTypesList,
      recommendationScore: _parseDouble(json['recommendationScore']),
      isFavourite: _parseBool(json['isFavourite']),
    );
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double? _parseDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }
}
