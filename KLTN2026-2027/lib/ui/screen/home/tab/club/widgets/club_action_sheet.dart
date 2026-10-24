// lib/ui/screen/home/tab/club/widgets/club_action_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../app/theme/theme.dart';
import 'club_join_by_code_dialog.dart';

class ClubActionSheet extends ConsumerWidget {
  const ClubActionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => const ClubActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.bottomSheet,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.base),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.cardBorder,
                borderRadius: AppRadius.borderXs,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Tham Gia Hoặc Tạo Câu Lạc Bộ',
              style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
            ),
            AppSpacing.gapH8,
            Text(
              'Kết nối cùng đồng đội và tham gia các buổi tập sôi động',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.colored(colors.textMuted),
            ),
            AppSpacing.gapH20,

            // 1. Create Club
            _buildActionTile(
              context: context,
              icon: Icons.add_business_rounded,
              iconColor: AppColors.primary,
              iconBgColor: colors.primaryContainer,
              title: 'Tạo câu lạc bộ mới',
              subtitle: 'Bạn sẽ là Chủ nhóm (Host) quản lý lịch chơi, thu quỹ và duyệt đơn',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/club/create');
              },
            ),
            AppSpacing.gapH12,

            // 2. Join with Code
            _buildActionTile(
              context: context,
              icon: Icons.tag_rounded,
              iconColor: AppColors.roleSky,
              iconBgColor: colors.secondaryContainer,
              title: 'Tham gia bằng mã Code',
              subtitle: 'Nhập mã Code được Host chia sẻ để vào nhóm ngay',
              onTap: () {
                Navigator.of(context).pop();
                ClubJoinByCodeDialog.show(context);
              },
            ),
            AppSpacing.gapH12,

            // 3. Radar GPS Explore
            _buildActionTile(
              context: context,
              icon: Icons.radar_rounded,
              iconColor: AppColors.roleViolet,
              iconBgColor: colors.primaryContainer,
              title: 'Quét tìm CLB quanh đây (Radar GPS)',
              subtitle: 'Tìm các câu lạc bộ cầu lông đang hoạt động trong khu vực của bạn',
              onTap: () {
                Navigator.of(context).pop();
                ref.read(homeTabProvider.notifier).state = 2;
              },
            ),
            AppSpacing.gapH12,

            AppSpacing.gapH8,
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceSubtle,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.iconMd),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                    ),
                    AppSpacing.gapH4,
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.colored(colors.textMuted),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              Icon(Icons.arrow_forward_ios_rounded, color: colors.textMuted, size: AppSpacing.iconSm),
            ],
          ),
        ),
      ),
    );
  }
}
