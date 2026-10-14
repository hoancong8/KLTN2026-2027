// lib/ui/screen/club/club_management_vm/club_members_vm.dart

import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/get_club_by_id_usecase.dart';
import '../../../../domain/usecases/club/get_club_members_usecase.dart';
import '../../../../domain/usecases/club/remove_club_member_usecase.dart';
import '../../../../domain/usecases/club/update_member_role_usecase.dart';
import '../club_vm/club_context_vm.dart';
import 'club_members_state.dart';

final clubMembersViewModelProvider =
    StateNotifierProvider.autoDispose<ClubMembersViewModel, ClubMembersState>((ref) {
  final activeClubId = ref.watch(clubContextViewModelProvider).currentClubId;
  return ClubMembersViewModel(
    clubId: activeClubId ?? '',
    getClubByIdUseCase: ref.watch(getClubByIdUseCaseProvider),
    getClubMembersUseCase: ref.watch(getClubMembersUseCaseProvider),
    updateMemberRoleUseCase: ref.watch(updateMemberRoleUseCaseProvider),
    removeClubMemberUseCase: ref.watch(removeClubMemberUseCaseProvider),
  );
});

class ClubMembersViewModel extends StateNotifier<ClubMembersState> {
  final String clubId;
  final GetClubByIdUseCase getClubByIdUseCase;
  final GetClubMembersUseCase getClubMembersUseCase;
  final UpdateMemberRoleUseCase updateMemberRoleUseCase;
  final RemoveClubMemberUseCase removeClubMemberUseCase;

  ClubMembersViewModel({
    required this.clubId,
    required this.getClubByIdUseCase,
    required this.getClubMembersUseCase,
    required this.updateMemberRoleUseCase,
    required this.removeClubMemberUseCase,
  }) : super(const ClubMembersState()) {
    if (clubId.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData() async {
    await loadForClub(clubId);
  }

  Future<void> loadForClub(String targetClubId) async {
    if (targetClubId.isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        getClubByIdUseCase.execute(targetClubId),
        getClubMembersUseCase.execute(targetClubId),
      ]);

      state = state.copyWith(
        club: results[0] as dynamic,
        members: results[1] as dynamic,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppException(message: 'Lỗi tải dữ liệu CLB: $e'),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Cập nhật vai trò của thành viên trong CLB (Host only)
  Future<bool> updateRole(String memberUserId, ClubRole newRole) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      final ok = await updateMemberRoleUseCase.execute(UpdateMemberRoleParams(
        clubId: clubId,
        userId: memberUserId,
        role: newRole,
      ));

      if (ok) {
        await loadData();
        state = state.copyWith(
          isActionLoading: false,
          successMessage: 'Đã đổi vai trò thành ${newRole.displayName}',
        );
        return true;
      }
      state = state.copyWith(isActionLoading: false);
      return false;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        error: AppException(message: 'Không thể đổi vai trò: $e'),
      );
      return false;
    }
  }

  /// Xóa thành viên khỏi CLB (Host only)
  Future<bool> removeMember(String memberUserId) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      final ok = await removeClubMemberUseCase.execute(RemoveClubMemberParams(
        clubId: clubId,
        userId: memberUserId,
      ));

      if (ok) {
        await loadData();
        state = state.copyWith(
          isActionLoading: false,
          successMessage: 'Đã xóa thành viên khỏi nhóm',
        );
        return true;
      }
      state = state.copyWith(isActionLoading: false);
      return false;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        error: AppException(message: 'Không thể xóa thành viên: $e'),
      );
      return false;
    }
  }
}
