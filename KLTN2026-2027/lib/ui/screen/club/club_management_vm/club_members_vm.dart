import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/usecases/club/club_role_usecases.dart';
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
    getClubRolesUseCase: ref.watch(getClubRolesUseCaseProvider),
    getClubPermissionsUseCase: ref.watch(getClubPermissionsUseCaseProvider),
    updateClubRolePermissionsUseCase: ref.watch(updateClubRolePermissionsUseCaseProvider),
    createClubRoleUseCase: ref.watch(createClubRoleUseCaseProvider),
    deleteClubRoleUseCase: ref.watch(deleteClubRoleUseCaseProvider),
  );
});

class ClubMembersViewModel extends StateNotifier<ClubMembersState> {
  final String clubId;
  final GetClubByIdUseCase getClubByIdUseCase;
  final GetClubMembersUseCase getClubMembersUseCase;
  final UpdateMemberRoleUseCase updateMemberRoleUseCase;
  final RemoveClubMemberUseCase removeClubMemberUseCase;
  final GetClubRolesUseCase getClubRolesUseCase;
  final GetClubPermissionsUseCase getClubPermissionsUseCase;
  final UpdateClubRolePermissionsUseCase updateClubRolePermissionsUseCase;
  final CreateClubRoleUseCase createClubRoleUseCase;
  final DeleteClubRoleUseCase deleteClubRoleUseCase;

  ClubMembersViewModel({
    required this.clubId,
    required this.getClubByIdUseCase,
    required this.getClubMembersUseCase,
    required this.updateMemberRoleUseCase,
    required this.removeClubMemberUseCase,
    required this.getClubRolesUseCase,
    required this.getClubPermissionsUseCase,
    required this.updateClubRolePermissionsUseCase,
    required this.createClubRoleUseCase,
    required this.deleteClubRoleUseCase,
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

  /// Tải danh sách vai trò nội bộ và bảng quyền nhóm chuẩn
  Future<void> loadRolesAndPermissions() async {
    state = state.copyWith(isLoadingRoles: true, clearError: true);
    try {
      final results = await Future.wait([
        getClubRolesUseCase.execute(clubId),
        getClubPermissionsUseCase.execute(),
      ]);

      state = state.copyWith(
        roles: results[0] as dynamic,
        availablePermissions: results[1] as dynamic,
        isLoadingRoles: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoadingRoles: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoadingRoles: false,
        error: AppException(message: 'Lỗi tải phân quyền: $e'),
      );
    }
  }

  /// Cập nhật danh sách quyền cho một vai trò trong nhóm (FR03)
  Future<bool> updateRolePermissions(String roleId, List<String> permissionIds) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      final ok = await updateClubRolePermissionsUseCase.execute(clubId, roleId, permissionIds);
      if (ok) {
        // Tải lại vai trò để cập nhật UI
        final updatedRoles = await getClubRolesUseCase.execute(clubId);
        state = state.copyWith(
          isActionLoading: false,
          roles: updatedRoles,
          successMessage: 'Cập nhật phân quyền thành công!',
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
        error: AppException(message: 'Không thể cập nhật quyền: $e'),
      );
      return false;
    }
  }

  /// Tạo vai trò mới cho câu lạc bộ (FR03)
  Future<bool> createRole({
    required String roleName,
    String? description,
    List<String> permissionIds = const [],
    bool isDefault = false,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await createClubRoleUseCase.execute(CreateClubRoleParams(
        clubId: clubId,
        roleName: roleName,
        description: description,
        permissionIds: permissionIds,
        isDefault: isDefault,
      ));

      // Tải lại danh sách vai trò
      final updatedRoles = await getClubRolesUseCase.execute(clubId);
      state = state.copyWith(
        isActionLoading: false,
        roles: updatedRoles,
        successMessage: 'Tạo vai trò mới thành công!',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        error: AppException(message: 'Không thể tạo vai trò: $e'),
      );
      return false;
    }
  }

  /// Xóa vai trò tùy chỉnh khỏi câu lạc bộ (FR03)
  Future<bool> deleteRole(String roleId) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      final ok = await deleteClubRoleUseCase.execute(clubId, roleId);
      if (ok) {
        final updatedRoles = await getClubRolesUseCase.execute(clubId);
        state = state.copyWith(
          isActionLoading: false,
          roles: updatedRoles,
          successMessage: 'Đã xóa vai trò thành công!',
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
        error: AppException(message: 'Không thể xóa vai trò: $e'),
      );
      return false;
    }
  }
}
