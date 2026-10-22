// lib/ui/screen/home/tab/club/widgets/club_qr_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../app/theme/theme.dart';

class ClubQrDialog extends StatelessWidget {
  final String clubName;
  final String clubCode;
  final String? avatarUrl;

  const ClubQrDialog({
    super.key,
    required this.clubName,
    required this.clubCode,
    this.avatarUrl,
  });

  static Future<void> show({
    required BuildContext context,
    required String clubName,
    required String clubCode,
    String? avatarUrl,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ClubQrDialog(
        clubName: clubName,
        clubCode: clubCode,
        avatarUrl: avatarUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      contentPadding: AppSpacing.allLg,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã Tham Gia Nhóm',
                style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.textMuted, size: AppSpacing.iconSm),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          AppSpacing.gapH16,
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderSm,
                  image: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 22)
                    : null,
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Text(
                  clubName,
                  style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          // ponytail: Visual QR frame with code pattern. Upgrade path: add qr_flutter if scanner camera requires raw matrix rendering.
          Container(
            width: 170,
            height: 170,
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: colors.cardBorder, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 96, color: AppColors.neutral900),
                AppSpacing.gapH4,
                Text(
                  clubCode,
                  style: AppTypography.labelLarge.bold.colored(AppColors.neutral900).copyWith(letterSpacing: 2),
                ),
              ],
            ),
          ),
          AppSpacing.gapH16,
          Text(
            'Nhập mã hoặc quét để bạn bè tham gia nhanh vào câu lạc bộ.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
          AppSpacing.gapH16,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                padding: AppSpacing.verticalMd,
              ),
              icon: const Icon(Icons.copy_rounded, size: AppSpacing.iconXs),
              label: Text(
                'Sao chép mã ($clubCode)',
                style: AppTypography.labelLarge.bold.colored(AppColors.white),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: clubCode));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã sao chép mã nhóm: $clubCode'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
