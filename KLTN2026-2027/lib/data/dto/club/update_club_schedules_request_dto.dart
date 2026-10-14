class ClubScheduleItemRequestDto {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  ClubScheduleItemRequestDto({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
  };
}

class UpdateClubSchedulesRequestDto {
  final List<ClubScheduleItemRequestDto> schedules;

  UpdateClubSchedulesRequestDto({required this.schedules});

  Map<String, dynamic> toJson() => {
    'schedules': schedules.map((e) => e.toJson()).toList(),
  };
}
