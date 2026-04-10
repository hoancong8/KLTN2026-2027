import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../widget/responsive_layout.dart';
import '../../../blocked_users/blocked_user_screen.dart';
import '../../../chat_detail/chat_detail_screen.dart';
import '../../../chat_detail/chat_detail_vm/chat_detail_vm.dart';
import '../../../add_friend/add_friend_screen.dart';
import 'chat_vm/chat_vm.dart';
import 'widgets/chat_page_mobile.dart';
import 'widgets/chat_page_tablet.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  dynamic _selectedChat; // For tablet master-detail pattern

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).loadUsers();
    });
  }

  void _onRefresh() async {
    await ref.read(chatViewModelProvider.notifier).loadUsers();
  }

  void _onUserTap(BuildContext context, dynamic user, bool isTablet) async {
    if (isTablet) {
      // Tablet: Show in right panel
      setState(() => _selectedChat = user);
      ref.read(chatViewModelProvider.notifier).setActiveChatFriend(user.userId);
    } else {
      // Mobile: Navigate to detail screen
      ref.read(chatViewModelProvider.notifier).setActiveChatFriend(user.userId);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            userId: user.userId,
            userName: user.userName,
            isOnline: user.isOnline,

          ),
        ),
      );

      ref.read(chatViewModelProvider.notifier).clearActiveChatFriend();
      ref.read(chatViewModelProvider.notifier).resetUnreadCount(user.userId);

      ref
          .read(
        chatDetailViewModelProvider(
          ChatDetailParams(
            friendUserId: user.userId,
            initialIsOnline: user.isOnline,
          ),
        ).notifier,
      )
          .markAllAsRead();
    }
  }

  void _onSearchChanged(String value) {
    ref.read(chatViewModelProvider.notifier).search(value);
  }

  void _onAddFriendPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFriendScreen()),
    ).then((_) {
      ref.read(chatViewModelProvider.notifier).loadUsers();
    });
  }

  void _onBlockedUsersPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
    ).then((_) {
      ref.read(chatViewModelProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);

    return ResponsiveLayout(
      mobile: ChatPageMobile(
        state: state,
        onRefresh: _onRefresh,
        onUserTap: (user) => _onUserTap(context, user, false),
        onSearchChanged: _onSearchChanged,
        onAddFriendPressed: () => _onAddFriendPressed(context),
        onBlockedUsersPressed: () => _onBlockedUsersPressed(context),
      ),
      tablet: ChatPageTablet(
        state: state,
        selectedChat: _selectedChat,
        onRefresh: _onRefresh,
        onUserTap: (user) => _onUserTap(context, user, true),
        onSearchChanged: _onSearchChanged,
        onAddFriendPressed: () => _onAddFriendPressed(context),
        onBlockedUsersPressed: () => _onBlockedUsersPressed(context),
        onCloseChat: () => setState(() => _selectedChat = null),
      ),
    );
  }
}
