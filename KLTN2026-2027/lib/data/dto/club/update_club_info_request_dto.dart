class UpdateClubInfoRequestDto {
  final String groupName;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? lat;
  final double? lng;
  final String? minSkillLevel;
  final String? maxSkillLevel;
  final bool isRecruiting;

  UpdateClubInfoRequestDto({
    required this.groupName,
    this.description,
    this.avatarUrl,
    this.fixedVenueName,
    this.fixedAddress,
    this.lat,
    this.lng,
    this.minSkillLevel,
    this.maxSkillLevel,
    required this.isRecruiting,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'groupName': groupName,
      'isRecruiting': isRecruiting,
    };
    if (description != null) map['description'] = description;
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;
    if (fixedVenueName != null) map['fixedVenueName'] = fixedVenueName;
    if (fixedAddress != null) map['fixedAddress'] = fixedAddress;
    if (lat != null) map['lat'] = lat;
    if (lng != null) map['lng'] = lng;
    if (minSkillLevel != null) map['minSkillLevel'] = minSkillLevel;
    if (maxSkillLevel != null) map['maxSkillLevel'] = maxSkillLevel;
    return map;
  }
}
