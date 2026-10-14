// lib/ui/screen/club/session_vm/club_sessions_state.dart

import '../../../../domain/entities/session/session.dart';

class ClubSessionsState {
  final bool isLoading;
  final List<Session> sessions;
  final String? errorMessage;

  const ClubSessionsState({
    this.isLoading = false,
    this.sessions = const [],
    this.errorMessage,
  });

  ClubSessionsState copyWith({
    bool? isLoading,
    List<Session>? sessions,
    String? errorMessage,
  }) {
    return ClubSessionsState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }
}
