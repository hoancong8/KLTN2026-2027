import 'package:kltn2026_2027/domain/entities/chat_friend.dart';
import 'package:kltn2026_2027/domain/exceptions/app_exception.dart';

class ChatState {
  final bool isLoading;
  final AppException? error;
  final List<ChatFriend> users;
  final List<ChatFriend> allUsers;
  final int totalUnreadCount;
  final int unreadUsersCount;

  const ChatState({
    this.isLoading = false,
    this.error,
    this.users = const [],
    this.allUsers = const [],
    this.totalUnreadCount = 0,
    this.unreadUsersCount = 0,
  });

  ChatState copyWith({
    bool? isLoading,
    AppException? error,
    List<ChatFriend>? users,
    List<ChatFriend>? allUsers,
  }) {
    final newUsers = users ?? this.users;
    final newAllUsers = allUsers ?? this.allUsers;
    final newTotalUnread = newAllUsers.fold<int>(
      0,
      (sum, user) => sum + user.unreadMessageCount,
    );
    final newUnreadUsers = newAllUsers
        .where((user) => user.unreadMessageCount > 0)
        .length;
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      users: newUsers,
      allUsers: newAllUsers,
      totalUnreadCount: newTotalUnread,
      unreadUsersCount: newUnreadUsers,
    );
  }
}
