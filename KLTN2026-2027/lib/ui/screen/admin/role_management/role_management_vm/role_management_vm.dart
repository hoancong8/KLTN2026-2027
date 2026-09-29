import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/domain/exceptions/app_exception.dart';
import 'package:kltn2026_2027/domain/usecases/role/get_roles_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/role/manage_role_usecase.dart';
import 'package:kltn2026_2027/domain/usecases/user/get_all_permissions_usecase.dart';
import 'role_management_state.dart';

final roleManagementViewModelProvider =
    StateNotifierProvider.autoDispose<RoleManagementViewModel, RoleManagementState>((ref) {
  final getRolesUseCase = ref.watch(getRolesUseCaseProvider);
  final getAllPermissionsUseCase = ref.watch(getAllPermissionsUseCaseProvider);
  final manageRoleUseCase = ref.watch(manageRoleUseCaseProvider);

  return RoleManagementViewModel(
    getRolesUseCase: getRolesUseCase,
    getAllPermissionsUseCase: getAllPermissionsUseCase,
    manageRoleUseCase: manageRoleUseCase,
  );
});

class RoleManagementViewModel extends StateNotifier<RoleManagementState> {
  final GetRolesUseCase getRolesUseCase;
  final GetAllPermissionsUseCase getAllPermissionsUseCase;
  final ManageRoleUseCase manageRoleUseCase;

  RoleManagementViewModel({
    required this.getRolesUseCase,
    required this.getAllPermissionsUseCase,
    required this.manageRoleUseCase,
  }) : super(const RoleManagementState()) {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      loadRoles(),
      loadAllPermissions(),
    ]);
  }

  Future<void> loadRoles() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      debugPrint('[RoleManagementVM] Loading roles from API...');
      final roles = await getRolesUseCase.execute();
      debugPrint('[RoleManagementVM] Loaded ${roles.length} roles successfully');
      state = state.copyWith(isLoading: false, roles: roles);
    } on AppException catch (e) {
      debugPrint('[RoleManagementVM] AppException in loadRoles: ${e.message}');
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e, stack) {
      debugPrint('[RoleManagementVM] Error in loadRoles: $e\n$stack');
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi tải danh sách vai trò: $e');
    }
  }

  Future<void> loadAllPermissions() async {
    try {
      debugPrint('[RoleManagementVM] Loading all system permissions tree...');
      final groups = await getAllPermissionsUseCase.execute();
      debugPrint('[RoleManagementVM] Loaded ${groups.length} root permission groups');
      state = state.copyWith(allPermissionGroups: groups);
    } catch (e) {
      debugPrint('[RoleManagementVM] Error loading permissions tree: $e');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> createRole({
    required String name,
    required String description,
    required List<String> permissions,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageRoleUseCase.createRole(name, description);
      
      // Sau khi tạo vai trò, nếu có chọn permissions, reload roles và gán permissions cho vai trò mới
      await loadRoles();
      if (permissions.isNotEmpty) {
        final newRole = state.roles.firstWhere(
          (r) => r.name.toLowerCase() == name.toLowerCase(),
          orElse: () => state.roles.last,
        );
        if (newRole.id.isNotEmpty) {
          await manageRoleUseCase.assignRolePermissions(newRole.id, permissions);
          await loadRoles();
        }
      }

      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Tạo vai trò thành công',
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể tạo vai trò: $e');
      return false;
    }
  }

  Future<bool> updateRole({
    required String id,
    required String name,
    required String description,
    required List<String> permissions,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageRoleUseCase.updateRole(id, name, description);
      await manageRoleUseCase.assignRolePermissions(id, permissions);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Cập nhật vai trò thành công',
      );
      await loadRoles();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể cập nhật: $e');
      return false;
    }
  }

  Future<bool> deleteRole(String id) async {
    state = state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true);
    try {
      await manageRoleUseCase.deleteRole(id);
      state = state.copyWith(
        isActionLoading: false,
        successMessage: 'Xóa vai trò thành công',
      );
      await loadRoles();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, errorMessage: 'Không thể xóa vai trò: $e');
      return false;
    }
  }
}
