class ExploreClubDto {
  final String id;
  final String groupName;
  final String code;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? distanceKm;
  final dynamic minSkillLevel;
  final dynamic maxSkillLevel;
  final int memberCount;
  final bool isRecruiting;
  final double qualityScore;
  final String? schedulesSummary;

  ExploreClubDto({
    required this.id,
    required this.groupName,
    required this.code,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.distanceKm,
    this.minSkillLevel,
    this.maxSkillLevel,
    required this.memberCount,
    required this.isRecruiting,
    required this.qualityScore,
    this.schedulesSummary,
  });

  factory ExploreClubDto.fromJson(Map<String, dynamic> json) {
    return ExploreClubDto(
      id: json['id']?.toString() ?? '',
      groupName: json['groupName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      fixedVenueName: json['fixedVenueName']?.toString(),
      fixedAddress: json['fixedAddress']?.toString(),
      distanceKm: _parseDoubleNullable(json['distanceKm']),
      minSkillLevel: json['minSkillLevel'],
      maxSkillLevel: json['maxSkillLevel'],
      memberCount: _parseInt(json['memberCount'] ?? json['activeMemberCount']),
      isRecruiting: _parseBool(json['isRecruiting']),
      qualityScore: _parseDouble(json['qualityScore'] ?? json['groupQualityScore'], defaultValue: 5.0),
      schedulesSummary: json['schedulesSummary']?.toString(),
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
