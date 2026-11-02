// lib/ui/screen/club/session_vm/club_sessions_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../app/utils/app_exception_handler.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import 'club_sessions_state.dart';

final clubSessionsViewModelProvider =
    StateNotifierProvider.autoDispose.family<ClubSessionsViewModel, ClubSessionsState, String>((ref, clubId) {
  return ClubSessionsViewModel(
    clubId: clubId,
    getClubSessionsUseCase: ref.watch(getClubSessionsUseCaseProvider),
    createSessionUseCase: ref.watch(createSessionUseCaseProvider),
  );
});

class ClubSessionsViewModel extends StateNotifier<ClubSessionsState> {
  final String clubId;
  final GetClubSessionsUseCase getClubSessionsUseCase;
  final CreateSessionUseCase createSessionUseCase;

  ClubSessionsViewModel({
    required this.clubId,
    required this.getClubSessionsUseCase,
    required this.createSessionUseCase,
  }) : super(const ClubSessionsState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    if (clubId.isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sessions = await getClubSessionsUseCase.execute(clubId);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, sessions: sessions, clearError: true);
    } catch (e) {
      if (!mounted) return;
      final appException = AppExceptionHandler.handle(e);
      state = state.copyWith(
        isLoading: false,
        error: appException,
        errorMessage: _resolveErrorMessage(appException),
      );
    }
  }

  Future<String?> createSession(CreateSessionParams params) async {
    try {
      final sessionId = await createSessionUseCase.execute(params);
      if (!mounted) return sessionId;
      await loadSessions();
      return sessionId;
    } catch (e) {
      if (!mounted) return null;
      final appException = AppExceptionHandler.handle(e);
      state = state.copyWith(
        error: appException,
        errorMessage: _resolveErrorMessage(appException),
      );
      return null;
    }
  }

  String _resolveErrorMessage(dynamic error) {
    if (error is AppException) {
      if (error.message?.isNotEmpty == true) return error.message!;
      if (error is ServerException) return 'Lỗi máy chủ nội bộ (HTTP 500). Vui lòng kiểm tra lại phía Backend.';
      if (error is NotFoundException) return 'Không tìm thấy dữ liệu buổi sinh hoạt.';
      if (error is ForbiddenException) return 'Bạn không có quyền xem hoặc thao tác trên lịch này.';
      if (error is ConnectionException) return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
      if (error is NetworkTimeoutException) return 'Hết thời gian chờ phản hồi từ máy chủ.';
    }
    return error.toString();
  }
}
