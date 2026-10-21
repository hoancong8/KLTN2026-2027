// lib/ui/screen/home/tab/club/widgets/club_action_sheet.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/theme/theme.dart';
import 'club_create_dialog.dart';
import 'club_join_by_code_dialog.dart';

class ClubActionSheet extends StatelessWidget {
  const ClubActionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ClubActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.borderXs,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Tham Gia Hoặc Tạo Câu Lạc Bộ',
              style: AppTypography.titleLarge.bold.colored(AppColors.textPrimary),
            ),
            AppSpacing.gapH8,
            Text(
              'Kết nối cùng đồng đội và tham gia các buổi tập sôi động',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.colored(AppColors.textMuted),
            ),
            AppSpacing.gapH20,

            // 1. Create Club
            _buildActionTile(
              icon: Icons.add_business_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryContainer,
              title: 'Tạo câu lạc bộ mới',
              subtitle: 'Bạn sẽ là Chủ nhóm (Host) quản lý lịch chơi, thu quỹ và duyệt đơn',
              onTap: () async {
                Navigator.of(context).pop();
                final newClubId = await ClubCreateDialog.show(context);
                if (newClubId != null && newClubId.isNotEmpty && context.mounted) {
                  context.push('/club/$newClubId');
                }
              },
            ),
            AppSpacing.gapH12,

            // 2. Join with Code
            _buildActionTile(
              icon: Icons.tag_rounded,
              iconColor: AppColors.roleSky,
              iconBgColor: AppColors.secondaryContainer,
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
              icon: Icons.radar_rounded,
              iconColor: AppColors.roleViolet,
              iconBgColor: AppColors.violetLight,
              title: 'Quét tìm CLB quanh đây (Radar GPS)',
              subtitle: 'Tìm các câu lạc bộ cầu lông đang hoạt động trong khu vực của bạn',
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppConfig.exploreClubsScreenPath);
              },
            ),
            AppSpacing.gapH12,

            // 4. My Bookings
            _buildActionTile(
              icon: Icons.event_available_rounded,
              iconColor: AppColors.primaryDark,
              iconBgColor: AppColors.primaryContainer,
              title: 'Lịch chơi tôi đã đăng ký',
              subtitle: 'Xem toàn bộ vé tham gia, buổi tập và trạng thái điểm danh',
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppConfig.myBookingsRoutePath);
              },
            ),
            AppSpacing.gapH8,
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.background,
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
                      style: AppTypography.titleSmall.bold.colored(AppColors.textPrimary),
                    ),
                    AppSpacing.gapH4,
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.colored(AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: AppSpacing.iconSm),
            ],
          ),
        ),
      ),
    );
  }
}
