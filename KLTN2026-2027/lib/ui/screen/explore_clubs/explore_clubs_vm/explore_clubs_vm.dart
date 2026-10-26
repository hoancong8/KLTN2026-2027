import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/club/explore_club.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/explore_clubs_usecase.dart';
import '../../../../domain/usecases/club/get_my_clubs_usecase.dart';
import 'explore_clubs_state.dart';

final exploreClubsViewModelProvider =
    StateNotifierProvider.autoDispose<ExploreClubsViewModel, ExploreClubsState>((ref) {
  return ExploreClubsViewModel(
    exploreClubsUseCase: ref.watch(exploreClubsUseCaseProvider),
    getMyClubsUseCase: ref.watch(getMyClubsUseCaseProvider),
  );
});

class ExploreClubsViewModel extends StateNotifier<ExploreClubsState> {
  final ExploreClubsUseCase exploreClubsUseCase;
  final GetMyClubsUseCase getMyClubsUseCase;

  ExploreClubsViewModel({
    required this.exploreClubsUseCase,
    required this.getMyClubsUseCase,
  }) : super(const ExploreClubsState()) {
    loadClubs();
  }

  Future<void> loadClubs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        exploreClubsUseCase.execute(ExploreClubsParams(
          latitude: null,
          longitude: null,
          radiusKm: null,
          skillLevel: state.selectedSkillLevel,
          isRecruiting: state.isRecruitingOnly,
          searchTerm: state.searchTerm.trim().isNotEmpty ? state.searchTerm.trim() : null,
        )),
        _fetchJoinedClubIds(),
      ]);

      final clubs = results[0] as List<ExploreClub>;
      final joinedClubIds = results[1] as Set<String>;

      final availableClubs = clubs.where((c) => !joinedClubIds.contains(c.id)).toList();
      state = state.copyWith(isLoading: false, clubs: availableClubs);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
    }
  }

  Future<Set<String>> _fetchJoinedClubIds() async {
    try {
      final myClubs = await getMyClubsUseCase.execute();
      return myClubs.map((c) => c.clubId).toSet();
    } catch (_) {
      return {};
    }
  }

  void setSearchTerm(String term) {
    state = state.copyWith(searchTerm: term);
    loadClubs();
  }

  void setSkillLevel(SkillLevel? skillLevel) {
    if (skillLevel == null) {
      state = state.copyWith(clearSkillLevel: true);
    } else {
      state = state.copyWith(selectedSkillLevel: skillLevel);
    }
    loadClubs();
  }

  void toggleRecruitingOnly(bool? value) {
    state = state.copyWith(isRecruitingOnly: value);
    loadClubs();
  }
}
