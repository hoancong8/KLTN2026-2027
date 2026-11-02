// lib/ui/screen/club/session_vm/club_sessions_state.dart

import '../../../../domain/entities/session/session.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ClubSessionsState {
  final bool isLoading;
  final List<Session> sessions;
  final AppException? error;
  final String? errorMessage;

  const ClubSessionsState({
    this.isLoading = false,
    this.sessions = const [],
    this.error,
    this.errorMessage,
  });

  ClubSessionsState copyWith({
    bool? isLoading,
    List<Session>? sessions,
    AppException? error,
    bool clearError = false,
    String? errorMessage,
  }) {
    return ClubSessionsState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      error: clearError ? null : (error ?? this.error),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
