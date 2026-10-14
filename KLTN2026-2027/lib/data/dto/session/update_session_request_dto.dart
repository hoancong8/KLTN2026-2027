// lib/data/dto/session/update_session_request_dto.dart

class UpdateSessionRequestDto {
  final String title;
  final String startTime;
  final String endTime;
  final String courtLocation;
  final int courtCount;
  final int maxPlayers;
  final String deadlineBooking;

  UpdateSessionRequestDto({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    required this.courtCount,
    required this.maxPlayers,
    required this.deadlineBooking,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'courtLocation': courtLocation,
    'courtCount': courtCount,
    'maxPlayers': maxPlayers,
    'deadlineBooking': deadlineBooking,
  };
}
