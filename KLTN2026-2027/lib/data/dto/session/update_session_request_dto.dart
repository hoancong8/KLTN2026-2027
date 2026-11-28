// lib/data/dto/session/update_session_request_dto.dart

class UpdateSessionRequestDto {
  final String title;
  final String startTime;
  final String endTime;
  final String courtLocation;
  final int courtCount;
  final int maxPlayers;
  final String deadlineBooking;
  final int? minimumPlayers;
  final int? shortageCheckMinutes;
  final bool? advanceEnabled;
  final int? advanceAmount;

  UpdateSessionRequestDto({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    required this.courtCount,
    required this.maxPlayers,
    required this.deadlineBooking,
    this.minimumPlayers,
    this.shortageCheckMinutes,
    this.advanceEnabled,
    this.advanceAmount,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    if (minimumPlayers != null) 'minimumPlayers': minimumPlayers,
    if (shortageCheckMinutes != null) 'shortageCheckMinutes': shortageCheckMinutes,
    if (advanceEnabled != null) 'advanceEnabled': advanceEnabled,
    if (advanceAmount != null) 'advanceAmount': advanceAmount,
    'courtLocation': courtLocation,
    'courtCount': courtCount,
    'maxPlayers': maxPlayers,
    'deadlineBooking': deadlineBooking,
  };
}
