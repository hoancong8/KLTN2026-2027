import '../../entities/venue_schedule.dart';
import '../../repositories/venue_schedule_repository.dart';

class ManageVenueScheduleUseCase {
  final VenueScheduleRepository repository;
  ManageVenueScheduleUseCase(this.repository);

  Future<void> create(VenueSchedule schedule) => repository.createVenueSchedule(schedule);
  Future<void> update(String id, String openTime, String closeTime, bool isClosed) {
    return repository.updateVenueSchedule(id, openTime, closeTime, isClosed);
  }
  Future<void> delete(String id) => repository.deleteVenueSchedule(id);
}
