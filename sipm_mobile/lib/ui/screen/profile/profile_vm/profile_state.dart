import 'package:sipm_mobile/domain/entities/employee.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final AppException? error;
  final String? successMessage;
  final Employee? employee;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.employee,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    AppException? error,
    String? successMessage,
    Employee? employee,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      employee: employee ?? this.employee,
    );
  }
}
