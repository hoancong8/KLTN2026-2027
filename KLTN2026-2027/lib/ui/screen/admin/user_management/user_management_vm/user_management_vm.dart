import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/exceptions/app_exception.dart';
import 'package:kltn2026_2027/domain/usecases/role/get_roles_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/user/get_users_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/user/lock_user_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/user/manage_user_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/user/update_user_roles_usecase.dart';
import 'user_management_state.dart';

final userManagementViewModelProvider =
    StateNotifierProvider.autoDispose<UserManagementViewModel, UserManagementState>((ref) {
  final getUsersUseCase = ref.watch(getUsersUseCaseProvider);
  final getRolesUseCase = ref.watch(getRolesUseCaseProvider);
  final manageUserUseCase = ref.watch(manageUserUseCaseProvider);
  final lockUserUseCase = ref.watch(lockUserUseCaseProvider);
  final updateUserRolesUseCase = ref.watch(updateUserRolesUseCaseProvider);

  return UserManagementViewModel(
    getUsersUseCase: getUsersUseCase,
    getRolesUseCase: getRolesUseCase,
    manageUserUseCase: manageUserUseCase,
    lockUserUseCase: lockUserUseCase,
    updateUserRolesUseCase: updateUserRolesUseCase,
  );
});

class UserManagementViewModel extends StateNotifier<UserManagementState> {
  final GetUsersUseCase getUsersUseCase;
  final GetRolesUseCase getRolesUseCase;
  final ManageUserUseCase manageUserUseCase;
  final LockUserUseCase lockUserUseCase;
  final UpdateUserRolesUseCase updateUserRolesUseCase;

  UserManagementViewModel({
    required this.getUsersUseCase,
    required this.getRolesUseCase,
    required this.manageUserUseCase,
    required this.lockUserUseCase,
    required this.updateUserRolesUseCase,
  }) : super(const UserManagementState()) {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      loadUsers(),
      loadRoles(),
    ]);
  }

  Future<void> loadUsers({int? page, String? search}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      pageNumber: page ?? state.pageNumber,
      searchQuery: search ?? state.searchQuery,
    );

    try {
      debugPrint('[UserManagementVM] Calling getUsers (page: ${state.pageNumber}, size: ${state.pageSize}, search: ${state.searchQuery})...');
      final pagedResult = await getUsersUseCase.execute(
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
        searchTerm: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      debugPrint('[UserManagementVM] Successfully loaded ${pagedResult.items.length} users (total: ${pagedResult.totalCount})');

      state = state.copyWith(
        isLoading: false,
        users: pagedResult.items,
        totalCount: pagedResult.totalCount,
        totalPages: pagedResult.totalPages,
        pageNumber: pagedResult.pageNumber,
      );
    } on AppException catch (e) {
      debugPrint('[UserManagementVM] AppException in loadUsers: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e, stack) {
      debugPrint('[UserManagementVM] Unexpected error in loadUsers: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải danh sách người dùng: $e',
      );
    }
  }

  Future<void> loadRoles() async {
    try {
      final roles = await getRolesUseCase.execute();
      state = state.copyWith(roles: roles);
    } catch (e) {
      debugPrint('[UserManagementVM] Error loading roles: $e');
    }
  }

  void setFilter(int index) {
    state = state.copyWith(selectedFilterIndex: index);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> createUser({
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageUserUseCase.createUser(email, password, roles);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Thêm tài khoản thành công',
      );
      await loadUsers();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể tạo tài khoản: $e');
      return false;
    }
  }

  Future<bool> updateUser({
    required String id,
    required String email,
    required String userName,
    String? phoneNumber,
    required List<String> roles,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageUserUseCase.updateUser(id, email, userName, phoneNumber: phoneNumber);
      await updateUserRolesUseCase.execute(id, roles);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Cập nhật tài khoản thành công',
      );
      await loadUsers();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể cập nhật: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageUserUseCase.deleteUser(id);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Xóa tài khoản thành công',
      );
      await loadUsers();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể xóa: $e');
      return false;
    }
  }

  Future<bool> toggleLockUser(String id, bool currentlyLocked) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await lockUserUseCase.execute(id, !currentlyLocked);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: currentlyLocked ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản',
      );
      await loadUsers();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Lỗi cập nhật trạng thái khóa: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String id, String newPassword) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageUserUseCase.resetPassword(id, newPassword);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Đặt lại mật khẩu thành công',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể đặt lại mật khẩu: $e');
      return false;
    }
  }
}
