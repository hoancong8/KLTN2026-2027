import 'package:flutter/material.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../notification_vm/notification_state.dart';
import '../notification_vm/notification_vm.dart';
import 'notification_item_card.dart';

class NotificationMobile extends StatelessWidget {
  final NotificationState state;
  final NotificationViewModel vm;

  const NotificationMobile({
    super.key,
    required this.state,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final notifications = state.filteredNotifications;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          l10n.notification_title,
          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () => vm.markAllAsRead(),
              icon: Icon(Icons.done_all_rounded, size: 18, color: colors.primary),
              label: Text(
                l10n.notification_mark_all_read,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.surface,
              onRefresh: () => vm.refresh(),
              child: state.isLoading && notifications.isEmpty
                  ? Center(child: CircularProgressIndicator(color: colors.primary))
                  : notifications.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                            vertical: AppSpacing.sm,
                          ),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            return NotificationItemCard(
                              notification: item,
                              onTap: () {
                                if (!item.isRead) {
                                  vm.markAsRead(item.id);
                                }
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    final filters = [
      {'key': 'ALL', 'label': l10n.notification_filter_all},
      {'key': 'UNREAD', 'label': '${l10n.notification_filter_unread} (${state.unreadCount})'},
      {'key': 'PAYMENT', 'label': l10n.notification_filter_payment},
      {'key': 'MATCH', 'label': l10n.notification_filter_match},
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 6),
      color: colors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => AppSpacing.gapW8,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = state.activeFilter == filter['key'];

          return ChoiceChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (_) => vm.setFilter(filter['key']!),
            selectedColor: colors.primaryContainer,
            backgroundColor: colors.surface,
            labelStyle: AppTypography.labelSmall.copyWith(
              color: isSelected ? colors.primary : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected ? colors.primary : colors.cardBorder,
              width: 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded, size: 48, color: colors.textSecondary),
            ),
            AppSpacing.gapH16,
            Text(
              l10n.notification_empty,
              style: AppTypography.titleMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              l10n.notification_empty_hint,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

