// lib/data/dto/session/session_dto.dart

class SessionDto {
  final String id;
  final String groupId;
  final String clubName;
  final String title;
  final String startTime;
  final String endTime;
  final String courtLocation;
  final int courtCount;
  final int targetPlayerPerCourt;
  final int maxPlayers;
  final String deadlineBooking;
  final double courtRentalCost;
  final String status;
  final int confirmedCount;
  final int waitingCount;
  final bool isBookedByCurrentUser;
  final String? currentUserBookingStatus;
  final int currentUserQueueOrder;

  SessionDto({
    required this.id,
    required this.groupId,
    required this.clubName,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.courtLocation,
    required this.courtCount,
    required this.targetPlayerPerCourt,
    required this.maxPlayers,
    required this.deadlineBooking,
    required this.courtRentalCost,
    required this.status,
    required this.confirmedCount,
    required this.waitingCount,
    this.isBookedByCurrentUser = false,
    this.currentUserBookingStatus,
    this.currentUserQueueOrder = 0,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      clubName: json['clubName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      courtLocation: json['courtLocation']?.toString() ?? '',
      courtCount: _parseInt(json['courtCount']),
      targetPlayerPerCourt: _parseInt(json['targetPlayerPerCourt']),
      maxPlayers: _parseInt(json['maxPlayers']),
      deadlineBooking: json['deadlineBooking']?.toString() ?? '',
      courtRentalCost: _parseDouble(json['courtRentalCost']),
      status: json['status']?.toString() ?? '1',
      confirmedCount: _parseInt(json['confirmedCount']),
      waitingCount: _parseInt(json['waitingCount']),
      isBookedByCurrentUser: _parseBool(json['isBookedByCurrentUser']),
      currentUserBookingStatus: json['currentUserBookingStatus']?.toString(),
      currentUserQueueOrder: _parseInt(json['currentUserQueueOrder']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'clubName': clubName,
    'title': title,
    'startTime': startTime,
    'endTime': endTime,
    'courtLocation': courtLocation,
    'courtCount': courtCount,
    'targetPlayerPerCourt': targetPlayerPerCourt,
    'maxPlayers': maxPlayers,
    'deadlineBooking': deadlineBooking,
    'courtRentalCost': courtRentalCost,
    'status': status,
    'confirmedCount': confirmedCount,
    'waitingCount': waitingCount,
    'isBookedByCurrentUser': isBookedByCurrentUser,
    'currentUserBookingStatus': currentUserBookingStatus,
    'currentUserQueueOrder': currentUserQueueOrder,
  };
}
