import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/user/get_player_profile_usecase.dart';
import '../../../../domain/usecases/user/update_player_profile_usecase.dart';
import 'profile_state.dart';

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    ref: ref,
    getPlayerProfileUseCase: ref.watch(getPlayerProfileUseCaseProvider),
    updatePlayerProfileUseCase: ref.watch(updatePlayerProfileUseCaseProvider),
  );
});

class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref ref;
  final GetPlayerProfileUseCase getPlayerProfileUseCase;
  final UpdatePlayerProfileUseCase updatePlayerProfileUseCase;

  ProfileViewModel({
    required this.ref,
    required this.getPlayerProfileUseCase,
    required this.updatePlayerProfileUseCase,
  }) : super(const ProfileState()) {
    reloadProfile();
  }

  Future<void> reloadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final playerProfile = await getPlayerProfileUseCase.execute();
      state = state.copyWith(isLoading: false, playerProfile: playerProfile);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: e.toString()),
      );
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required int gender,
    String? avatarUrl,
    required SkillLevel skillLevel,
    required bool isOpenForGuest,
  }) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    try {
      await updatePlayerProfileUseCase.execute(UpdatePlayerProfileParams(
        fullName: fullName.trim(),
        gender: gender,
        avatarUrl: avatarUrl,
        skillLevel: skillLevel,
        isOpenForGuest: isOpenForGuest,
      ));

      final playerProfile = await getPlayerProfileUseCase.execute();
      state = state.copyWith(
        isSaving: false,
        playerProfile: playerProfile,
        successMessage: 'Cập nhật hồ sơ và trình độ thành công!',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: AppException(message: e.toString()),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}
