import '../../../../domain/entities/club/club.dart';
import '../../../../domain/entities/club/club_member.dart';
import '../../../../domain/entities/club/club_role_item.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ClubMembersState {
  final Club? club;
  final List<ClubMember> members;
  final List<ClubRoleItem> roles;
  final List<ClubRolePermission> availablePermissions;
  final bool isLoading;
  final bool isActionLoading;
  final bool isLoadingRoles;
  final AppException? error;
  final String? successMessage;
  final String searchQuery;

  const ClubMembersState({
    this.club,
    this.members = const [],
    this.roles = const [],
    this.availablePermissions = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.isLoadingRoles = false,
    this.error,
    this.successMessage,
    this.searchQuery = '',
  });

  List<ClubMember> get filteredMembers {
    if (searchQuery.trim().isEmpty) return members;
    final q = searchQuery.toLowerCase().trim();
    return members.where((m) {
      final name = m.userName?.toLowerCase() ?? '';
      final email = m.email?.toLowerCase() ?? '';
      final nickname = m.nickname?.toLowerCase() ?? '';
      final role = m.role.displayName.toLowerCase();
      return name.contains(q) || email.contains(q) || nickname.contains(q) || role.contains(q);
    }).toList();
  }

  ClubMembersState copyWith({
    Club? club,
    List<ClubMember>? members,
    List<ClubRoleItem>? roles,
    List<ClubRolePermission>? availablePermissions,
    bool? isLoading,
    bool? isActionLoading,
    bool? isLoadingRoles,
    AppException? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? searchQuery,
  }) {
    return ClubMembersState(
      club: club ?? this.club,
      members: members ?? this.members,
      roles: roles ?? this.roles,
      availablePermissions: availablePermissions ?? this.availablePermissions,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isLoadingRoles: isLoadingRoles ?? this.isLoadingRoles,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
