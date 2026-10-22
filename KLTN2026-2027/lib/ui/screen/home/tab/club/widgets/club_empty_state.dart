// lib/ui/screen/home/tab/club/widgets/club_empty_state.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../app/theme/theme.dart';
import 'club_join_by_code_dialog.dart';

class ClubEmptyState extends StatelessWidget {
  const ClubEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero Visual Card
            Container(
              padding: AppSpacing.allXl,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.15),
                    colors.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_tennis_rounded,
                size: 64,
                color: colors.primary,
              ),
            ),
            AppSpacing.gapH24,
            Text(
              'Chưa tham gia Câu lạc bộ nào',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.bold.colored(colors.textPrimary),
            ),
            AppSpacing.gapH8,
            Padding(
              padding: AppSpacing.horizontalBase,
              child: Text(
                'Tham gia hoặc tạo câu lạc bộ để lên lịch thi đấu, bình chọn slot buổi tập, theo dõi hàng chờ và giao lưu cùng đồng đội.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.colored(colors.textMuted),
              ),
            ),
            AppSpacing.gapH32,

            // Card 1: Tạo CLB Mới (Primary Action)
            _buildActionCard(
              context,
              title: 'Tạo Câu Lạc Bộ Mới',
              description: 'Bạn là Chủ nhóm (Host) lên lịch buổi chơi, quản lý quỹ và duyệt thành viên',
              icon: Icons.add_business_rounded,
              accentColor: colors.primary,
              onTap: () => context.push('/club/create'),
            ),
            AppSpacing.gapH12,

            // Card 2: Nhập Mã Code
            _buildActionCard(
              context,
              title: 'Tham Gia Bằng Mã Code',
              description: 'Nhập mã Code được Host chia sẻ để gia nhập nhóm bạn bè ngay lập tức',
              icon: Icons.tag_rounded,
              accentColor: AppColors.roleSky,
              onTap: () => ClubJoinByCodeDialog.show(context),
            ),
            AppSpacing.gapH12,

            // Card 3: Khám Phá CLB Quanh Đây (FR06)
            _buildActionCard(
              context,
              title: 'Tìm CLB Quanh Đây (Radar GPS)',
              description: 'Quét bán kính xung quanh tìm các CLB cầu lông đang hoạt động và tuyển quân',
              icon: Icons.radar_rounded,
              accentColor: AppColors.roleViolet,
              onTap: () => context.push(AppConfig.exploreClubsScreenPath),
            ),
            AppSpacing.gapH12,

            // Card 4: Khám Phá Kèo Giao Lưu (FR12)
            _buildActionCard(
              context,
              title: 'Tìm Kèo Giao Lưu Gần Bạn',
              description: 'Quét radar tìm kiếm các buổi tập đang tuyển người vãng lai trong khu vực',
              icon: Icons.sports_tennis_rounded,
              accentColor: colors.warning,
              onTap: () => context.push(AppConfig.exploreRecruitmentsScreenPath),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Material(
        color: AppColors.transparent,
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
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(icon, color: accentColor, size: AppSpacing.iconMd),
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
                        description,
                        style: AppTypography.bodySmall.colored(colors.textMuted),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapW8,
                Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: AppSpacing.iconSm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
