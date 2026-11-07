// lib/ui/screen/home/tab/club/widgets/club_qr_dialog.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../../app/theme/theme.dart';

class ClubQrDialog extends StatelessWidget {
  final String? clubId;
  final String clubName;
  final String clubCode;
  final String? avatarUrl;

  const ClubQrDialog({
    super.key,
    this.clubId,
    required this.clubName,
    required this.clubCode,
    this.avatarUrl,
  });

  static Future<void> show({
    required BuildContext context,
    String? clubId,
    required String clubName,
    required String clubCode,
    String? avatarUrl,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ClubQrDialog(
        clubId: clubId,
        clubName: clubName,
        clubCode: clubCode,
        avatarUrl: avatarUrl,
      ),
    );
  }

  String get _qrLink {
    if (clubId != null && clubId!.isNotEmpty) {
      final base = kIsWeb && Uri.base.host.isNotEmpty
          ? '${Uri.base.scheme}://${Uri.base.host}${Uri.base.hasPort && Uri.base.port != 80 && Uri.base.port != 443 ? ':${Uri.base.port}' : ''}'
          : 'https://sportclub.l7ungdz.id.vn';
      return '$base/#/club/$clubId';
    }
    return clubCode;
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
          // Real scannable QR Code rendering web link to club details
          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: colors.cardBorder, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: QrImageView(
                    data: _qrLink,
                    version: QrVersions.auto,
                    size: 160.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.neutral900,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.neutral900,
                    ),
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                AppSpacing.gapH8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.tag,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Text(
                    clubCode,
                    style: AppTypography.labelMedium.bold.colored(AppColors.neutral900).copyWith(letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH12,
          Text(
            'Quét mã để mở xem thông tin CLB trên web hoặc nhập mã để tham gia nhanh.',
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
              icon: const Icon(Icons.link_rounded, size: AppSpacing.iconXs),
              label: Text(
                'Sao chép liên kết web',
                style: AppTypography.labelLarge.bold.colored(AppColors.white),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _qrLink));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép liên kết câu lạc bộ vào bộ nhớ tạm'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          AppSpacing.gapH8,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.cardBorder),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                padding: AppSpacing.verticalMd,
              ),
              icon: const Icon(Icons.copy_rounded, size: AppSpacing.iconXs),
              label: Text(
                'Sao chép mã ($clubCode)',
                style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
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
