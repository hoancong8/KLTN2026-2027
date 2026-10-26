import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/explore_clubs_usecase.dart';
import 'explore_clubs_state.dart';

final exploreClubsViewModelProvider =
    StateNotifierProvider.autoDispose<ExploreClubsViewModel, ExploreClubsState>((ref) {
  return ExploreClubsViewModel(
    exploreClubsUseCase: ref.watch(exploreClubsUseCaseProvider),
  );
});

class ExploreClubsViewModel extends StateNotifier<ExploreClubsState> {
  final ExploreClubsUseCase exploreClubsUseCase;

  ExploreClubsViewModel({required this.exploreClubsUseCase})
      : super(const ExploreClubsState()) {
    loadClubs();
  }

  Future<void> loadClubs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clubs = await exploreClubsUseCase.execute(ExploreClubsParams(
        latitude: null,
        longitude: null,
        radiusKm: null,
        skillLevel: state.selectedSkillLevel,
        isRecruiting: state.isRecruitingOnly,
        searchTerm: state.searchTerm.trim().isNotEmpty ? state.searchTerm.trim() : null,
      ));
      state = state.copyWith(isLoading: false, clubs: clubs);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
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
