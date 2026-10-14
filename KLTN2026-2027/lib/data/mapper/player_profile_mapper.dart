import '../../domain/entities/player_profile.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/user/player_profile_dto.dart';
import '../dto/user/update_player_profile_request_dto.dart';

class PlayerProfileMapper {
  static PlayerProfile toEntity(PlayerProfileDto dto) {
    return PlayerProfile(
      id: dto.id,
      fullName: dto.fullName,
      userName: dto.userName,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      gender: dto.gender,
      avatarUrl: dto.avatarUrl,
      skillLevel: SkillLevel.fromString(dto.skillLevel),
      skillLevelName: dto.skillLevelName,
      isOpenForGuest: dto.isOpenForGuest,
      reputationScore: dto.reputationScore,
    );
  }

  static UpdatePlayerProfileRequestDto toUpdateRequestDto({
    required String fullName,
    required int gender,
    String? avatarUrl,
    required SkillLevel skillLevel,
    required bool isOpenForGuest,
  }) {
    return UpdatePlayerProfileRequestDto(
      fullName: fullName,
      gender: gender,
      avatarUrl: avatarUrl,
      skillLevel: skillLevel.code,
      isOpenForGuest: isOpenForGuest,
    );
  }
}
