import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import '../../../../../../domain/entities/chat_friend.dart';
import 'chat_avatar.dart';

class ChatListItem extends StatelessWidget {
  final ChatFriend user;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = user.unreadMessageCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColor.cDivider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              ChatAvatar(
                name: user.userName,
                radius: 24,
                isOnline: user.isOnline,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName,
                      style: TextStyle(
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 15,
                        color: AppColor.cTitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: user.isOnline ? AppColor.cMain : AppColor.cMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.isOnline ? 'Đang hoạt động' : 'Ngoại tuyến',
                          style: TextStyle(
                            fontSize: 13,
                            color: user.isOnline ? AppColor.cMain : AppColor.cMuted,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasUnread) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.cMain,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.unreadMessageCount > 99 ? '99+' : '${user.unreadMessageCount}',
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.chevron_right,
                  color: AppColor.cMuted,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
