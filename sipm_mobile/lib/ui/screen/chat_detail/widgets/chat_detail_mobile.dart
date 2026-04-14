import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/utils/exception_ext.dart';
import '../../../../app/consts/app_color.dart';
import '../../home/tab/chat/widgets/message_bubble.dart';
import '../../home/tab/chat/widgets/message_input.dart';
import '../chat_detail_vm/chat_detail_vm.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_detail_shared.dart';
import '../../../../app/provider/localization_provider.dart';

class ChatDetailMobile extends ConsumerStatefulWidget {
  final int userId;
  final String userName;
  final bool isOnline;
  final bool isBlocked;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final bool showScrollToBottom;
  final VoidCallback onSendMessage;
  final VoidCallback onScrollToBottom;
  final ChatDetailParams params;

  const ChatDetailMobile({
    super.key,
    required this.userId,
    required this.userName,
    required this.isOnline,
    required this.isBlocked,
    required this.messageController,
    required this.scrollController,
    required this.showScrollToBottom,
    required this.onSendMessage,
    required this.onScrollToBottom,
    required this.params,
  });

  @override
  ConsumerState<ChatDetailMobile> createState() => _ChatDetailMobileState();
}

class _ChatDetailMobileState extends ConsumerState<ChatDetailMobile> {
  Future<void> _handleMenuSelection(String value) async {
    if (value == 'block') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final l10n = context.l10n;
          return AlertDialog(
            title: Text('${l10n.chat_block_user}?'),
            content: Text('${l10n.chat_block_user}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(context.l10n.com_cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColor.cError),
                child: Text(context.l10n.chat_block_user),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        ref
            .read(chatDetailViewModelProvider(widget.params).notifier)
            .blockUser();
      }
    } else if (value == 'unblock') {
      ref
          .read(chatDetailViewModelProvider(widget.params).notifier)
          .unblockUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatDetailViewModelProvider(widget.params));
    ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: AppColor.cGray_50,
      appBar: ChatDetailAppBar(
        userId: widget.userId,
        userName: widget.userName,
        isOnline: widget.isOnline,
        isBlocked: widget.isBlocked,
        onBackPressed: () => context.pop(),
        onMenuSelected: _handleMenuSelection,
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
                      child: state.error != null
                          ? buildErrorState(
                              context,
                              state.error!.getDisplayMessage(context.l10n),
                              () {
                                ref
                                    .read(
                                      chatDetailViewModelProvider(
                                        widget.params,
                                      ).notifier,
                                    )
                                    .loadMessages();
                              },
                            )
                          : state.displayedMessages.isEmpty
                          ? buildEmptyState(context, widget.userName)
                          : ListView.builder(
                              controller: widget.scrollController,
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
                                  key: ValueKey(message.id),
                                  message: message,
                                  senderName: widget.userName,
                                );
                              },
                            ),
                    ),
                    MessageInput(
                      controller: widget.messageController,
                      onSend: widget.onSendMessage,
                      isSending: state.isSending,
                      onAttachImage: () => ref
                          .read(
                            chatDetailViewModelProvider(widget.params).notifier,
                          )
                          .pickAndUploadImage(ImageSource.gallery),
                      onAttachFile: () => ref
                          .read(
                            chatDetailViewModelProvider(widget.params).notifier,
                          )
                          .pickAndUploadFile(),
                    ),
                  ],
                ),
                if (widget.showScrollToBottom)
                  buildScrollToBottomButton(widget.onScrollToBottom),
              ],
            ),
    );
  }
}
