// lib/ui/screen/club/session_vm/session_detail_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/session/session_booking.dart';
import '../../../../domain/enums/session_enums.dart';
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
    confirmBookingUseCase: ref.watch(confirmBookingUseCaseProvider),
    updateSessionUseCase: ref.watch(updateSessionUseCaseProvider),
    setShortageReminderUseCase: ref.watch(setShortageReminderUseCaseProvider),
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
  final UpdateSessionUseCase updateSessionUseCase;
  final SetShortageReminderUseCase? setShortageReminderUseCase;
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
    required this.updateSessionUseCase,
    this.setShortageReminderUseCase,
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

  Future<bool> updateSession({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String courtLocation,
    required int courtCount,
    required int maxPlayers,
    required DateTime deadlineBooking,
    int? minimumPlayers,
    int? shortageCheckMinutes,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await updateSessionUseCase.execute(UpdateSessionParams(
        sessionId: sessionId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        courtLocation: courtLocation,
        courtCount: courtCount,
        maxPlayers: maxPlayers,
        deadlineBooking: deadlineBooking,
        minimumPlayers: minimumPlayers,
        shortageCheckMinutes: shortageCheckMinutes,
      ));
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

  Future<bool> setShortageReminder(int? delayMinutes) async {
    final useCase = setShortageReminderUseCase;
    if (useCase == null || state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await useCase.execute(sessionId, delayMinutes);
      if (!mounted) return true;
      await loadDetail();
      if (mounted) state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isSubmitting: false, errorMessage: _resolveErrorMessage(e));
      }
      return false;
    }
  }

  Future<bool> updateStatus(String status, {bool confirmRemainingNoShows = true}) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await updateSessionStatusUseCase.execute(
        sessionId,
        status,
        confirmRemainingNoShows: confirmRemainingNoShows,
      );
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

  void applyRealtimeBookingUpdate({
    required String targetUserId,
    required String action,
    required String currentUserId,
  }) {
    final currentDetail = state.detail;
    if (currentDetail == null) return;

    final isMe = currentUserId.isNotEmpty && targetUserId.toLowerCase() == currentUserId.toLowerCase();
    final actionUpper = action.toUpperCase();

    if (actionUpper == 'CONFIRMED') {
      final waitingList = List<SessionBooking>.from(currentDetail.waitingQueue);
      final confirmedList = List<SessionBooking>.from(currentDetail.confirmedPlayers);

      final indexInWaiting = waitingList.indexWhere((p) => p.userId.toLowerCase() == targetUserId.toLowerCase());
      if (indexInWaiting != -1) {
        final player = waitingList.removeAt(indexInWaiting);
        final confirmedPlayer = player.copyWith(
          status: BookingStatus.confirmed,
          queueOrder: 0,
        );
        confirmedList.add(confirmedPlayer);

        for (var i = 0; i < waitingList.length; i++) {
          final w = waitingList[i];
          if (w.queueOrder > player.queueOrder) {
            waitingList[i] = w.copyWith(queueOrder: (w.queueOrder - 1).clamp(1, 999));
          }
        }

        final updatedSession = currentDetail.session.copyWith(
          confirmedCount: confirmedList.length,
          waitingCount: waitingList.length,
          isBookedByCurrentUser: isMe ? true : currentDetail.session.isBookedByCurrentUser,
          currentUserBookingStatus: isMe ? BookingStatus.confirmed : currentDetail.session.currentUserBookingStatus,
          currentUserQueueOrder: isMe ? 0 : currentDetail.session.currentUserQueueOrder,
        );

        state = state.copyWith(
          detail: currentDetail.copyWith(
            session: updatedSession,
            confirmedPlayers: confirmedList,
            waitingQueue: waitingList,
          ),
        );
      }
    } else if (actionUpper == 'CANCELLED') {
      final waitingList = List<SessionBooking>.from(currentDetail.waitingQueue);
      final confirmedList = List<SessionBooking>.from(currentDetail.confirmedPlayers);

      final waitingIndex = waitingList.indexWhere((p) => p.userId.toLowerCase() == targetUserId.toLowerCase());
      final confirmedIndex = confirmedList.indexWhere((p) => p.userId.toLowerCase() == targetUserId.toLowerCase());

      if (waitingIndex != -1) {
        final removed = waitingList.removeAt(waitingIndex);
        for (var i = 0; i < waitingList.length; i++) {
          final w = waitingList[i];
          if (w.queueOrder > removed.queueOrder) {
            waitingList[i] = w.copyWith(queueOrder: (w.queueOrder - 1).clamp(1, 999));
          }
        }
      } else if (confirmedIndex != -1) {
        confirmedList.removeAt(confirmedIndex);
        if (waitingList.isNotEmpty) {
          waitingList.sort((a, b) => a.queueOrder.compareTo(b.queueOrder));
          final promoted = waitingList.removeAt(0).copyWith(
            status: BookingStatus.confirmed,
            queueOrder: 0,
          );
          confirmedList.add(promoted);
          for (var i = 0; i < waitingList.length; i++) {
            waitingList[i] = waitingList[i].copyWith(queueOrder: (waitingList[i].queueOrder - 1).clamp(1, 999));
          }
        }
      }

      final updatedSession = currentDetail.session.copyWith(
        confirmedCount: confirmedList.length,
        waitingCount: waitingList.length,
        isBookedByCurrentUser: isMe ? false : currentDetail.session.isBookedByCurrentUser,
        currentUserBookingStatus: isMe ? null : currentDetail.session.currentUserBookingStatus,
        currentUserQueueOrder: isMe ? 0 : currentDetail.session.currentUserQueueOrder,
      );

      state = state.copyWith(
        detail: currentDetail.copyWith(
          session: updatedSession,
          confirmedPlayers: confirmedList,
          waitingQueue: waitingList,
        ),
      );
    }

    silentRefresh();
  }

  Future<void> silentRefresh() async {
    try {
      final detail = await getSessionDetailUseCase.execute(sessionId);
      if (!mounted) return;
      state = state.copyWith(detail: detail);
    } catch (_) {}
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
