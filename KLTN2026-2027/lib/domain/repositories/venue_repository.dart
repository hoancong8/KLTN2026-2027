import '../entities/paged_response.dart';
import '../entities/venue.dart';

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
}
