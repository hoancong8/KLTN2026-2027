import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/club/explore_club.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/explore_clubs_usecase.dart';
import '../../../../domain/usecases/club/get_my_clubs_usecase.dart';
import 'explore_clubs_state.dart';

class _JoinedClubIdentifiers {
  final Set<String> ids;
  final Set<String> codes;
  final Set<String> names;

  const _JoinedClubIdentifiers({
    required this.ids,
    required this.codes,
    required this.names,
  });
}

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
        _fetchJoinedClubIdentifiers(),
      ]);

      final clubs = results[0] as List<ExploreClub>;
      final joined = results[1] as _JoinedClubIdentifiers;

      final availableClubs = clubs.where((c) {
        final id = c.id.trim().toLowerCase();
        final code = c.code.trim().toUpperCase();
        final name = c.groupName.trim().toLowerCase();

        if (id.isNotEmpty && joined.ids.contains(id)) return false;
        if (code.isNotEmpty && joined.codes.contains(code)) return false;
        if (name.isNotEmpty && joined.names.contains(name)) return false;
        return true;
      }).toList();

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

  Future<_JoinedClubIdentifiers> _fetchJoinedClubIdentifiers() async {
    try {
      final myClubs = await getMyClubsUseCase.execute();
      return _JoinedClubIdentifiers(
        ids: myClubs
            .map((c) => c.clubId.trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toSet(),
        codes: myClubs
            .map((c) => c.clubCode.trim().toUpperCase())
            .where((s) => s.isNotEmpty)
            .toSet(),
        names: myClubs
            .map((c) => c.clubName.trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toSet(),
      );
    } catch (_) {
      return const _JoinedClubIdentifiers(ids: {}, codes: {}, names: {});
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
