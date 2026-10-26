// lib/ui/screen/club/session_vm/explore_recruitments_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../domain/enums/session_enums.dart';
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
  );
});

class ExploreRecruitmentsViewModel extends StateNotifier<ExploreRecruitmentsState> {
  final ExploreRecruitmentsUseCase exploreRecruitmentsUseCase;
  final JoinRecruitmentUseCase joinRecruitmentUseCase;
  final CancelRecruitmentBookingUseCase cancelRecruitmentBookingUseCase;
  final GetMyBookingsUseCase getMyBookingsUseCase;

  ExploreRecruitmentsViewModel({
    required this.exploreRecruitmentsUseCase,
    required this.joinRecruitmentUseCase,
    required this.cancelRecruitmentBookingUseCase,
    required this.getMyBookingsUseCase,
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
      ]);
      final recruitments = results[0] as List<GuestRecruitment>;
      final bookedSessionIds = results[1] as Set<String>;

      final available = recruitments.where((r) => !bookedSessionIds.contains(r.sessionId)).toList();
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
    try {
      await cancelRecruitmentBookingUseCase.execute(recruitmentId);
      await explore();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
