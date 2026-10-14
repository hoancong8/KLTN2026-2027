import '../../../../domain/entities/club/club_detail.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ClubDetailState {
  final bool isLoading;
  final bool isSubmitting;
  final AppException? error;
  final String? successMessage;
  final ClubDetail? club;

  const ClubDetailState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
    this.club,
  });

  ClubDetailState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    AppException? error,
    String? successMessage,
    ClubDetail? club,
  }) {
    return ClubDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      successMessage: successMessage,
      club: club ?? this.club,
    );
  }
}
