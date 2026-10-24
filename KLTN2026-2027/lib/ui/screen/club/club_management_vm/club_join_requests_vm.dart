// lib/ui/screen/club/club_management_vm/club_join_requests_vm.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/entities/club/join_request.dart';
import '../../../../domain/usecases/club/join_request_usecases.dart';
import '../../club_detail/club_detail_vm/club_detail_vm.dart';
import 'club_members_vm.dart';

class ClubJoinRequestsState {
  final bool isLoading;
  final bool isProcessing;
  final List<JoinRequest> requests;
  final String? errorMessage;
  final String? successMessage;

  const ClubJoinRequestsState({
    this.isLoading = false,
    this.isProcessing = false,
    this.requests = const [],
    this.errorMessage,
    this.successMessage,
  });

  ClubJoinRequestsState copyWith({
    bool? isLoading,
    bool? isProcessing,
    List<JoinRequest>? requests,
    String? errorMessage,
    String? successMessage,
  }) {
    return ClubJoinRequestsState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      requests: requests ?? this.requests,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final clubJoinRequestsViewModelProvider = StateNotifierProvider.autoDispose
    .family<ClubJoinRequestsViewModel, ClubJoinRequestsState, String>((ref, clubId) {
  return ClubJoinRequestsViewModel(
    ref: ref,
    clubId: clubId,
    getJoinRequestsUseCase: ref.watch(getJoinRequestsUseCaseProvider),
    approveJoinRequestUseCase: ref.watch(approveJoinRequestUseCaseProvider),
    rejectJoinRequestUseCase: ref.watch(rejectJoinRequestUseCaseProvider),
    createJoinRequestUseCase: ref.watch(createJoinRequestUseCaseProvider),
  );
});

class ClubJoinRequestsViewModel extends StateNotifier<ClubJoinRequestsState> {
  final Ref ref;
  final String clubId;
  final GetJoinRequestsUseCase getJoinRequestsUseCase;
  final ApproveJoinRequestUseCase approveJoinRequestUseCase;
  final RejectJoinRequestUseCase rejectJoinRequestUseCase;
  final CreateJoinRequestUseCase createJoinRequestUseCase;

  ClubJoinRequestsViewModel({
    required this.ref,
    required this.clubId,
    required this.getJoinRequestsUseCase,
    required this.approveJoinRequestUseCase,
    required this.rejectJoinRequestUseCase,
    required this.createJoinRequestUseCase,
  }) : super(const ClubJoinRequestsState()) {
    loadRequests();
  }

  Future<void> loadRequests() async {
    if (clubId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final requests = await getJoinRequestsUseCase.execute(clubId);
      state = state.copyWith(isLoading: false, requests: requests);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> approve(String requestId, {String? roleId, String? memberType}) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);
    try {
      await approveJoinRequestUseCase.execute(
        ApproveJoinRequestParams(
          clubId: clubId,
          requestId: requestId,
          roleId: roleId,
          memberType: memberType,
        ),
      );
      ref.invalidate(clubDetailViewModelProvider(clubId));
      ref.read(clubMembersViewModelProvider.notifier).loadForClub(clubId);
      final remaining = state.requests.where((r) => r.id != requestId).toList();
      state = state.copyWith(requests: remaining, isProcessing: false, successMessage: 'Đã chấp thuận đơn gia nhập!');
      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> reject(String requestId) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);
    try {
      await rejectJoinRequestUseCase.execute(clubId, requestId);
      ref.invalidate(clubDetailViewModelProvider(clubId));
      final remaining = state.requests.where((r) => r.id != requestId).toList();
      state = state.copyWith(requests: remaining, isProcessing: false, successMessage: 'Đã từ chối đơn gia nhập');
      await loadRequests();
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> sendRequest(String introduction) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);
    try {
      await createJoinRequestUseCase.execute(clubId, introduction: introduction);
      state = state.copyWith(isProcessing: false, successMessage: 'Đã gửi yêu cầu gia nhập!');
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: e.toString());
      return false;
    }
  }
}
