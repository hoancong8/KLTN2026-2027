// lib/ui/screen/club/session_vm/explore_recruitments_vm.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/club/my_club.dart';
import '../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../domain/entities/session/my_booking_item.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/services/i_location_service.dart';
import '../../../../domain/usecases/club/get_my_clubs_usecase.dart';
import '../../../../domain/usecases/session/get_my_bookings_usecase.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'explore_recruitments_state.dart';

final exploreRecruitmentsViewModelProvider =
    StateNotifierProvider<ExploreRecruitmentsViewModel, ExploreRecruitmentsState>((ref) {
  return ExploreRecruitmentsViewModel(
    ref: ref,
    exploreRecruitmentsUseCase: ref.watch(exploreRecruitmentsUseCaseProvider),
    joinRecruitmentUseCase: ref.watch(joinRecruitmentUseCaseProvider),
    cancelRecruitmentBookingUseCase: ref.watch(cancelRecruitmentBookingUseCaseProvider),
    getMyBookingsUseCase: ref.watch(getMyBookingsUseCaseProvider),
    getMyClubsUseCase: ref.watch(getMyClubsUseCaseProvider),
    locationService: ref.watch(locationServiceProvider),
  );
});

class ExploreRecruitmentsViewModel extends StateNotifier<ExploreRecruitmentsState> {
  final Ref? ref;
  final ExploreRecruitmentsUseCase exploreRecruitmentsUseCase;
  final JoinRecruitmentUseCase joinRecruitmentUseCase;
  final CancelRecruitmentBookingUseCase cancelRecruitmentBookingUseCase;
  final GetMyBookingsUseCase? getMyBookingsUseCase;
  final GetMyClubsUseCase? getMyClubsUseCase;
  final ILocationService? locationService;

  ExploreRecruitmentsViewModel({
    this.ref,
    required this.exploreRecruitmentsUseCase,
    required this.joinRecruitmentUseCase,
    required this.cancelRecruitmentBookingUseCase,
    this.getMyBookingsUseCase,
    this.getMyClubsUseCase,
    this.locationService,
  }) : super(const ExploreRecruitmentsState(isLocating: false)) {
    if (ref == null || ref?.read(authTokenProvider) != null) {
      explore();
    }
  }

  Future<void> explore() async {
    final token = ref?.read(authTokenProvider);
    if (ref != null && (token == null || token.accessToken.isEmpty)) {
      state = state.copyWith(isLoading: false, recruitments: const [], clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true, errorMessage: null);
    try {
      double? lat;
      double? lng;

      if (locationService != null) {
        try {
          final hasPerm = await locationService!.hasPermission();
          if (hasPerm) {
            final loc = await locationService!.getCurrentLocation();
            lat = loc.latitude;
            lng = loc.longitude;
            state = state.copyWith(latitude: lat, longitude: lng);
          }
        } catch (_) {
          lat = null;
          lng = null;
        }
      }

      final recruitmentsFuture = exploreRecruitmentsUseCase.execute(
        latitude: lat,
        longitude: lng,
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
          .where((b) => b.bookingStatus != BookingStatus.absent && b.bookingStatus != BookingStatus.waiting)
          .map((b) => b.sessionId.trim().toLowerCase())
          .where((id) => id.isNotEmpty)
          .toSet();

      final waitingSessionIds = bookings
          .where((b) => b.bookingStatus == BookingStatus.waiting)
          .map((b) => b.sessionId.trim().toLowerCase())
          .where((id) => id.isNotEmpty)
          .toSet();

      for (final r in recruitments) {
        final sid = r.sessionId.trim().toLowerCase();
        if (r.isWaitingApproval) {
          waitingSessionIds.add(sid);
        } else if (r.isConfirmedParticipant) {
          activeJoinedSessionIds.add(sid);
        }
      }

      final clubNames = clubs
          .map((c) => c.clubName.trim().toLowerCase())
          .where((n) => n.isNotEmpty)
          .toSet();

      state = state.copyWith(
        isLoading: false,
        recruitments: recruitments,
        joinedSessionIds: activeJoinedSessionIds,
        waitingSessionIds: waitingSessionIds,
        myClubNames: clubNames,
        clearError: true,
      );
    } catch (e) {
      final appException = e is AppException ? e : AppException(message: e.toString(), originalError: e);
      state = state.copyWith(
        isLoading: false,
        error: appException,
        errorMessage: appException.message ?? appException.toString(),
      );
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
    state = state.copyWith(isJoining: true, clearError: true, errorMessage: null);
    try {
      await joinRecruitmentUseCase.execute(recruitmentId);
      final matched = state.recruitments.where((r) => r.id == recruitmentId).firstOrNull;
      if (matched != null) {
        final updatedWaiting = Set<String>.from(state.waitingSessionIds)..add(matched.sessionId.trim().toLowerCase());
        state = state.copyWith(waitingSessionIds: updatedWaiting);
      }
      await explore();
      state = state.copyWith(isJoining: false, successMessage: 'Đã gửi yêu cầu tham gia, vui lòng chờ duyệt!');
      return true;
    } catch (e) {
      final appException = e is AppException ? e : AppException(message: e.toString(), originalError: e);
      state = state.copyWith(
        isJoining: false,
        error: appException,
        errorMessage: appException.message ?? appException.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelRecruitment(String recruitmentId) async {
    state = state.copyWith(isJoining: true, clearError: true, errorMessage: null);
    try {
      await cancelRecruitmentBookingUseCase.execute(recruitmentId);
      await explore();
      state = state.copyWith(isJoining: false, successMessage: 'Đã hủy suất giao lưu thành công!');
      return true;
    } catch (e) {
      final appException = e is AppException ? e : AppException(message: e.toString(), originalError: e);
      state = state.copyWith(
        isJoining: false,
        error: appException,
        errorMessage: appException.message ?? appException.toString(),
      );
      return false;
    }
  }
}
