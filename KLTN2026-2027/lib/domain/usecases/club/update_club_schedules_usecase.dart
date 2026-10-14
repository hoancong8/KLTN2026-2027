import '../../entities/club/club_detail.dart';
import '../../repositories/club_repository.dart';

class UpdateClubSchedulesUseCase {
  final ClubRepository repository;
  UpdateClubSchedulesUseCase(this.repository);

  Future<void> execute(String clubId, List<ClubScheduleInput> schedules) {
    return repository.updateClubSchedules(clubId, schedules);
  }
}
