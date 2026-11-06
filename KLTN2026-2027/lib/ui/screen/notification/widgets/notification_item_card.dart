import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/app_notification.dart';

class NotificationItemCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'PAYMENT':
        return Icons.payments_rounded;
      case 'MATCH':
      case 'ROTATION':
        return Icons.sports_tennis_rounded;
      case 'QUEUE':
        return Icons.people_alt_rounded;
      case 'SESSION':
        return Icons.calendar_month_rounded;
      case 'GUEST_RECRUIT':
        return Icons.explore_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(BuildContext context, String type) {
    final colors = context.colors;
    switch (type.toUpperCase()) {
      case 'PAYMENT':
        return colors.warning;
      case 'MATCH':
      case 'ROTATION':
        return colors.primary;
      case 'QUEUE':
        return colors.secondary;
      case 'GUEST_RECRUIT':
        return colors.success;
      default:
        return colors.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !notification.isRead;
    final iconColor = _getIconColor(context, notification.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isUnread
              ? colors.primaryContainer.withValues(alpha: context.isDark ? 0.2 : 0.4)
              : colors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isUnread ? colors.primary.withValues(alpha: 0.3) : colors.cardBorder,
            width: isUnread ? 1.2 : 1.0,
          ),
          boxShadow: isUnread && !context.isDark ? AppShadows.sm : AppShadows.none,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconForType(notification.type), color: iconColor, size: 20),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        AppSpacing.gapW8,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.gapH4,
                  Text(
                    notification.content,
                    style: AppTypography.bodySmall.copyWith(
                      color: isUnread ? colors.textPrimary : colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
