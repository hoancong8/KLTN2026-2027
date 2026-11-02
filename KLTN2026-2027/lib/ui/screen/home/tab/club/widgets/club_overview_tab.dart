// lib/ui/screen/home/tab/club/widgets/club_overview_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../app/provider.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../../../../../../app/l10n_gen/app_localizations.dart';
import '../../../../../../domain/enums/club_role.dart';
import '../../../../../../domain/entities/club/club_fee_rule.dart';
import '../../../../club/club_management_vm/club_members_vm.dart';
import '../../../../club/club_vm/club_context_vm.dart';
import '../../../../club_detail/club_detail_vm/club_detail_vm.dart';
import 'club_qr_dialog.dart';

class ClubOverviewTab extends ConsumerStatefulWidget {
  final String clubId;
  final String clubCode;
  final ClubRole userRole;

  const ClubOverviewTab({
    super.key,
    required this.clubId,
    required this.clubCode,
    required this.userRole,
  });

  @override
  ConsumerState<ClubOverviewTab> createState() => _ClubOverviewTabState();
}

class _ClubOverviewTabState extends ConsumerState<ClubOverviewTab> {

  AppThemeColors get colors => context.colors;
  AppLocalizations get l10n => context.l10n;

  void _copyToClipboard(String text, String message) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubDetailViewModelProvider(widget.clubId));
    final vm = ref.read(clubDetailViewModelProvider(widget.clubId).notifier);
    final activeContext = ref.watch(activeClubContextProvider);

    final club = state.club;
    final currentProfile = ref.watch(currentUserProfileProvider);

    // Dynamic RBAC with strict Context Isolation
    final isSameClub = activeContext?.clubId == widget.clubId;
    final isHostOwner = club != null && currentProfile != null && club.host.userId == currentProfile.id;
    final isHost = isHostOwner || (isSameClub && activeContext?.role == ClubRole.host) || widget.userRole == ClubRole.host;
    final canManageInfo = isHost || (isSameClub && ref.hasClubPermission('MEMBER.INFO.UPDATE'));
    final canManageRoles = isHost || (isSameClub && ref.hasClubPermission('MEMBER.ROLE.MANAGE'));
    final canManageClub = isHost || canManageInfo || canManageRoles;

    if (state.isLoading && state.club == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final code = widget.clubCode.isNotEmpty ? widget.clubCode : (club?.code ?? 'CHƯA CÓ');

    return RefreshIndicator(
      onRefresh: () => vm.loadDetail(),
      color: AppColors.primary,
      child: ListView(
        padding: AppSpacing.allBase,
        children: [
          // 1. Invite Friends Card (Discord Style)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: context.isDark ? colors.surfaceSubtle : colors.primaryContainer.withValues(alpha: 0.35),
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppSpacing.allSm,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: const Icon(Icons.group_add_rounded, color: AppColors.white, size: 20),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mời bạn bè vào nhóm',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                          ),
                          Text(
                            'Chia sẻ mã này để bạn bè tham gia ngay không cần duyệt',
                            style: AppTypography.bodySmall.colored(colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tag_rounded, color: AppColors.primary, size: 20),
                          AppSpacing.gapW8,
                          Text(
                            code,
                            style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                            ),
                            icon: const Icon(Icons.copy, size: AppSpacing.iconXs),
                            label: Text('Sao chép', style: AppTypography.labelMedium.colored(AppColors.onPrimary)),
                            onPressed: () => _copyToClipboard(code, 'Đã sao chép mã nhóm: $code'),
                          ),
                          AppSpacing.gapW8,
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.primary,
                              side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                            ),
                            icon: const Icon(Icons.qr_code_rounded, size: AppSpacing.iconXs),
                            label: Text('Mã QR', style: AppTypography.labelMedium.bold.colored(colors.primary)),
                            onPressed: () => ClubQrDialog.show(
                              context: context,
                              clubName: club?.groupName ?? 'Câu Lạc Bộ',
                              clubCode: code,
                              avatarUrl: club?.avatarUrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 2. Fixed Venue & Location Card (FR07)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stadium_rounded, color: AppColors.primary, size: 20),
                        AppSpacing.gapW8,
                        Text(
                          'Sân sinh hoạt cố định',
                          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                        ),
                      ],
                    ),
                    if (canManageInfo && club != null)
                      TextButton.icon(
                        onPressed: () => context.push('/club/${widget.clubId}/settings'),
                        icon: const Icon(Icons.edit_outlined, size: AppSpacing.iconXs),
                        label: Text('Chỉnh sửa', style: AppTypography.labelSmall.colored(AppColors.primary)),
                      ),
                  ],
                ),
                AppSpacing.gapH8,
                Text(
                  club?.fixedVenueName != null && club!.fixedVenueName!.isNotEmpty
                      ? club.fixedVenueName!
                      : 'Chưa thiết lập sân cố định',
                  style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                ),
                AppSpacing.gapH4,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: AppSpacing.iconXs, color: colors.textMuted),
                    AppSpacing.gapW4,
                    Expanded(
                      child: Text(
                        club?.fixedAddress != null && club!.fixedAddress!.isNotEmpty
                            ? club.fixedAddress!
                            : 'Chưa cập nhật địa chỉ sân',
                        style: AppTypography.bodySmall.colored(colors.textMuted),
                      ),
                    ),
                    if (club?.fixedAddress != null && club!.fixedAddress!.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.content_copy_rounded, size: 16, color: colors.primary),
                        tooltip: 'Sao chép địa chỉ',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => _copyToClipboard(club.fixedAddress!, 'Đã sao chép địa chỉ sân'),
                      ),
                  ],
                ),
                if (club?.lat != null && club?.lng != null) ...[
                  AppSpacing.gapH4,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed_rounded, size: 12, color: colors.primary),
                        AppSpacing.gapW4,
                        Text(
                          'Tọa độ GPS: ${club!.lat!.toStringAsFixed(4)}, ${club.lng!.toStringAsFixed(4)}',
                          style: AppTypography.labelSmall.colored(colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 3. Tiền sân & Đóng quỹ nhóm (Biểu phí sinh hoạt)
          _buildClubFeeCard(club, canManageClub, state.feeRule),

          AppSpacing.gapH16,

          // 4. Club Quality & Details Card (FR23)
          Container(
            padding: AppSpacing.allBase,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hồ sơ & Đánh giá câu lạc bộ',
                  style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                ),
                AppSpacing.gapH12,
                _buildInfoRow(
                  'Điểm chất lượng CLB',
                  club != null ? '${club.qualityScore.toStringAsFixed(1)} / 5.0' : '5.0 / 5.0',
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Số lượng thành viên',
                  club != null ? '${club.memberCount} thành viên' : 'Đang tải...',
                  icon: Icons.people_outline_rounded,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Trình độ tiếp nhận',
                  (club?.minSkillLevel != null && club?.maxSkillLevel != null)
                      ? '${club!.minSkillLevel!.code} -> ${club.maxSkillLevel!.code}'
                      : 'Mọi trình độ',
                  icon: Icons.speed_rounded,
                ),
                Divider(height: AppSpacing.base, color: colors.cardBorder),
                _buildInfoRow(
                  'Tuyển thành viên mới',
                  (club?.isRecruiting ?? false) ? 'Đang mở tuyển' : 'Tạm đóng',
                  icon: Icons.how_to_reg_rounded,
                  valueColor: (club?.isRecruiting ?? false) ? AppColors.success : colors.textMuted,
                ),
                if (club?.host != null) ...[
                  Divider(height: AppSpacing.base, color: colors.cardBorder),
                  _buildInfoRow(
                    'Chủ nhiệm (Host)',
                    club!.host.fullName,
                    icon: Icons.person_outline_rounded,
                  ),
                ],
                if (club?.description != null && club!.description!.isNotEmpty) ...[
                  Divider(height: AppSpacing.base, color: colors.cardBorder),
                  _buildInfoRow(
                    'Mô tả nhóm',
                    club.description!,
                    icon: Icons.notes_rounded,
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.gapH16,

          // 6. Host Quick Action Shortcuts: Cài đặt nhóm
          if (canManageClub) ...[
            Container(
              padding: AppSpacing.allBase,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cài đặt & Quản trị',
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                  ),
                  AppSpacing.gapH12,
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.settings_outlined, size: AppSpacing.iconSm),
                    label: Text(
                      'Cài đặt nhóm',
                      style: AppTypography.labelLarge.bold.colored(AppColors.white),
                    ),
                    onPressed: () {
                      context.push('/club/${widget.clubId}/settings');
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
          ],


          // 8. Leave Club Button (Only for non-Host members)
          if (!isHost) ...[
            AppSpacing.gapH16,
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                padding: AppSpacing.verticalMd,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              icon: const Icon(Icons.exit_to_app_rounded, size: AppSpacing.iconSm),
              label: Text(
                'Rời khỏi câu lạc bộ',
                style: AppTypography.labelLarge.bold.colored(colors.error),
              ),
              onPressed: () => _confirmLeaveClub(context),
            ),
          ],
          AppSpacing.gapH24,
        ],
      ),
    );
  }

  String _formatVnd(num value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Widget _buildClubFeeCard(dynamic club, bool canManageClub, [ClubFeeRule? feeRule]) {
    final isDynamic = feeRule?.isDynamic ?? true;
    final monthlyFee = feeRule?.monthlyFee ?? 500000;
    final monthlyDiscount = feeRule?.femaleDiscountMonthly ?? 50000;
    final dailyMemberFee = feeRule?.dailyMemberFee ?? 50000;
    final dailyDiscount = feeRule?.femaleDiscountDaily ?? 10000;
    final guestFee = feeRule?.guestFee ?? 70000;
    final guestDiscount = feeRule?.femaleDiscountGuest ?? 10000;
    final roundRule = feeRule?.roundRule ?? 1000;

    final monthlyFemale = (monthlyFee - monthlyDiscount).clamp(0, monthlyFee);
    final dailyFemale = (dailyMemberFee - dailyDiscount).clamp(0, dailyMemberFee);
    final guestFemale = (guestFee - guestDiscount).clamp(0, guestFee);

    final roundText = canManageClub ? ' (Làm tròn: ${_formatVnd(roundRule)}đ khi quét VietQR).' : '';
    final modeDesc = isDynamic
        ? 'Tổng tiền sân + Cầu bóc mới thực tế + Nước uống phát sinh, chia đều theo đầu người tham gia buổi chơi.$roundText'
        : 'Thu theo đơn giá buổi cố định đã thiết lập cho từng nhóm đối tượng.$roundText';

    return Container(
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(Icons.payments_outlined, color: colors.primary, size: 18),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiền sân & Đóng quỹ nhóm',
                      style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                    ),
                    Text(
                      'Cách tính tiền buổi chơi & quỹ tháng của CLB',
                      style: AppTypography.labelSmall.colored(colors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          // Banner cách tính tiền buổi chơi
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calculate_outlined, color: colors.primary, size: 18),
                AppSpacing.gapW8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cách chia tiền mỗi buổi chơi:',
                        style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                      ),
                      AppSpacing.gapH4,
                      Text(
                        modeDesc,
                        style: AppTypography.bodySmall.colored(colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH12,
          if (isDynamic) ...[
            _buildInfoRow(
              'Hình thức đóng tiền',
              'Chia đều toàn bộ chi phí thực tế cho tất cả tay vợt',
              icon: Icons.groups_rounded,
              iconColor: colors.primary,
            ),
            Divider(height: AppSpacing.base, color: colors.cardBorder),
            _buildInfoRow(
              'Ưu đãi dành cho Nữ',
              'Tự động giảm trừ ${_formatVnd(dailyDiscount)} đ/người vào phần chia mỗi buổi',
              icon: Icons.female_rounded,
              iconColor: AppColors.pink,
              valueColor: AppColors.pink,
            ),
          ] else ...[
            _buildInfoRow(
              'Hội viên cố định (tháng)',
              '${_formatVnd(monthlyFee)} đ/tháng (Nữ: ${_formatVnd(monthlyFemale)} đ)',
              icon: Icons.card_membership_rounded,
              iconColor: colors.primary,
            ),
            Divider(height: AppSpacing.base, color: colors.cardBorder),
            _buildInfoRow(
              'Hội viên đóng theo buổi',
              '${_formatVnd(dailyMemberFee)} đ/buổi (Nữ: ${_formatVnd(dailyFemale)} đ)',
              icon: Icons.person_outline_rounded,
              iconColor: colors.success,
            ),
            Divider(height: AppSpacing.base, color: colors.cardBorder),
            _buildInfoRow(
              'Khách vãng lai giao lưu',
              '${_formatVnd(guestFee)} đ/buổi (Nữ: ${_formatVnd(guestFemale)} đ)',
              icon: Icons.sports_tennis_rounded,
              iconColor: colors.warning,
            ),
            Divider(height: AppSpacing.base, color: colors.cardBorder),
            _buildInfoRow(
              'Ưu đãi cho Nữ (mọi đối tượng)',
              'Giảm ${_formatVnd(monthlyDiscount)} đ/tháng, ${_formatVnd(dailyDiscount)} đ/buổi cố định, ${_formatVnd(guestDiscount)} đ/buổi khách vãng lai',
              icon: Icons.favorite_outline_rounded,
              iconColor: colors.error,
              valueColor: colors.error,
            ),
          ],
        ],
      ),
    );
  }

  void _confirmLeaveClub(BuildContext context) {
    final currentProfile = ref.read(currentUserProfileProvider);
    if (currentProfile == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text('Xác nhận rời câu lạc bộ', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
        content: Text(
          'Bạn có chắc chắn muốn rời khỏi câu lạc bộ này? Bạn sẽ mất quyền truy cập vào các buổi tập và thông tin nội bộ của nhóm.',
          style: AppTypography.bodyMedium.colored(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ref.read(clubMembersViewModelProvider.notifier).removeMember(currentProfile.id);
              if (ok && context.mounted) {
                await ref.read(clubContextViewModelProvider.notifier).loadMyClubs();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã rời khỏi câu lạc bộ thành công.'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Rời nhóm', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: iconColor ?? colors.textMuted),
          AppSpacing.gapW8,
        ],
        SizedBox(
          width: 140,
          child: Text(label, style: AppTypography.bodySmall.colored(colors.textMuted)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.semiBold.colored(valueColor ?? colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
