// lib/data/dto/session/create_session_request_dto.dart

class CreateSessionRequestDto {
  final String title;
  final String startTime;
  final String endTime;
  final String courtLocation;
  final int courtCount;
  final int targetPlayerPerCourt;
  final int? maxPlayers;
  final String? deadlineBooking;
  final double courtRentalCost;

  CreateSessionRequestDto({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    this.courtCount = 1,
    this.targetPlayerPerCourt = 6,
    this.maxPlayers,
    this.deadlineBooking,
    this.courtRentalCost = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'courtLocation': courtLocation,
    'courtCount': courtCount,
    'targetPlayerPerCourt': targetPlayerPerCourt,
    if (maxPlayers != null) 'maxPlayers': maxPlayers,
    if (deadlineBooking != null) 'deadlineBooking': deadlineBooking,
    'courtRentalCost': courtRentalCost,
  };
}
