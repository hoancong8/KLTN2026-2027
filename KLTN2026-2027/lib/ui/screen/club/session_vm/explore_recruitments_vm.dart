// lib/ui/screen/club/session_vm/explore_recruitments_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/usecases/club/get_my_clubs_usecase.dart';
import '../../../../domain/usecases/session/get_my_bookings_usecase.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'explore_recruitments_state.dart';

final exploreRecruitmentsViewModelProvider =
    StateNotifierProvider<ExploreRecruitmentsViewModel, ExploreRecruitmentsState>((ref) {
  return ExploreRecruitmentsViewModel(
    exploreRecruitmentsUseCase: ref.watch(exploreRecruitmentsUseCaseProvider),
    joinRecruitmentUseCase: ref.watch(joinRecruitmentUseCaseProvider),
    cancelRecruitmentBookingUseCase: ref.watch(cancelRecruitmentBookingUseCaseProvider),
    getMyBookingsUseCase: ref.watch(getMyBookingsUseCaseProvider),
    getMyClubsUseCase: ref.watch(getMyClubsUseCaseProvider),
  );
});

class ExploreRecruitmentsViewModel extends StateNotifier<ExploreRecruitmentsState> {
  final ExploreRecruitmentsUseCase exploreRecruitmentsUseCase;
  final JoinRecruitmentUseCase joinRecruitmentUseCase;
  final CancelRecruitmentBookingUseCase cancelRecruitmentBookingUseCase;
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final GetMyClubsUseCase getMyClubsUseCase;

  ExploreRecruitmentsViewModel({
    required this.exploreRecruitmentsUseCase,
    required this.joinRecruitmentUseCase,
    required this.cancelRecruitmentBookingUseCase,
    required this.getMyBookingsUseCase,
    required this.getMyClubsUseCase,
  }) : super(const ExploreRecruitmentsState(isLocating: false)) {
    explore();
  }

  Future<void> explore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        exploreRecruitmentsUseCase.execute(
          latitude: null,
          longitude: null,
          radiusKm: null,
          minSkillLevel: state.selectedSkillLevel,
        ),
        _fetchActiveBookedSessionIds(),
        _fetchJoinedClubNames(),
      ]);
      final recruitments = results[0] as List<GuestRecruitment>;
      final bookedSessionIds = results[1] as Set<String>;
      final joinedClubNames = results[2] as Set<String>;

      final available = recruitments.where((r) {
        if (bookedSessionIds.contains(r.sessionId)) return false;
        final clubName = r.clubName.trim().toLowerCase();
        if (clubName.isNotEmpty && joinedClubNames.contains(clubName)) return false;
        return true;
      }).toList();

      state = state.copyWith(isLoading: false, recruitments: available);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<Set<String>> _fetchActiveBookedSessionIds() async {
    try {
      final bookings = await getMyBookingsUseCase.execute();
      return bookings
          .where((b) => !b.isEnded && b.bookingStatus != BookingStatus.absent)
          .map((b) => b.sessionId)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> _fetchJoinedClubNames() async {
    try {
      final clubs = await getMyClubsUseCase.execute();
      return clubs
          .map((c) => c.clubName.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  void setSearchTerm(String term) {
    state = state.copyWith(searchTerm: term);
  }

  void setSkillLevel(String? skillLevel) {
    if (skillLevel == null || skillLevel.isEmpty) {
      state = state.copyWith(clearSkillLevel: true);
    } else {
      state = state.copyWith(selectedSkillLevel: skillLevel);
    }
    explore();
  }

  Future<bool> joinRecruitment(String recruitmentId) async {
    state = state.copyWith(isJoining: true, errorMessage: null);
    try {
      await joinRecruitmentUseCase.execute(recruitmentId);
      await explore();
      state = state.copyWith(isJoining: false, successMessage: 'Nhận suất giao lưu thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isJoining: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> cancelRecruitment(String recruitmentId) async {
    state = state.copyWith(isJoining: true, errorMessage: null);
    try {
      await cancelRecruitmentBookingUseCase.execute(recruitmentId);
      await explore();
      state = state.copyWith(isJoining: false, successMessage: 'Đã hủy suất giao lưu thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isJoining: false, errorMessage: e.toString());
      return false;
    }
  }
}
