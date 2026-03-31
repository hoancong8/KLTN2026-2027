import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/ui/screen/home/tab/chat/widgets/chat_list_item.dart';
import '../../../blocked_users/blocked_user_screen.dart';
import '../../../chat_detail/chat_detail_screen.dart';
import '../../../chat_detail/chat_detail_vm/chat_detail_vm.dart';
import '../../../add_friend/add_friend_screen.dart';
import 'chat_vm/chat_vm.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.cError.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColor.cError,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: TextStyle(color: AppColor.cError, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(chatViewModelProvider.notifier).loadUsers(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cMain,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Remove the early return for empty state

    return RefreshIndicator(
      color: AppColor.cMain,
      backgroundColor: AppColor.white,
      onRefresh: () async {
        await ref.read(chatViewModelProvider.notifier).loadUsers();
      },
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: state.users.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.cMain.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColor.cMain,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy cuộc trò chuyện',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cTitle,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ChatListItem(
                  user: user,
                  onTap: () async {
                    ref
                        .read(chatViewModelProvider.notifier)
                        .setActiveChatFriend(user.userId);

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

                    ref
                        .read(chatViewModelProvider.notifier)
                        .clearActiveChatFriend();
                    // Cập nhật local state ngay (không rebuild toàn bộ list)
                    ref
                        .read(chatViewModelProvider.notifier)
                        .resetUnreadCount(user.userId);
                    // Báo server đã đọc (fire-and-forget)
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.cMain.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chat_outlined,
                  color: AppColor.cMain,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tin nhắn',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColor.cTitle,
                      ),
                    ),
                    Text(
                      'Trò chuyện với đồng nghiệp',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColor.cMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddFriendScreen()),
                  ).then((_) {
                    ref.read(chatViewModelProvider.notifier).loadUsers();
                  });
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColor.cMain,
                  size: 24,
                ),
                tooltip: 'Thêm bạn',
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BlockedUsersScreen(),
                    ),
                  ).then((_) {
                    ref.read(chatViewModelProvider.notifier).loadUsers();
                  });
                },
                icon: Icon(Icons.block, color: AppColor.cError, size: 24),
                tooltip: 'Danh sách chặn',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              ref.read(chatViewModelProvider.notifier).search(value);
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm cuộc trò chuyện...',
              hintStyle: TextStyle(color: AppColor.cMuted),
              prefixIcon: Icon(Icons.search, color: AppColor.cMuted),
              filled: true,
              fillColor: AppColor.cGray_50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.cMain, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
