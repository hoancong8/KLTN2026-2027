import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/consts/app_color.dart';
import '../../home/tab/chat/widgets/chat_avatar.dart';
import '../../../../app/provider/localization_provider.dart';

class ChatDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int userId;
  final String userName;
  final bool isOnline;
  final bool isBlocked;
  final VoidCallback onBackPressed;
  final Function(String) onMenuSelected;

  const ChatDetailAppBar({
    super.key,
    required this.userId,
    required this.userName,
    required this.isOnline,
    required this.isBlocked,
    required this.onBackPressed,
    required this.onMenuSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    return AppBar(
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
        onPressed: onBackPressed,
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          ChatAvatar(name: userName, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
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
                        color: isOnline ? AppColor.cMain : AppColor.cMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? context.l10n.online : context.l10n.offline,
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
          onSelected: onMenuSelected,
          itemBuilder: (BuildContext context) {
            return [
              if (isBlocked)
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
    );
  }
}

Widget buildEmptyState(BuildContext context, String userName) {
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
          context.l10n.startchat,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.cTitle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.sendfirstmessage(userName),
          style: TextStyle(fontSize: 14, color: AppColor.cMuted),
        ),
      ],
    ),
  );
}

Widget buildScrollToBottomButton(VoidCallback onTap) {
  return Positioned(
    left: 0,
    right: 0,
    bottom: 80,
    child: Center(
      child: GestureDetector(
        onTap: onTap,
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
  );
}

Widget buildErrorState(BuildContext context, String error, VoidCallback onRetry) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
          context.l10n.cannotloadmessages,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColor.cTitle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.tryagain,
          style: TextStyle(fontSize: 14, color: AppColor.cMuted),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.cMain,
            foregroundColor: AppColor.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(context.l10n.tryagainbtn),
        ),
      ],
    ),
  );
}
