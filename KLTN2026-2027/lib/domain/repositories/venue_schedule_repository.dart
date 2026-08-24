import '../entities/paged_response.dart';
import '../entities/venue_schedule.dart';

abstract class VenueScheduleRepository {
  Future<PagedResponse<VenueSchedule>> getVenueSchedules({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  });
  Future<void> createVenueSchedule(VenueSchedule schedule);
  Future<void> updateVenueSchedule(String id, String openTime, String closeTime, bool isClosed);
  Future<void> deleteVenueSchedule(String id);
}
