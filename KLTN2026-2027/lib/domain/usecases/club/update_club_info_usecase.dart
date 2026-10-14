import '../../enums/session_enums.dart';
import '../../repositories/club_repository.dart';

class UpdateClubInfoParams {
  final String clubId;
  final String groupName;
  final String? description;
  final String? avatarUrl;
  final String? fixedVenueName;
  final String? fixedAddress;
  final double? lat;
  final double? lng;
  final SkillLevel? minSkillLevel;
  final SkillLevel? maxSkillLevel;
  final bool isRecruiting;

  const UpdateClubInfoParams({
    required this.clubId,
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
}

class UpdateClubInfoUseCase {
  final ClubRepository repository;
  UpdateClubInfoUseCase(this.repository);

  Future<void> execute(UpdateClubInfoParams params) {
    return repository.updateClubInfo(
      params.clubId,
      groupName: params.groupName,
      description: params.description,
      avatarUrl: params.avatarUrl,
      fixedVenueName: params.fixedVenueName,
      fixedAddress: params.fixedAddress,
      lat: params.lat,
      lng: params.lng,
      minSkillLevel: params.minSkillLevel,
      maxSkillLevel: params.maxSkillLevel,
      isRecruiting: params.isRecruiting,
    );
  }
}
