import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/domain/exceptions/app_exception.dart';
import 'package:sipm_mobile/app/consts/app_log.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../domain/entities/chat_friend.dart';
import '../../../../../../domain/entities/friend_ship_state.dart';
import '../../../../../../domain/services/i_signalr_service.dart';
import '../../../../../../domain/usecases/friend/get_chat_friends_usecase.dart';
import 'chat_state.dart';

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((
  ref,
) {
  return ChatViewModel(
    ref.watch(getChatFriendsUseCaseProvider),
    ref.watch(signalRServiceProvider),
  );
});

class ChatViewModel extends StateNotifier<ChatState> {
  final GetChatFriendsUseCase getChatFriendsUseCase;
  final ISignalRService signalRService;

  // Theo dõi chat đang mở để không tăng unread count
  int? _activeChatFriendUserId;

  ChatViewModel(this.getChatFriendsUseCase, this.signalRService)
    : super(const ChatState());

  /// Đánh dấu đang xem chat với user này
  void setActiveChatFriend(int userId) {
    _activeChatFriendUserId = userId;
    AppLog.info('[Chat] Active chat set to userId: $userId');
  }

  /// Clear khi rời khỏi chat detail
  void clearActiveChatFriend() {
    AppLog.info('[Chat] Active chat cleared (was: $_activeChatFriendUserId)');
    _activeChatFriendUserId = null;
  }

  /// Reset unread count cho user cụ thể (local state, không gọi API)
  void resetUnreadCount(int userId) {
    ChatFriend update(ChatFriend user) {
      if (user.userId == userId) {
        return ChatFriend(
          userId: user.userId,
          tenantId: user.tenantId,
          userName: user.userName,
          tenancyName: user.tenancyName,
          profilePictureId: user.profilePictureId,
          unreadMessageCount: 0,
          isOnline: user.isOnline,
          state: user.state,
        );
      }
      return user;
    }

    final updatedAllUsers = state.allUsers.map(update).toList();
    final updatedUsers = state.users.map(update).toList();
    state = state.copyWith(users: updatedUsers, allUsers: updatedAllUsers);
  }

  void handleNewMessage(Map<String, dynamic> data) {
    AppLog.info('[Chat] New message: $data');

    if (!mounted) {
      AppLog.info('[Chat] Not mounted, skipping');
      return;
    }

    // targetUserId là người gửi (từ phía web gửi đến mobile)
    final senderId = data['targetUserId'] as int?;

    if (senderId == null) {
      AppLog.info('[Chat] targetUserId is null, skipping');
      return;
    }

    // Skip tăng unread count nếu đang xem chat với người gửi này
    if (_activeChatFriendUserId == senderId) {
      AppLog.info(
        '[Chat] User is viewing this chat, skipping unread increment',
      );
      return;
    }

    AppLog.info('[Chat] Sender ID: $senderId');
    AppLog.info(
      '[Chat] Available user IDs: ${state.users.map((u) => u.userId).toList()}',
    );

    // Need to update both `allUsers` and `users` (if currently visible)
    // To simplify: update `allUsers` first, then re-apply search filter if needed?
    // Or just update both lists manually.
    // Ideally we should keep a separate filters state but here we just have lists.
    // Let's assume we update `allUsers` and then map `users` similarly.

    bool found = false;
    final updatedAllUsers = state.allUsers.map((user) {
      if (user.userId == senderId) {
        found = true;
        // ... print ...
        return ChatFriend(
          userId: user.userId,
          tenantId: user.tenantId,
          userName: user.userName,
          tenancyName: user.tenancyName,
          profilePictureId: user.profilePictureId,
          unreadMessageCount: user.unreadMessageCount + 1,
          isOnline: user.isOnline,
          state: user.state,
        );
      }
      return user;
    }).toList();

    if (!found) {
      AppLog.info(
        '[Chat] WARNING: User with ID $senderId not found in friends list',
      );
      loadUsers();
      return;
    }

    // Also update `users` (displayed list)
    final updatedUsers = state.users.map((user) {
      if (user.userId == senderId) {
        return ChatFriend(
          userId: user.userId,
          tenantId: user.tenantId,
          userName: user.userName,
          tenancyName: user.tenancyName,
          profilePictureId: user.profilePictureId,
          unreadMessageCount: user.unreadMessageCount + 1,
          isOnline: user.isOnline,
          state: user.state,
        );
      }
      return user;
    }).toList();

    state = state.copyWith(users: updatedUsers, allUsers: updatedAllUsers);
    AppLog.info(
      '[Chat] State updated. Unread users count: ${state.unreadUsersCount}',
    );
  }

  void handleUserConnectionChange(Map<String, dynamic> data) {
    AppLog.info('[Chat] Connection change: $data');

    final friend = data['friend'] as Map<String, dynamic>?;
    final isConnected = data['isConnected'] as bool?;

    if (friend == null || isConnected == null || !mounted) return;

    final friendUserId = friend['friendUserId'] as int?;
    if (friendUserId == null) return;

    ChatFriend updateFriend(ChatFriend user) {
      if (user.userId == friendUserId) {
        return ChatFriend(
          userId: user.userId,
          tenantId: user.tenantId,
          userName: user.userName,
          tenancyName: user.tenancyName,
          profilePictureId: user.profilePictureId,
          unreadMessageCount: user.unreadMessageCount,
          isOnline: isConnected,
          state: user.state,
        );
      }
      return user;
    }

    final updatedAllUsers = state.allUsers.map(updateFriend).toList();
    final updatedUsers = state.users.map(updateFriend).toList();

    state = state.copyWith(users: updatedUsers, allUsers: updatedAllUsers);
  }

  void handleMessagesRead(Map<String, dynamic> data) {
    AppLog.info('[Chat] Messages read: $data');

    final friend = data['friend'] as Map<String, dynamic>?;
    if (friend == null || !mounted) return;

    final friendUserId = friend['userId'] as int?;
    if (friendUserId == null) return;

    ChatFriend updateFriend(ChatFriend user) {
      if (user.userId == friendUserId) {
        return ChatFriend(
          userId: user.userId,
          tenantId: user.tenantId,
          userName: user.userName,
          tenancyName: user.tenancyName,
          profilePictureId: user.profilePictureId,
          unreadMessageCount: 0,
          isOnline: user.isOnline,
          state: user.state,
        );
      }
      return user;
    }

    final updatedAllUsers = state.allUsers.map(updateFriend).toList();
    final updatedUsers = state.users.map(updateFriend).toList();

    state = state.copyWith(users: updatedUsers, allUsers: updatedAllUsers);
  }

  Future<void> loadUsers() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final friends = await getChatFriendsUseCase.execute();
      if (!mounted) return;

      // Chỉ hiển thị user chưa bị block (state != 2)
      final activeFriends = friends
          .where((f) => f.state != FriendshipState.blocked)
          .toList();

      state = state.copyWith(
        isLoading: false,
        users: activeFriends,
        allUsers: activeFriends, // Init both
      );
    } on AppException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        // error: AppExceptionHandler.handle(e),
      );
    }
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      state = state.copyWith(users: state.allUsers);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = state.allUsers.where((user) {
      return user.userName.toLowerCase().contains(lowerQuery);
    }).toList();

    state = state.copyWith(users: filtered);
  }

  void onUserTap(ChatFriend user) {
    AppLog.info('Tapped on user: ${user.userName}');
    // Navigation will be handled in chat_page.dart
  }
}
