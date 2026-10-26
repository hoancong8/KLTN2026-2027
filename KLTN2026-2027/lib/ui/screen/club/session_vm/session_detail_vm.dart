// lib/ui/screen/club/session_vm/session_detail_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/session/session_booking.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'session_detail_state.dart';

final sessionDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<SessionDetailViewModel, SessionDetailState, String>((ref, sessionId) {
  return SessionDetailViewModel(
    sessionId: sessionId,
    getSessionDetailUseCase: ref.watch(getSessionDetailUseCaseProvider),
    voteBookingUseCase: ref.watch(voteBookingUseCaseProvider),
    cancelBookingUseCase: ref.watch(cancelBookingUseCaseProvider),
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
  final UpdateSessionStatusUseCase updateSessionStatusUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;
  final CreateRecruitmentUseCase createRecruitmentUseCase;
  final DeleteRecruitmentUseCase deleteRecruitmentUseCase;

  SessionDetailViewModel({
    required this.sessionId,
    required this.getSessionDetailUseCase,
    required this.voteBookingUseCase,
    required this.cancelBookingUseCase,
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
      if (!mounted) return;
      state = state.copyWith(isLoading: false, detail: detail);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: _resolveErrorMessage(e));
    }
  }

  Future<SessionBooking?> voteBooking() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final booking = await voteBookingUseCase.execute(sessionId);
      if (!mounted) return booking;
      await loadDetail();
      if (!mounted) return booking;
      state = state.copyWith(isSubmitting: false);
      return booking;
    } catch (e) {
      if (!mounted) return null;
      state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      return null;
    }
  }

  Future<bool> cancelBooking() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await cancelBookingUseCase.execute(sessionId);
      if (!mounted) return true;
      await loadDetail();
      if (!mounted) return true;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      return false;
    }
  }

  Future<bool> updateStatus(String status) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await updateSessionStatusUseCase.execute(sessionId, status);
      if (!mounted) return true;
      await loadDetail();
      if (!mounted) return true;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      return false;
    }
  }

  Future<bool> deleteSession() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await deleteSessionUseCase.execute(sessionId);
      if (!mounted) return true;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      return false;
    }
  }

  Future<bool> createRecruitment(CreateRecruitmentParams params) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await createRecruitmentUseCase.execute(params);
      if (!mounted) return true;
      await loadDetail();
      if (!mounted) return true;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      return false;
    }
  }

  Future<bool> deleteRecruitment() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await deleteRecruitmentUseCase.execute(sessionId);
      if (!mounted) return true;
      await loadDetail();
      if (!mounted) return true;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      return false;
    }
  }

  String _resolveErrorMessage(dynamic error) {
    if (error is AppException) {
      if (error.message?.isNotEmpty == true) return error.message!;
      if (error is ServerException) return 'Lỗi máy chủ nội bộ (HTTP 500).';
      if (error is NotFoundException) return 'Không tìm thấy dữ liệu.';
      if (error is ForbiddenException) return 'Bạn không có quyền thực hiện thao tác này.';
      if (error is ConnectionException) return 'Không thể kết nối đến máy chủ.';
      if (error is NetworkTimeoutException) return 'Hết thời gian chờ phản hồi từ máy chủ.';
    }
    return error.toString();
  }
}
