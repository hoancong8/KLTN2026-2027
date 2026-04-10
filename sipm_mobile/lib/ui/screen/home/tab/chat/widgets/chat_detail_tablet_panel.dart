import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import '../../../../../../app/provider/localization_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../chat_detail/chat_detail_vm/chat_detail_vm.dart';
import '../../../../chat_detail/widgets/chat_detail_shared.dart';
import 'chat_avatar.dart';
import 'message_bubble.dart';
import 'message_input.dart';

class ChatDetailTabletPanel extends ConsumerStatefulWidget {
  final dynamic user;
  final VoidCallback onClose;

  const ChatDetailTabletPanel({
    super.key,
    required this.user,
    required this.onClose,
  });

  @override
  ConsumerState<ChatDetailTabletPanel> createState() => _ChatDetailTabletPanelState();
}

class _ChatDetailTabletPanelState extends ConsumerState<ChatDetailTabletPanel> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  ChatDetailParams get _params => ChatDetailParams(
    friendUserId: widget.user.userId,
    initialIsOnline: widget.user.isOnline,
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

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'block') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title:  Text(context.l10n.blockuser),
          content: Text(
          context.l10n.blockUserConfirmation(widget.user.userName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child:  Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.cError,
              ),
              child:  Text(context.l10n.blockuser),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        ref.read(chatDetailViewModelProvider(_params).notifier).blockUser();
      }
    } else if (value == 'unblock') {
      ref.read(chatDetailViewModelProvider(_params).notifier).unblockUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatDetailViewModelProvider(_params));
    ref.watch(localizationProvider);

    ref.listen(chatDetailViewModelProvider(_params), (previous, next) {
      if (previous?.isLoading == true &&
          next.isLoading == false &&
          next.displayedMessages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Container(
      color: AppColor.cGray_50,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                bottom: BorderSide(color: AppColor.cDivider, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close chat',
                ),
                const SizedBox(width: 8),
                ChatAvatar(name: widget.user.userName, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cTitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                            state.isOnline ? context.l10n.online : context.l10n.offline,
                            style: const TextStyle(fontSize: 12, color: AppColor.cMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: _handleMenuSelection,
                  itemBuilder: (BuildContext context) {
                    return [
                      if (state.isBlocked)
                        PopupMenuItem<String>(
                          value: 'unblock',
                          child: Text(context.l10n.unblock),
                        )
                      else
                        PopupMenuItem<String>(
                          value: 'block',
                          child: Text(context.l10n.blockuser),
                        ),
                    ];
                  },
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : state.displayedMessages.isEmpty
                    ? buildEmptyState(context, widget.user.userName)
                    : Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: state.displayedMessages.length +
                                (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.displayedMessages.length &&
                                  state.isLoadingMore) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final reversedIndex =
                                  state.displayedMessages.length - 1 - index;
                              final message = state.displayedMessages[reversedIndex];

                              return MessageBubble(
                                key: ValueKey(message.id),
                                message: message,
                                senderName: widget.user.userName,
                              );
                            },
                          ),
                          if (_showScrollToBottom)
                            buildScrollToBottomButton(_scrollToBottom),
                        ],
                      ),
          ),
          // Message Input
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
    );
  }
}
