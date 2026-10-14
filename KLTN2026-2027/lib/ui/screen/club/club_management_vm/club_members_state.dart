// lib/ui/screen/club/club_management_vm/club_members_state.dart

import '../../../../domain/entities/club/club.dart';
import '../../../../domain/entities/club/club_member.dart';
import '../../../../domain/exceptions/app_exception.dart';

class ClubMembersState {
  final Club? club;
  final List<ClubMember> members;
  final bool isLoading;
  final bool isActionLoading;
  final AppException? error;
  final String? successMessage;
  final String searchQuery;

  const ClubMembersState({
    this.club,
    this.members = const [],
    this.isLoading = false,
    this.isActionLoading = false,
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
    bool? isLoading,
    bool? isActionLoading,
    AppException? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? searchQuery,
  }) {
    return ClubMembersState(
      club: club ?? this.club,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
