import '../../entities/club/explore_club.dart';
import '../../enums/session_enums.dart';
import '../../repositories/club_repository.dart';

class ExploreClubsParams {
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final SkillLevel? skillLevel;
  final bool? isRecruiting;
  final String? searchTerm;

  const ExploreClubsParams({
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.skillLevel,
    this.isRecruiting,
    this.searchTerm,
  });
}

class ExploreClubsUseCase {
  final ClubRepository repository;
  ExploreClubsUseCase(this.repository);

  Future<List<ExploreClub>> execute([ExploreClubsParams? params]) {
    return repository.exploreClubs(
      latitude: params?.latitude,
      longitude: params?.longitude,
      radiusKm: params?.radiusKm,
      skillLevel: params?.skillLevel,
      isRecruiting: params?.isRecruiting,
      searchTerm: params?.searchTerm,
    );
  }
}
