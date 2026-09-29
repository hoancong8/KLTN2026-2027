import '../../entities/paged_response.dart';
import '../../entities/venue_recommendation.dart';
import '../../repositories/venue_repository.dart';

class GetVenueRecommendationsUseCase {
  final VenueRepository repository;

  GetVenueRecommendationsUseCase(this.repository);

  Future<PagedResponse<VenueRecommendation>> execute({
    double? latitude,
    double? longitude,
    double maxDistanceKm = 20.0,
    String? sportTypeId,
    DateTime? date,
    String? startTime,
    String? endTime,
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return repository.getVenueRecommendations(
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
      sportTypeId: sportTypeId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
