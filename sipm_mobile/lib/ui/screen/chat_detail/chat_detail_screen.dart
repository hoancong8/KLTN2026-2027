import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/widget/responsive_layout.dart';

import 'chat_detail_vm/chat_detail_vm.dart';
import 'widgets/chat_detail_mobile.dart';
import 'widgets/chat_detail_tablet.dart';

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

    return ResponsiveLayout(
      mobile: ChatDetailMobile(
        userId: widget.userId,
        userName: widget.userName,
        isOnline: widget.isOnline,
        isBlocked: widget.isBlocked,
        messageController: _messageController,
        scrollController: _scrollController,
        showScrollToBottom: _showScrollToBottom,
        onSendMessage: _sendMessage,
        onScrollToBottom: _scrollToBottom,
        params: _params,
      ),
      tablet: ChatDetailTablet(
        userId: widget.userId,
        userName: widget.userName,
        isOnline: widget.isOnline,
        isBlocked: widget.isBlocked,
        messageController: _messageController,
        scrollController: _scrollController,
        showScrollToBottom: _showScrollToBottom,
        onSendMessage: _sendMessage,
        onScrollToBottom: _scrollToBottom,
        params: _params,
      ),
    );
  }
}
