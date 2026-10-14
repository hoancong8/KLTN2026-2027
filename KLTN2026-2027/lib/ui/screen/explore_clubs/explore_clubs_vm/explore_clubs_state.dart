import '../../../../domain/entities/club/explore_club.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ExploreClubsState {
  final bool isLoading;
  final AppException? error;
  final List<ExploreClub> clubs;
  final double radiusKm;
  final SkillLevel? selectedSkillLevel;
  final bool? isRecruitingOnly;
  final String searchTerm;
  final double? latitude;
  final double? longitude;

  const ExploreClubsState({
    this.isLoading = false,
    this.error,
    this.clubs = const [],
    this.radiusKm = 10.0,
    this.selectedSkillLevel,
    this.isRecruitingOnly,
    this.searchTerm = '',
    this.latitude,
    this.longitude,
  });

  ExploreClubsState copyWith({
    bool? isLoading,
    AppException? error,
    List<ExploreClub>? clubs,
    double? radiusKm,
    SkillLevel? selectedSkillLevel,
    bool clearSkillLevel = false,
    bool? isRecruitingOnly,
    String? searchTerm,
    double? latitude,
    double? longitude,
  }) {
    return ExploreClubsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      clubs: clubs ?? this.clubs,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedSkillLevel: clearSkillLevel ? null : (selectedSkillLevel ?? this.selectedSkillLevel),
      isRecruitingOnly: isRecruitingOnly ?? this.isRecruitingOnly,
      searchTerm: searchTerm ?? this.searchTerm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
