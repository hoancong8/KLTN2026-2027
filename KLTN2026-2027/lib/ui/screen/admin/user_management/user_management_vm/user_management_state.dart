import 'package:equatable/equatable.dart';
import 'package:kltn2026_2027/domain/entities/app_role.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';

class UserManagementState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final List<UserProfile> users;
  final List<AppRole> roles;
  final int selectedFilterIndex; // 0: Tất cả, 1: Đã kích hoạt, 2: Bị khóa
  final String searchQuery;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final String? errorMessage;
  final String? successMessage;

  const UserManagementState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.users = const [],
    this.roles = const [],
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    this.pageNumber = 1,
    this.pageSize = 10,
    this.totalCount = 0,
    this.totalPages = 0,
    this.errorMessage,
    this.successMessage,
  });

  /// Danh sách User đã lọc theo Tab trạng thái và Tìm kiếm
  List<UserProfile> get filteredUsers {
    List<UserProfile> result = users;

    // Lọc theo trạng thái tab
    if (selectedFilterIndex == 1) {
      // Đã kích hoạt (không bị khóa)
      result = result.where((u) => !u.isLocked).toList();
    } else if (selectedFilterIndex == 2) {
      // Bị khóa
      result = result.where((u) => u.isLocked).toList();
    }

    // Lọc theo từ khóa tìm kiếm
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((u) {
        final nameMatch = u.userName.toLowerCase().contains(q);
        final emailMatch = u.email.toLowerCase().contains(q);
        final phoneMatch = u.phoneNumber?.toLowerCase().contains(q) ?? false;
        final roleMatch = u.roles.any((r) => r.toLowerCase().contains(q));
        return nameMatch || emailMatch || phoneMatch || roleMatch;
      }).toList();
    }

    return result;
  }

  UserManagementState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<UserProfile>? users,
    List<AppRole>? roles,
    int? selectedFilterIndex,
    String? searchQuery,
    int? pageNumber,
    int? pageSize,
    int? totalCount,
    int? totalPages,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return UserManagementState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      users: users ?? this.users,
      roles: roles ?? this.roles,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        users,
        roles,
        selectedFilterIndex,
        searchQuery,
        pageNumber,
        pageSize,
        totalCount,
        totalPages,
        errorMessage,
        successMessage,
      ];
}
