import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/app/services/biometric_service.dart';
import '../../../home_vm/home_vm.dart';
import 'settings_state.dart';

final settingsViewModelProvider =
StateNotifierProvider.autoDispose<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(
    biometricService: ref.watch(biometricServiceProvider),
    ref: ref,
  );
});


class SettingsViewModel extends StateNotifier<SettingsState> {
  final BiometricService biometricService;
  final Ref ref;

  SettingsViewModel({
    required this.biometricService,
    required this.ref,
  }) : super(const SettingsState());

  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ok = await ref.read(homeViewModelProvider.notifier).logout();

      // giữ biometric credentials, chỉ clear session
      await biometricService.clearSessionOnly();

      state = state.copyWith(isLoading: false);
      return ok;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

}

