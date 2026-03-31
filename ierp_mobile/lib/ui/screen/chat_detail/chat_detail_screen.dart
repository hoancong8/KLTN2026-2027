import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ierp_mobile/app/consts/app_colcor.dart';
import '../home/tab/chat/widgets/message_bubble.dart';
import '../home/tab/chat/widgets/message_input.dart';
import '../home/tab/chat/widgets/chat_avatar.dart';
import 'chat_detail_vm/chat_detail_vm.dart';
import 'package:image_picker/image_picker.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final int userId;
  final String userName;
  final bool isOnline;
  final bool isBlocked; // NEW

  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.isOnline,
    this.isBlocked = false, // Default false
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  ChatDetailParams get _params => ChatDetailParams(
    friendUserId: widget.userId,
    initialIsOnline: widget.isOnline,
    isBlocked: widget.isBlocked,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatDetailViewModelProvider(_params).notifier).loadMessages();
      ref.read(chatDetailViewModelProvider(_params).notifier).markAllAsRead();
    });
  }

  void _onScroll() {
    final isAtBottom = _scrollController.position.pixels <= 100;

    if (_showScrollToBottom != !isAtBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref
          .read(chatDetailViewModelProvider(_params).notifier)
          .loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    await ref
        .read(chatDetailViewModelProvider(_params).notifier)
        .sendMessage(message);

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatDetailViewModelProvider(_params));

    ref.listen(chatDetailViewModelProvider(_params), (previous, next) {
      if (previous?.isLoading == true &&
          next.isLoading == false &&
          next.displayedMessages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColor.cGray_50,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.cGray_50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColor.cTitle,
              size: 18,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            ChatAvatar(name: widget.userName, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cTitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.isOnline
                              ? AppColor.cMain
                              : AppColor.cMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.isOnline ? 'Đang hoạt động' : 'Ngoại tuyến',
                        style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'block') {
                // Show confirm dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Chặn người dùng?'),
                    content: Text(
                      'Bạn có chắc chắn muốn chặn ${widget.userName}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.cError,
                        ),
                        child: const Text('Chặn'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  ref
                      .read(chatDetailViewModelProvider(_params).notifier)
                      .blockUser();
                }
              } else if (value == 'unblock') {
                ref
                    .read(chatDetailViewModelProvider(_params).notifier)
                    .unblockUser();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                if (state.isBlocked)
                  const PopupMenuItem<String>(
                    value: 'unblock',
                    child: Text('Bỏ chặn'),
                  )
                else
                  const PopupMenuItem<String>(
                    value: 'block',
                    child: Text('Chặn người dùng'),
                  ),
              ];
            },
          ),
        ],
      ),
      body: state.isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
        ),
      )
          : Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: state.displayedMessages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount:
                  state.displayedMessages.length +
                      (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.displayedMessages.length &&
                        state.isLoadingMore) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                              AppColor.cMain,
                            ),
                          ),
                        ),
                      );
                    }

                    final reversedIndex =
                        state.displayedMessages.length - 1 - index;
                    final message =
                    state.displayedMessages[reversedIndex];

                    return MessageBubble(
                      key: ValueKey(
                        message.id,
                      ), // ← FIX: Prevent rebuild
                      message: message,
                      senderName: widget.userName,
                    );
                  },
                ),
              ),
              MessageInput(
                controller: _messageController,
                onSend: _sendMessage,
                isSending: state.isSending,
                onAttachImage: () => ref
                    .read(chatDetailViewModelProvider(_params).notifier)
                    .pickAndUploadImage(ImageSource.gallery),
                onAttachFile: () => ref
                    .read(chatDetailViewModelProvider(_params).notifier)
                    .pickAndUploadFile(),
              ),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Center(
                child: GestureDetector(
                  onTap: _scrollToBottom,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.cMain,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.cMain.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColor.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'Bắt đầu cuộc trò chuyện',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.cTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gửi tin nhắn đầu tiên cho ${widget.userName}',
            style: TextStyle(fontSize: 14, color: AppColor.cMuted),
          ),
        ],
      ),
    );
  }
}