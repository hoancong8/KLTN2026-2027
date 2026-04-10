import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../../../../add_friend/add_friend_screen.dart';
import '../../../../blocked_users/blocked_user_screen.dart';
import '../chat_vm/chat_vm.dart';
PreferredSizeWidget buildChatPageAppBar({
  required BuildContext context,
  required VoidCallback onAddFriendPressed,
  required VoidCallback onBlockedUsersPressed,
}) {
  return AppBar(
    backgroundColor: AppColor.white,
    elevation: 0,
    title: Text(
      context.l10n.tinNhan,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColor.cTitle,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.person_add, color: AppColor.cMain),
        onPressed: onAddFriendPressed,
        tooltip: context.l10n.addfriend,
      ),
      IconButton(
        icon: Icon(Icons.block, color: AppColor.cMuted),
        onPressed: onBlockedUsersPressed,
        tooltip: 'Blocked Users',
      ),
    ],
  );
}

Widget buildChatPageHeader({
  required BuildContext context,
  required WidgetRef ref,
}) {
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
                    context.l10n.tinNhan,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColor.cTitle,
                    ),
                  ),
                  Text(
                    context.l10n.chatWithColleagues,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.cMuted,
                    ),
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
              tooltip: context.l10n.addfriend,
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
              tooltip: context.l10n.blockedusers,
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) {
            ref.read(chatViewModelProvider.notifier).search(value);
          },
          decoration: InputDecoration(
            hintText: context.l10n.searchconversation,
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

Widget buildEmptyState(BuildContext context, bool isSearching) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColor.cMain.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSearching ? Icons.search_off : Icons.chat_bubble_outline,
            color: AppColor.cMain,
            size: 64,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isSearching ? context.l10n.nouserfound : context.l10n.noconversationyet,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cTitle,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isSearching
              ? context.l10n.trysearchdiffkeyword
              : context.l10n.startfisrtconversation,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.cMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget buildErrorState(BuildContext context, String error, VoidCallback onRetry) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColor.cError.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            color: AppColor.cError,
            size: 64,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.anerroroccurred,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cTitle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: TextStyle(
            fontSize: 14,
            color: AppColor.cMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.tryagainbtn),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cMain,
            foregroundColor: AppColor.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}
