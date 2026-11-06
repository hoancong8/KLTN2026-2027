// lib/ui/screen/home/tab/club/widgets/my_clubs_mobile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../club/club_vm/club_context_state.dart';
import '../../../../notification/notification_vm/notification_vm.dart';
import 'club_action_sheet.dart';
import 'club_detail_view.dart';
import 'club_empty_state.dart';
import 'club_switcher_sheet.dart';

class MyClubsMobile extends StatelessWidget {
  final ClubContextState state;
  final String? selectedClubId;
  final ValueChanged<String> onSwitchClub;

  const MyClubsMobile({
    super.key,
    required this.state,
    required this.selectedClubId,
    required this.onSwitchClub,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clubs = state.myClubs;
    final activeId = state.activeContext?.clubId;
    final selectedClub = clubs.where((c) => c.clubId == selectedClubId).firstOrNull ??
        (clubs.isNotEmpty ? clubs.first : null);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: clubs.isEmpty
            ? Text(
                'Câu Lạc Bộ Của Tôi',
                style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
              )
            : InkWell(
                onTap: () => ClubSwitcherSheet.show(
                  context: context,
                  clubs: clubs,
                  selectedClubId: selectedClubId,
                  activeClubId: activeId,
                  onClubSelected: onSwitchClub,
                ),
                borderRadius: AppRadius.borderSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          selectedClub?.clubName ?? 'Câu Lạc Bộ',
                          style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.gapW4,
                      Icon(Icons.expand_more_rounded, color: colors.textMuted, size: AppSpacing.iconSm),
                    ],
                  ),
                ),
              ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(notificationViewModelProvider.select((s) => s.unreadCount));
              return IconButton(
                tooltip: 'Thông báo',
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications_outlined, color: colors.textPrimary, size: 24),
                    if (unreadCount > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => context.push(AppConfig.notificationsPath),
              );
            },
          ),
          IconButton(
            tooltip: 'Thêm / Tham gia nhóm',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: colors.primary, size: 22),
            ),
            onPressed: () => ClubActionSheet.show(context),
          ),
          AppSpacing.gapW8,
        ],
      ),
      body: state.isLoading && clubs.isEmpty
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : selectedClub != null
              ? ClubDetailView(
                  key: ValueKey(selectedClub.clubId),
                  club: selectedClub,
                  isActiveContext: selectedClub.clubId == activeId,
                )
              : const ClubEmptyState(),
    );
  }
}
