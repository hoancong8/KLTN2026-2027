import '../entities/paged_response.dart';
import '../entities/venue.dart';
import '../entities/venue_recommendation.dart';

abstract class VenueRepository {
  Future<PagedResponse<Venue>> getVenues({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? isActive,
  });
  Future<Venue> getVenueById(String id);
  Future<String> createVenue(Venue venue);
  Future<void> updateVenue(String id, Venue venue);
  Future<void> deleteVenue(String id);
  Future<PagedResponse<VenueRecommendation>> getVenueRecommendations({
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
