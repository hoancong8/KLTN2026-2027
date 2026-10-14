import '../enums/session_enums.dart';

class PlayerProfile {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String? phoneNumber;
  final int gender; // 0: Khác, 1: Nam, 2: Nữ
  final String? avatarUrl;
  final SkillLevel skillLevel;
  final String skillLevelName;
  final bool isOpenForGuest;
  final double reputationScore;

  const PlayerProfile({
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

  PlayerProfile copyWith({
    String? id,
    String? fullName,
    String? userName,
    String? email,
    String? phoneNumber,
    int? gender,
    String? avatarUrl,
    SkillLevel? skillLevel,
    String? skillLevelName,
    bool? isOpenForGuest,
    double? reputationScore,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skillLevel: skillLevel ?? this.skillLevel,
      skillLevelName: skillLevelName ?? this.skillLevelName,
      isOpenForGuest: isOpenForGuest ?? this.isOpenForGuest,
      reputationScore: reputationScore ?? this.reputationScore,
    );
  }
}
