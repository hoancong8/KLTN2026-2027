import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/entities/employee.dart';
import 'package:kltn2026_2027/domain/exceptions/auth_exceptions.dart';
import 'package:kltn2026_2027/domain/usecases/profile/change_profile_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/profile/get_profile_usecase.dart';
import 'profile_state.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../app/utils/app_exception_handler.dart';
final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    changeProfileUseCase: ref.watch(changeProfileUseCaseProvider),
  );
});

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final ChangeProfileUseCase changeProfileUseCase;

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.changeProfileUseCase,
  }) : super(const ProfileState());

  void setEmployee(Employee employee) {
    state = state.copyWith(employee: employee);
  }

  Future<void> loadProfile(int employeeId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final employee = await getProfileUseCase.execute(employeeId);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, employee: employee);
    } on SessionExpiredException {
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
    catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: AppExceptionHandler.handle(e));
    }
  }
  void updateField({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? hometown,
    DateTime? doB,
    int? gender,
  }) {
    if (state.employee == null) return;

    state = state.copyWith(
      employee: state.employee!.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        hometown: hometown,
        doB: doB,
        gender: gender,
      ),
    );
  }
  Future<void> saveProfile() async {
    if (state.employee == null) return;
    if (!mounted) return;

    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    try {
      await changeProfileUseCase.execute(employee: state.employee!);
      if (!mounted) return;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Cập nhật thông tin thành công',
      );
    } on SessionExpiredException {
      if (!mounted) return;
      state = state.copyWith(isSaving: false);
    } on AppException catch (e) {
      state = state.copyWith(isSaving: false, error: e);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isSaving: false,
        error: AppExceptionHandler.handle(e),
      );
    }
  }
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}
