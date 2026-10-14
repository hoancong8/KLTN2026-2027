// lib/ui/screen/club/session_vm/session_detail_state.dart

import '../../../../domain/entities/session/session_detail.dart';

class SessionDetailState {
  final bool isLoading;
  final bool isSubmitting;
  final SessionDetail? detail;
  final String? errorMessage;
  final String? successMessage;

  const SessionDetailState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.detail,
    this.errorMessage,
    this.successMessage,
  });

  SessionDetailState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    SessionDetail? detail,
    String? errorMessage,
    String? successMessage,
  }) {
    return SessionDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
