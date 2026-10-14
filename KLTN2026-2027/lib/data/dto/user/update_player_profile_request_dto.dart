class UpdatePlayerProfileRequestDto {
  final String fullName;
  final int gender;
  final String? avatarUrl;
  final String skillLevel;
  final bool isOpenForGuest;

  UpdatePlayerProfileRequestDto({
    required this.fullName,
    required this.gender,
    this.avatarUrl,
    required this.skillLevel,
    required this.isOpenForGuest,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'gender': gender,
      'skillLevel': skillLevel,
      'isOpenForGuest': isOpenForGuest,
    };
    if (avatarUrl != null) {
      map['avatarUrl'] = avatarUrl;
    }
    return map;
  }
}
