import '../../domain/entities/paged_response.dart';
import '../../domain/entities/sport_type.dart';
import '../../domain/entities/venue.dart';
import '../../domain/entities/venue_recommendation.dart';
import '../dto/common/paged_result_dto.dart';
import '../dto/venue/sport_type_dto.dart';
import '../dto/venue/venue_recommendation_response_dto.dart';
import '../dto/venue/venue_request_dto.dart';
import '../dto/venue/venue_response_dto.dart';

class VenueMapper {
  static Venue toEntity(VenueResponseDto dto) {
    return Venue(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      address: dto.address,
      latitude: dto.latitude,
      longitude: dto.longitude,
      openTime: dto.openTime,
      closeTime: dto.closeTime,
      isActive: dto.isActive,
    );
  }

  static VenueRequestDto toDto(Venue entity) {
    return VenueRequestDto(
      name: entity.name,
      description: entity.description,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
    );
  }

  static PagedResponse<Venue> toPagedEntity(PagedResultDto<VenueResponseDto> dto) {
    return PagedResponse<Venue>(
      items: dto.items.map((e) => toEntity(e)).toList(),
      totalCount: dto.totalCount,
      pageNumber: dto.pageNumber,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
      hasPreviousPage: dto.hasPreviousPage,
      hasNextPage: dto.hasNextPage,
    );
  }

  static SportType toSportTypeEntity(SportTypeDto dto) {
    return SportType(
      id: dto.id,
      name: dto.name,
    );
  }

  static VenueRecommendation toRecommendationEntity(VenueRecommendationResponseDto dto) {
    return VenueRecommendation(
      idVenue: dto.idVenue,
      nameVenue: dto.nameVenue,
      address: dto.address,
      latitude: dto.latitude,
      longitude: dto.longitude,
      primaryImageUrl: dto.primaryImageUrl,
      distanceKm: dto.distanceKm,
      averageRating: dto.averageRating,
      reviewCount: dto.reviewCount,
      favouriteCount: dto.favouriteCount,
      minPricePerHour: dto.minPricePerHour,
      sportTypes: dto.sportTypes.map((s) => toSportTypeEntity(s)).toList(),
      recommendationScore: dto.recommendationScore,
      isFavourite: dto.isFavourite,
    );
  }

  static PagedResponse<VenueRecommendation> toPagedRecommendationEntity(
    PagedResultDto<VenueRecommendationResponseDto> dto,
  ) {
    return PagedResponse<VenueRecommendation>(
      items: dto.items.map((e) => toRecommendationEntity(e)).toList(),
      totalCount: dto.totalCount,
      pageNumber: dto.pageNumber,
      pageSize: dto.pageSize,
      totalPages: dto.totalPages,
      hasPreviousPage: dto.hasPreviousPage,
      hasNextPage: dto.hasNextPage,
    );
  }
}
