// ui/change_password/change_password_vm.dart
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/auth_exceptions.dart';
import '../../../../domain/usecases/auth/change_password_usecase.dart';
import 'change_password_state.dart';

// Provider for ChangePasswordViewModel
final changePasswordViewModelProvider =
StateNotifierProvider.autoDispose<
    ChangePasswordViewModel, ChangePasswordState>((ref) {
  return ChangePasswordViewModel(
    ref.watch(changePasswordUseCaseProvider),
  );
});

// ViewModel
class ChangePasswordViewModel
    extends StateNotifier<ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordViewModel(this.changePasswordUseCase)
      : super(const ChangePasswordState());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      success: false,
    );

    try {
      await changePasswordUseCase.execute(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
      );
    } on ChangePasswordFailedException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
