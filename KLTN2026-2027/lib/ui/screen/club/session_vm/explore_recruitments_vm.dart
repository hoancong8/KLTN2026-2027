// lib/ui/screen/club/session_vm/explore_recruitments_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/services/i_location_service.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'explore_recruitments_state.dart';

final exploreRecruitmentsViewModelProvider =
    StateNotifierProvider<ExploreRecruitmentsViewModel, ExploreRecruitmentsState>((ref) {
  return ExploreRecruitmentsViewModel(
    exploreRecruitmentsUseCase: ref.watch(exploreRecruitmentsUseCaseProvider),
    joinRecruitmentUseCase: ref.watch(joinRecruitmentUseCaseProvider),
    cancelRecruitmentBookingUseCase: ref.watch(cancelRecruitmentBookingUseCaseProvider),
    locationService: ref.watch(locationServiceProvider),
  );
});

class ExploreRecruitmentsViewModel extends StateNotifier<ExploreRecruitmentsState> {
  final ExploreRecruitmentsUseCase exploreRecruitmentsUseCase;
  final JoinRecruitmentUseCase joinRecruitmentUseCase;
  final CancelRecruitmentBookingUseCase cancelRecruitmentBookingUseCase;
  final ILocationService locationService;

  ExploreRecruitmentsViewModel({
    required this.exploreRecruitmentsUseCase,
    required this.joinRecruitmentUseCase,
    required this.cancelRecruitmentBookingUseCase,
    required this.locationService,
  }) : super(const ExploreRecruitmentsState()) {
    initLocationAndExplore();
  }

  Future<void> initLocationAndExplore() async {
    state = state.copyWith(isLoading: true, isLocating: true, errorMessage: null);
    try {
      final loc = await locationService.getCurrentLocation();
      state = state.copyWith(
        latitude: loc.latitude,
        longitude: loc.longitude,
        isLocating: false,
      );
      await explore();
    } catch (_) {
      state = state.copyWith(isLocating: false);
      await explore();
    }
  }

  Future<void> explore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      double? lat = state.latitude;
      double? lng = state.longitude;

      if (lat == null || lng == null) {
        final loc = await locationService.getCurrentLocation();
        lat = loc.latitude;
        lng = loc.longitude;
        state = state.copyWith(latitude: lat, longitude: lng);
      }

      final results = await exploreRecruitmentsUseCase.execute(
        latitude: lat,
        longitude: lng,
        radiusKm: state.radiusKm,
        minSkillLevel: state.selectedSkillLevel,
      );
      state = state.copyWith(isLoading: false, recruitments: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setRadius(double radiusKm) {
    state = state.copyWith(radiusKm: radiusKm);
    explore();
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
