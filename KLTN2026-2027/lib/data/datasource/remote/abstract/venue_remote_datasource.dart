import '../../../dto/common/paged_result_dto.dart';
import '../../../dto/venue/venue_recommendation_response_dto.dart';
import '../../../dto/venue/venue_request_dto.dart';
import '../../../dto/venue/venue_response_dto.dart';

abstract class VenueRemoteDatasource {
  Future<PagedResultDto<VenueResponseDto>> getVenues({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? isActive,
  });
  Future<VenueResponseDto> getVenueById(String id);
  Future<String> createVenue(VenueRequestDto request);
  Future<void> updateVenue(String id, VenueRequestDto request);
  Future<void> deleteVenue(String id);
  Future<PagedResultDto<VenueRecommendationResponseDto>> getVenueRecommendations({
    double? latitude,
    double? longitude,
    double maxDistanceKm = 20.0,
    String? sportTypeId,
    DateTime? date,
    String? startTime,
    String? endTime,
    int pageNumber = 1,
    int pageSize = 20,
  });
}
