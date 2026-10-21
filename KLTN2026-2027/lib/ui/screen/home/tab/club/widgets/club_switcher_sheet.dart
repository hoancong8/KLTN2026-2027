// lib/ui/screen/home/tab/club/widgets/club_switcher_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../domain/entities/club/my_club.dart';
import 'club_create_dialog.dart';
import 'club_join_by_code_dialog.dart';

class ClubSwitcherSheet extends ConsumerWidget {
  final List<MyClub> clubs;
  final String? selectedClubId;
  final String? activeClubId;
  final ValueChanged<String> onClubSelected;

  const ClubSwitcherSheet({
    super.key,
    required this.clubs,
    required this.selectedClubId,
    required this.activeClubId,
    required this.onClubSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<MyClub> clubs,
    required String? selectedClubId,
    required String? activeClubId,
    required ValueChanged<String> onClubSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClubSwitcherSheet(
        clubs: clubs,
        selectedClubId: selectedClubId,
        activeClubId: activeClubId,
        onClubSelected: onClubSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.bottomSheet,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.borderXs,
                ),
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Danh Sách Câu Lạc Bộ Của Bạn',
              style: AppTypography.titleLarge.bold.colored(AppColors.textPrimary),
            ),
            AppSpacing.gapH4,
            Text(
              'Chọn nhóm để làm việc và đồng bộ vai trò tương ứng',
              style: AppTypography.bodySmall.colored(AppColors.textMuted),
            ),
            AppSpacing.gapH16,
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: clubs.length,
                separatorBuilder: (_, _) => AppSpacing.gapH8,
                itemBuilder: (ctx, i) {
                  final club = clubs[i];
                  final isSelected = club.clubId == selectedClubId;
                  final isActive = club.clubId == activeClubId;

                  return Material(
                    color: isSelected ? AppColors.primaryContainer : AppColors.background,
                    borderRadius: AppRadius.borderMd,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onClubSelected(club.clubId);
                      },
                      borderRadius: AppRadius.borderMd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: AppRadius.borderMd,
                                image: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(club.avatarUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: club.avatarUrl == null || club.avatarUrl!.isEmpty
                                  ? const Center(
                                      child: Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 22),
                                    )
                                  : null,
                            ),
                            AppSpacing.gapW12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    club.clubName,
                                    style: AppTypography.titleSmall.colored(
                                      isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600),
                                  ),
                                  AppSpacing.gapH4,
                                  Row(
                                    children: [
                                      Text(
                                        club.role.displayName,
                                        style: AppTypography.labelSmall.colored(AppColors.textMuted),
                                      ),
                                      if (isActive) ...[
                                        AppSpacing.gapW8,
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: const BoxDecoration(
                                            color: AppColors.successContainer,
                                            borderRadius: AppRadius.borderXs,
                                          ),
                                          child: Text(
                                            'Kích hoạt',
                                            style: AppTypography.labelSmall.bold.colored(AppColors.onSuccess),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AppSpacing.gapH16,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: AppSpacing.verticalMd,
                      side: const BorderSide(color: AppColors.primary),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.tag_rounded, color: AppColors.primary, size: AppSpacing.iconSm),
                    label: Text('Nhập mã Code', style: AppTypography.labelLarge.bold.colored(AppColors.primary)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ClubJoinByCodeDialog.show(context);
                    },
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      padding: AppSpacing.verticalMd,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.add_rounded, size: AppSpacing.iconSm),
                    label: Text('Tạo CLB mới', style: AppTypography.labelLarge.bold.colored(AppColors.onPrimary)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final newClubId = await ClubCreateDialog.show(context);
                      if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
                        context.push('/club/$newClubId');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
