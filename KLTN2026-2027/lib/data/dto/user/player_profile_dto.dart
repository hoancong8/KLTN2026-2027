class PlayerProfileDto {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String? phoneNumber;
  final int gender;
  final String? avatarUrl;
  final dynamic skillLevel;
  final String skillLevelName;
  final bool isOpenForGuest;
  final double reputationScore;

  PlayerProfileDto({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    this.phoneNumber,
    required this.gender,
    this.avatarUrl,
    required this.skillLevel,
    required this.skillLevelName,
    required this.isOpenForGuest,
    required this.reputationScore,
  });

  factory PlayerProfileDto.fromJson(Map<String, dynamic> json) {
    return PlayerProfileDto(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      gender: _parseInt(json['gender']),
      avatarUrl: json['avatarUrl']?.toString(),
      skillLevel: json['skillLevel'] ?? 'NB',
      skillLevelName: json['skillLevelName']?.toString() ?? 'Newbie',
      isOpenForGuest: _parseBool(json['isOpenForGuest']),
      reputationScore: _parseDouble(json['reputationScore'], defaultValue: 100.0),
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

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return defaultValue;
  }
}
