// lib/ui/screen/club/session_vm/session_detail_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/session/session_booking.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'session_detail_state.dart';

final sessionDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<SessionDetailViewModel, SessionDetailState, String>((ref, sessionId) {
  return SessionDetailViewModel(
    sessionId: sessionId,
    getSessionDetailUseCase: ref.watch(getSessionDetailUseCaseProvider),
    voteBookingUseCase: ref.watch(voteBookingUseCaseProvider),
    cancelBookingUseCase: ref.watch(cancelBookingUseCaseProvider),
    confirmBookingUseCase: ref.watch(confirmBookingUseCaseProvider),
    updateSessionStatusUseCase: ref.watch(updateSessionStatusUseCaseProvider),
    deleteSessionUseCase: ref.watch(deleteSessionUseCaseProvider),
    createRecruitmentUseCase: ref.watch(createRecruitmentUseCaseProvider),
    deleteRecruitmentUseCase: ref.watch(deleteRecruitmentUseCaseProvider),
  );
});

class SessionDetailViewModel extends StateNotifier<SessionDetailState> {
  final String sessionId;
  final GetSessionDetailUseCase getSessionDetailUseCase;
  final VoteBookingUseCase voteBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final ConfirmBookingUseCase confirmBookingUseCase;
  final UpdateSessionStatusUseCase updateSessionStatusUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final CreateRecruitmentUseCase createRecruitmentUseCase;
  final DeleteRecruitmentUseCase deleteRecruitmentUseCase;

  SessionDetailViewModel({
    required this.sessionId,
    required this.getSessionDetailUseCase,
    required this.voteBookingUseCase,
    required this.cancelBookingUseCase,
    required this.confirmBookingUseCase,
    required this.updateSessionStatusUseCase,
    required this.deleteSessionUseCase,
    required this.createRecruitmentUseCase,
    required this.deleteRecruitmentUseCase,
  }) : super(const SessionDetailState()) {
    loadDetail();
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final detail = await getSessionDetailUseCase.execute(sessionId);
      state = state.copyWith(isLoading: false, detail: detail);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<SessionBooking?> voteBooking() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final booking = await voteBookingUseCase.execute(sessionId);
      await loadDetail();
      state = state.copyWith(isSubmitting: false);
      return booking;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> cancelBooking() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await cancelBookingUseCase.execute(sessionId);
      await loadDetail();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> confirmBooking(String bookingId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await confirmBookingUseCase.execute(sessionId, bookingId);
      await loadDetail();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String status) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await updateSessionStatusUseCase.execute(sessionId, status);
      await loadDetail();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteSession() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await deleteSessionUseCase.execute(sessionId);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> createRecruitment(CreateRecruitmentParams params) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await createRecruitmentUseCase.execute(params);
      await loadDetail();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteRecruitment() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await deleteRecruitmentUseCase.execute(sessionId);
      await loadDetail();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}
