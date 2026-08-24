import '../../entities/paged_response.dart';
import '../../entities/venue_schedule.dart';
import '../../repositories/venue_schedule_repository.dart';

class GetVenueSchedulesUseCase {
  final VenueScheduleRepository repository;
  GetVenueSchedulesUseCase(this.repository);

  Future<PagedResponse<VenueSchedule>> execute({
    String? venueId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return repository.getVenueSchedules(
      venueId: venueId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
