// lib/ui/screen/club/session_vm/club_sessions_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'club_sessions_state.dart';

final clubSessionsViewModelProvider =
    StateNotifierProvider.autoDispose.family<ClubSessionsViewModel, ClubSessionsState, String>((ref, clubId) {
  return ClubSessionsViewModel(
    clubId: clubId,
    getClubSessionsUseCase: ref.watch(getClubSessionsUseCaseProvider),
    createSessionUseCase: ref.watch(createSessionUseCaseProvider),
  );
});

class ClubSessionsViewModel extends StateNotifier<ClubSessionsState> {
  final String clubId;
  final GetClubSessionsUseCase getClubSessionsUseCase;
  final CreateSessionUseCase createSessionUseCase;

  ClubSessionsViewModel({
    required this.clubId,
    required this.getClubSessionsUseCase,
    required this.createSessionUseCase,
  }) : super(const ClubSessionsState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    if (clubId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final sessions = await getClubSessionsUseCase.execute(clubId);
      state = state.copyWith(isLoading: false, sessions: sessions);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<String?> createSession(CreateSessionParams params) async {
    try {
      final sessionId = await createSessionUseCase.execute(params);
      await loadSessions();
      return sessionId;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
}
