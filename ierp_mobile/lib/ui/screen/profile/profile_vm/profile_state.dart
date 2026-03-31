import 'package:ierp_mobile/domain/entities/employee.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
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
    String? error,
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
