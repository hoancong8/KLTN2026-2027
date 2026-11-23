// lib/domain/entities/club/club_schedule_defaults.dart

class ClubScheduleDefaults {
  final int courtCount;
  final double courtRentalCost;

  const ClubScheduleDefaults({
    this.courtCount = 1,
    this.courtRentalCost = 0.0,
  });
}
