import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';
import 'package:sipm_mobile/domain/entities/chat_friend.dart';
import 'package:sipm_mobile/app/provider.dart';

import '../../../domain/entities/friend_ship_state.dart';
import '../../../domain/usecases/friend/get_chat_friends_usecase.dart';
import '../../../domain/usecases/friend/unblock_user_usecase.dart';

class BlockedUsersState {
  final bool isLoading;
  final List<ChatFriend> blockedUsers;
  final String? error;

  const BlockedUsersState({
    this.isLoading = false,
    this.blockedUsers = const [],
    this.error,
  });

  BlockedUsersState copyWith({
    bool? isLoading,
    List<ChatFriend>? blockedUsers,
    String? error,
  }) {
    return BlockedUsersState(
      isLoading: isLoading ?? this.isLoading,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      error: error,
    );
  }
}

final blockedUsersViewModelProvider =
    StateNotifierProvider.autoDispose<BlockedUsersViewModel, BlockedUsersState>(
      (ref) {
        return BlockedUsersViewModel(
          ref.watch(getChatFriendsUseCaseProvider),
          ref.watch(unblockUserUseCaseProvider),
        );
      },
    );

class BlockedUsersViewModel extends StateNotifier<BlockedUsersState> {
  final GetChatFriendsUseCase getChatFriendsUseCase;
  final UnblockUserUseCase unblockUserUseCase;

  BlockedUsersViewModel(this.getChatFriendsUseCase, this.unblockUserUseCase)
    : super(const BlockedUsersState());

  Future<void> loadBlockedUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final friends = await getChatFriendsUseCase.execute();
      if (!mounted) return;

      final blocked = friends
          .where((f) => f.state == FriendshipState.blocked)
          .toList();

      state = state.copyWith(isLoading: false, blockedUsers: blocked);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unblockUser(int userId, int? tenantId) async {
    try {
      await unblockUserUseCase.execute(userId, tenantId);
      if (!mounted) return;

      // Reload list after unblock
      await loadBlockedUsers();
    } catch (e) {
      // Handle error (maybe show toast via UI listener)
      AppLog.info('Unblock failed: $e');
    }
  }
}
