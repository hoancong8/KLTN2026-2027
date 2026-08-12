import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/l10n_gen/app_localizations.dart';
import 'package:kltn2026_2027/app/utils/exception_ext.dart';
import '../../../../../../app/consts/app_color.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../chat_vm/chat_state.dart';
import '../chat_vm/chat_vm.dart';
import 'chat_list_item.dart';
import 'chat_page_shared.dart';

class ChatPageMobile extends ConsumerStatefulWidget {
  final ChatState state;
  final VoidCallback onRefresh;
  final Function(dynamic) onUserTap;
  final Function(String) onSearchChanged;
  final VoidCallback onAddFriendPressed;
  final VoidCallback onBlockedUsersPressed;

  const ChatPageMobile({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onUserTap,
    required this.onSearchChanged,
    required this.onAddFriendPressed,
    required this.onBlockedUsersPressed,
  });

  @override
  ConsumerState<ChatPageMobile> createState() => _ChatPageMobileState();
}

class _ChatPageMobileState extends ConsumerState<ChatPageMobile> {
  @override
  Widget build(BuildContext context) {
    ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        children: [
          // Header with search
          buildChatPageHeader(context: context, ref: ref),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.onRefresh(),
              child: widget.state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : widget.state.error != null
                  ? buildErrorState(
                      context,
                      widget.state.error!.getDisplayMessage(context.l10n),
                      widget.onRefresh,
                    )
                  : widget.state.users.isEmpty
                  ? buildEmptyState(
                      context,
                      false,
                    ) // Không thể check search được nữa
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.state.users.length,
                      itemBuilder: (context, index) {
                        final user = widget.state.users[index];
                        return ChatListItem(
                          user: user,
                          onTap: () => widget.onUserTap(user),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
