class ClubHostDto {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;

  ClubHostDto({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory ClubHostDto.fromJson(Map<String, dynamic> json) {
    return ClubHostDto(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
    );
  }
}

class ClubScheduleItemDto {
  final String id;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isActive;

  ClubScheduleItemDto({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory ClubScheduleItemDto.fromJson(Map<String, dynamic> json) {
    return ClubScheduleItemDto(
      id: json['id']?.toString() ?? '',
      dayOfWeek: _parseInt(json['dayOfWeek']),
      dayName: json['dayName']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return defaultValue;
  }
}

class ClubCurrentUserStatusDto {
  final bool isMember;
  final String? roleName;
  final String? status;
  final bool hasPendingJoinRequest;
  final String? pendingRequestId;

  ClubCurrentUserStatusDto({
    required this.isMember,
    this.roleName,
    this.status,
    required this.hasPendingJoinRequest,
    this.pendingRequestId,
  });

  bool get isHost => roleName?.toLowerCase() == 'host';

  factory ClubCurrentUserStatusDto.fromJson(Map<String, dynamic> json) {
    return ClubCurrentUserStatusDto(
      isMember: _parseBool(json['isMember']),
      roleName: json['roleName']?.toString(),
      status: json['status']?.toString(),
      hasPendingJoinRequest: _parseBool(json['hasPendingJoinRequest']),
      pendingRequestId: json['pendingRequestId']?.toString(),
    );
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return defaultValue;
  }
}

class ClubDetailDto {
  final String id;
  final String groupName;
  final String code;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? lat;
  final double? lng;
  final dynamic minSkillLevel;
  final dynamic maxSkillLevel;
  final double qualityScore;
  final bool isRecruiting;
  final int memberCount;
  final ClubHostDto host;
  final List<ClubScheduleItemDto> schedules;
  final String? schedulesSummary;
  final ClubCurrentUserStatusDto currentUserStatus;

  ClubDetailDto({
    required this.id,
    required this.groupName,
    required this.code,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.lat,
    this.lng,
    this.minSkillLevel,
    this.maxSkillLevel,
    required this.qualityScore,
    required this.isRecruiting,
    required this.memberCount,
    required this.host,
    required this.schedules,
    this.schedulesSummary,
    required this.currentUserStatus,
  });

  factory ClubDetailDto.fromJson(Map<String, dynamic> json) {
    return ClubDetailDto(
      id: json['id']?.toString() ?? '',
      groupName: json['name']?.toString() ?? json['groupName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      fixedVenueName: json['fixedVenueName']?.toString(),
      fixedAddress: json['fixedAddress']?.toString(),
      lat: _parseDoubleNullable(json['lat']),
      lng: _parseDoubleNullable(json['lng']),
      minSkillLevel: json['minSkillLevel'],
      maxSkillLevel: json['maxSkillLevel'],
      qualityScore: _parseDouble(json['qualityScore'] ?? json['groupQualityScore'], defaultValue: 5.0),
      isRecruiting: _parseBool(json['isRecruiting']),
      memberCount: _parseInt(json['memberCount'] ?? json['activeMemberCount']),
      host: json['host'] is Map<String, dynamic>
          ? ClubHostDto.fromJson(json['host'] as Map<String, dynamic>)
          : ClubHostDto(userId: '', fullName: ''),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => ClubScheduleItemDto.fromJson(e))
          .toList(),
      schedulesSummary: json['schedulesSummary']?.toString(),
      currentUserStatus: json['currentUserStatus'] is Map<String, dynamic>
          ? ClubCurrentUserStatusDto.fromJson(json['currentUserStatus'] as Map<String, dynamic>)
          : ClubCurrentUserStatusDto(isMember: false, hasPendingJoinRequest: false),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return defaultValue;
  }
}
