// lib/data/dto/session/guest_recruitment_dto.dart

class GuestRecruitmentDto {
  final String id;
  final String sessionId;
  final String clubName;
  final String courtLocation;
  final String startTime;
  final String endTime;
  final int slotsNeeded;
  final int slotsRemaining;
  final String minSkillLevel;
  final double sharedCost;
  final double scanRadiusKm;
  final String status;
  final String broadcastAt;
  final double? distanceKm;
  final bool hidePlayerList;
  final double? femaleDiscount;
  final double? femaleSharedCost;

  GuestRecruitmentDto({
    required this.id,
    required this.sessionId,
    required this.clubName,
    required this.courtLocation,
    required this.startTime,
    required this.endTime,
    required this.slotsNeeded,
    required this.slotsRemaining,
    required this.minSkillLevel,
    required this.sharedCost,
    required this.scanRadiusKm,
    required this.status,
    required this.broadcastAt,
    this.distanceKm,
    this.hidePlayerList = false,
    this.femaleDiscount,
    this.femaleSharedCost,
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
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value == 1;
    return false;
  }

  factory GuestRecruitmentDto.fromJson(Map<String, dynamic> json) {
    return GuestRecruitmentDto(
      id: json['id']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      clubName: json['clubName']?.toString() ?? '',
      courtLocation: json['courtLocation']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      slotsNeeded: _parseInt(json['slotsNeeded']),
      slotsRemaining: _parseInt(json['slotsRemaining']),
      minSkillLevel: json['minSkillLevel']?.toString() ?? '1',
      sharedCost: _parseDouble(json['sharedCost']),
      scanRadiusKm: _parseDouble(json['scanRadiusKm']),
      status: json['status']?.toString() ?? '1',
      broadcastAt: json['broadcastAt']?.toString() ?? '',
      distanceKm: json['distanceKm'] != null ? _parseDouble(json['distanceKm']) : null,
      hidePlayerList: _parseBool(json['hidePlayerList']),
      femaleDiscount: json['femaleDiscount'] != null
          ? _parseDouble(json['femaleDiscount'])
          : (json['femaleDiscountGuest'] != null ? _parseDouble(json['femaleDiscountGuest']) : null),
      femaleSharedCost: json['femaleSharedCost'] != null
          ? _parseDouble(json['femaleSharedCost'])
          : (json['femaleCost'] != null ? _parseDouble(json['femaleCost']) : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'clubName': clubName,
    'courtLocation': courtLocation,
    'startTime': startTime,
    'endTime': endTime,
    'slotsNeeded': slotsNeeded,
    'slotsRemaining': slotsRemaining,
    'minSkillLevel': minSkillLevel,
    'sharedCost': sharedCost,
    'scanRadiusKm': scanRadiusKm,
    'status': status,
    'broadcastAt': broadcastAt,
    'distanceKm': distanceKm,
    'hidePlayerList': hidePlayerList,
    if (femaleDiscount != null) 'femaleDiscount': femaleDiscount,
    if (femaleSharedCost != null) 'femaleSharedCost': femaleSharedCost,
  };
}
