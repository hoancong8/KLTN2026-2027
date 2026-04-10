import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../chat_vm/chat_state.dart';
import 'chat_detail_tablet_panel.dart';
import 'chat_list_item.dart';
import 'chat_page_shared.dart';

class ChatPageTablet extends ConsumerStatefulWidget {
  final ChatState state;
  final dynamic selectedChat;
  final VoidCallback onRefresh;
  final Function(dynamic) onUserTap;
  final Function(String) onSearchChanged;
  final VoidCallback onAddFriendPressed;
  final VoidCallback onBlockedUsersPressed;
  final VoidCallback onCloseChat;

  const ChatPageTablet({
    super.key,
    required this.state,
    required this.selectedChat,
    required this.onRefresh,
    required this.onUserTap,
    required this.onSearchChanged,
    required this.onAddFriendPressed,
    required this.onBlockedUsersPressed,
    required this.onCloseChat,
  });

  @override
  ConsumerState<ChatPageTablet> createState() => _ChatPageTabletState();
}

class _ChatPageTabletState extends ConsumerState<ChatPageTablet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Row(
        children: [
          // Left Sidebar - Chat List
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                right: BorderSide(color: AppColor.cDivider, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header with actions and search
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    border: Border(
                      bottom: BorderSide(color: AppColor.cDivider, width: 1),
                    ),
                  ),
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
                                  context.l10n.tinNhan,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.cTitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.person_add, color: AppColor.cMain, size: 28),
                            onPressed: widget.onAddFriendPressed,
                            tooltip: context.l10n.addfriend,
                          ),
                          IconButton(
                            icon: Icon(Icons.block, color: AppColor.cMuted, size: 28),
                            onPressed: widget.onBlockedUsersPressed,
                            tooltip: 'Blocked Users',
                          ),
                        ],
                      ),
                      const SizedBox(height:5),
                      Row (
                        children: [
                          Text(
                            context.l10n.chatWithColleagues,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColor.cMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        onChanged: widget.onSearchChanged,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: context.l10n.search,
                          hintStyle: const TextStyle(fontSize: 16),
                          prefixIcon: const Icon(Icons.search, size: 24),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColor.cDivider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColor.cDivider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppColor.cMain),
                          ),
                          filled: true,
                          fillColor: AppColor.cGray_50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => widget.onRefresh(),
                    child: widget.state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : widget.state.error != null
                            ? buildErrorState(context, widget.state.error!, widget.onRefresh)
                            : widget.state.users.isEmpty
                                ? buildEmptyState(context, _searchController.text.isNotEmpty)
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: widget.state.users.length,
                                    itemBuilder: (context, index) {
                                      final user = widget.state.users[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: AppColor.cGray_50.withValues(alpha: 0.3),
                                        ),
                                        child: ChatListItem(
                                          user: user,
                                          onTap: () => widget.onUserTap(user),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ),
              ],
            ),
          ),

          // Right Content - Chat Detail or Placeholder
          Expanded(
            child: widget.selectedChat != null
                ? ChatDetailTabletPanel(
                    user: widget.selectedChat,
                    onClose: widget.onCloseChat,
                  )
                : Container(
                    color: AppColor.cGray_50,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.cMain.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: AppColor.cMain,
                              size: 80,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.l10n.selectaconversation,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColor.cTitle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.selectuserformlist,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.cMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
