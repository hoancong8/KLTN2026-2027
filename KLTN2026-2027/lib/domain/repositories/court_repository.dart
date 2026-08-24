import '../entities/court.dart';
import '../entities/paged_response.dart';

abstract class CourtRepository {
  Future<PagedResponse<Court>> getCourts({
    String? venueId,
    bool? isAvailable,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> createCourt(Court court);
  Future<void> updateCourt(String id, Court court);
  Future<void> deleteCourt(String id);
}
