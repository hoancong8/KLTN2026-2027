// lib/ui/screen/login/register_vm/register_vm.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/auth_token.dart';
import '../../../../domain/usecases/auth/register_usecase.dart';
import 'register_state.dart';

final registerViewModelProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>((ref) {
  return RegisterViewModel(
    registerUseCase: ref.watch(registerUseCaseProvider),
    ref: ref,
  );
});

class RegisterViewModel extends StateNotifier<RegisterState> {
  final RegisterUseCase registerUseCase;
  final Ref ref;

  RegisterViewModel({
    required this.registerUseCase,
    required this.ref,
  }) : super(const RegisterState());

  Future<bool> register({
    required String fullName,
    String? email,
    String? phoneNumber,
    required String password,
    int gender = 0,
    String skillLevel = 'NB',
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await registerUseCase.execute(
        RegisterParams(
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          gender: gender,
          skillLevel: skillLevel,
        ),
      );

      if (result.accessToken.isNotEmpty) {
        ref.read(authTokenProvider.notifier).state = AuthToken(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          userId: result.userId,
        );
        await ref.read(currentUserProfileProvider.notifier).fetchProfile();
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
