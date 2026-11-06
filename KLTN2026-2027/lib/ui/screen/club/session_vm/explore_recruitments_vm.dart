// lib/ui/screen/club/session_vm/explore_recruitments_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/club/my_club.dart';
import '../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../domain/entities/session/my_booking_item.dart';
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
  final GetMyBookingsUseCase? getMyBookingsUseCase;
  final GetMyClubsUseCase? getMyClubsUseCase;

  ExploreRecruitmentsViewModel({
    required this.exploreRecruitmentsUseCase,
    required this.joinRecruitmentUseCase,
    required this.cancelRecruitmentBookingUseCase,
    this.getMyBookingsUseCase,
    this.getMyClubsUseCase,
  }) : super(const ExploreRecruitmentsState(isLocating: false)) {
    explore();
  }

  Future<void> explore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final recruitmentsFuture = exploreRecruitmentsUseCase.execute(
        latitude: null,
        longitude: null,
        radiusKm: null,
        minSkillLevel: state.selectedSkillLevel,
      );

      final bookingsFuture = getMyBookingsUseCase?.execute() ?? Future.value(<MyBookingItem>[]);
      final clubsFuture = getMyClubsUseCase?.execute() ?? Future.value(<MyClub>[]);

      final results = await Future.wait([
        recruitmentsFuture,
        bookingsFuture.catchError((_) => <MyBookingItem>[]),
        clubsFuture.catchError((_) => <MyClub>[]),
      ]);

      final recruitments = results[0] as List<GuestRecruitment>;
      final bookings = results[1] as List<MyBookingItem>;
      final clubs = results[2] as List<MyClub>;

      final activeJoinedSessionIds = bookings
          .where((b) => b.bookingStatus != BookingStatus.absent)
          .map((b) => b.sessionId.trim().toLowerCase())
          .where((id) => id.isNotEmpty)
          .toSet();

      final clubNames = clubs
          .map((c) => c.clubName.trim().toLowerCase())
          .where((n) => n.isNotEmpty)
          .toSet();

      state = state.copyWith(
        isLoading: false,
        recruitments: recruitments,
        joinedSessionIds: activeJoinedSessionIds,
        myClubNames: clubNames,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
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
      final matched = state.recruitments.where((r) => r.id == recruitmentId).firstOrNull;
      if (matched != null) {
        final updatedJoined = Set<String>.from(state.joinedSessionIds)..add(matched.sessionId.trim().toLowerCase());
        state = state.copyWith(joinedSessionIds: updatedJoined);
      }
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
