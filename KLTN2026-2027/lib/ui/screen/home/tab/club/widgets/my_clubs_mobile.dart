// lib/ui/screen/home/tab/club/widgets/my_clubs_mobile.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../domain/entities/club/my_club.dart';
import '../../../../club/club_vm/club_context_state.dart';
import 'club_action_sheet.dart';
import 'club_create_dialog.dart';
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
    final clubs = state.myClubs;
    final activeId = state.activeContext?.clubId;
    final selectedClub = clubs.where((c) => c.clubId == selectedClubId).firstOrNull ??
        (clubs.isNotEmpty ? clubs.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: clubs.isEmpty
            ? Text(
                'Câu Lạc Bộ Của Tôi',
                style: AppTypography.titleLarge.bold.colored(AppColors.textPrimary),
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
                          style: AppTypography.titleMedium.bold.colored(AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppSpacing.gapW4,
                      const Icon(Icons.expand_more_rounded, color: AppColors.textMuted, size: AppSpacing.iconSm),
                    ],
                  ),
                ),
              ),
        actions: [
          IconButton(
            tooltip: 'Lịch tôi đã đăng ký',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
            ),
            onPressed: () => context.push(AppConfig.myBookingsRoutePath),
          ),
          IconButton(
            tooltip: 'Thêm / Tham gia nhóm',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
            ),
            onPressed: () => ClubActionSheet.show(context),
          ),
          AppSpacing.gapW8,
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(clubs.length > 1 ? 64 : 1),
          child: Column(
            children: [
              if (clubs.length > 1) _buildHorizontalClubStrip(context, clubs, activeId),
              Container(height: 1, color: AppColors.border),
            ],
          ),
        ),
      ),
      body: state.isLoading && clubs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : selectedClub != null
              ? ClubDetailView(
                  key: ValueKey(selectedClub.clubId),
                  club: selectedClub,
                  isActiveContext: selectedClub.clubId == activeId,
                )
              : const ClubEmptyState(),
    );
  }

  Widget _buildHorizontalClubStrip(BuildContext context, List<MyClub> clubs, String? activeId) {
    return Container(
      height: 60,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 6),
        itemCount: clubs.length + 1,
        separatorBuilder: (_, _) => AppSpacing.gapW8,
        itemBuilder: (context, index) {
          if (index == clubs.length) {
            return InkWell(
              onTap: () async {
                final newClubId = await ClubCreateDialog.show(context);
                if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
                  context.push('/club/$newClubId');
                }
              },
              borderRadius: AppRadius.borderFull,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: AppSpacing.iconSm, color: AppColors.primary),
                    AppSpacing.gapW4,
                    Text(
                      'Tạo CLB mới',
                      style: AppTypography.labelSmall.bold.colored(AppColors.primary),
                    ),
                  ],
                ),
              ),
            );
          }

          final club = clubs[index];
          final isSelected = club.clubId == selectedClubId;
          final isActive = club.clubId == activeId;
          final initials = club.clubName.isNotEmpty
              ? club.clubName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : 'CLB';

          return GestureDetector(
            onTap: () => onSwitchClub(club.clubId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceSubtle,
                borderRadius: AppRadius.borderFull,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.neutral400,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: AppTypography.labelSmall.bold.colored(AppColors.white),
                      ),
                    ),
                  ),
                  AppSpacing.gapW8,
                  Text(
                    club.clubName,
                    style: AppTypography.bodySmall.colored(
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                    ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                  ),
                  if (isActive) ...[
                    AppSpacing.gapW4,
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
