import 'package:equatable/equatable.dart';
import 'package:kltn2026_2027/domain/entities/app_role.dart';
import 'package:kltn2026_2027/domain/entities/permission_group.dart';

class RoleManagementState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final List<AppRole> roles;
  final List<PermissionGroup> allPermissionGroups;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const RoleManagementState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.roles = const [],
    this.allPermissionGroups = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  List<AppRole> get filteredRoles {
    if (searchQuery.trim().isEmpty) return roles;
    final q = searchQuery.trim().toLowerCase();
    return roles.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
    }).toList();
  }

  RoleManagementState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<AppRole>? roles,
    List<PermissionGroup>? allPermissionGroups,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RoleManagementState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      roles: roles ?? this.roles,
      allPermissionGroups: allPermissionGroups ?? this.allPermissionGroups,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        roles,
        allPermissionGroups,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}
