import 'package:equatable/equatable.dart';
import '../../../../domain/entities/sepay/sepay_application.dart';

class AdminSepayState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final SepayApplication? application;
  final String? errorMessage;
  final String? errorMessageKey;
  final String? successMessageKey;
  final bool isRevisionConflict;

  const AdminSepayState({
    this.isLoading = false,
    this.isSaving = false,
    this.application,
    this.errorMessage,
    this.errorMessageKey,
    this.successMessageKey,
    this.isRevisionConflict = false,
  });

  AdminSepayState copyWith({
    bool? isLoading,
    bool? isSaving,
    SepayApplication? application,
    String? errorMessage,
    String? errorMessageKey,
    String? successMessageKey,
    bool? isRevisionConflict,
    bool clearMessages = false,
    bool clearApplication = false,
  }) {
    return AdminSepayState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      application: clearApplication ? null : (application ?? this.application),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      errorMessageKey: clearMessages
          ? null
          : (errorMessageKey ?? this.errorMessageKey),
      successMessageKey: clearMessages
          ? null
          : (successMessageKey ?? this.successMessageKey),
      isRevisionConflict: isRevisionConflict ?? this.isRevisionConflict,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    application,
    errorMessage,
    errorMessageKey,
    successMessageKey,
    isRevisionConflict,
  ];
}
