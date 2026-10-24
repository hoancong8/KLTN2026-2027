// lib/ui/screen/home/tab/club/widgets/club_join_requests_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../../domain/entities/club/join_request.dart';
import '../../../../club/club_management_vm/club_join_requests_vm.dart';

class ClubJoinRequestsTab extends ConsumerWidget {
  final String clubId;

  const ClubJoinRequestsTab({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(clubJoinRequestsViewModelProvider(clubId));
    final vm = ref.read(clubJoinRequestsViewModelProvider(clubId).notifier);

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    if (state.requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: vm.loadRequests,
        color: colors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.allXl,
          children: [
            AppSpacing.gapH64,
            Center(
              child: Container(
                padding: AppSpacing.allLg,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.how_to_reg_rounded, size: 48, color: colors.primary),
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Không có đơn gia nhập chờ duyệt',
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            Text(
              'Khi người chơi gửi yêu cầu tham gia nhóm, đơn sẽ xuất hiện tại đây để ban điều hành xét duyệt.',
              style: AppTypography.bodySmall.colored(colors.textMuted),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH24,
            Center(
              child: OutlinedButton.icon(
                onPressed: vm.loadRequests,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Làm mới danh sách'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadRequests,
      color: colors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.allBase,
        children: [
          // Header summary banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.35),
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions_rounded, color: colors.primary, size: 20),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    'Đang có ${state.requests.length} người chơi chờ xét duyệt vào CLB',
                    style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 20, color: colors.primary),
                  tooltip: 'Tải lại',
                  onPressed: vm.loadRequests,
                ),
              ],
            ),
          ),
          AppSpacing.gapH12,

          // Request cards
          ...state.requests.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _JoinRequestCard(
                request: req,
                isProcessing: state.isProcessing,
                onApprove: () => _confirmApprove(context, vm, req),
                onReject: () => _confirmReject(context, vm, req),
              ),
            ),
          ),
          AppSpacing.gapH32,
        ],
      ),
    );
  }

  void _confirmApprove(BuildContext context, ClubJoinRequestsViewModel vm, JoinRequest req) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: colors.success, size: 24),
            AppSpacing.gapW8,
            Text('Phê Duyệt Gia Nhập', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đồng ý kết nạp "${req.fullName}" vào câu lạc bộ với vai trò Hội viên chính thức?',
              style: AppTypography.bodyMedium.colored(colors.textSecondary),
            ),
            if (req.introduction != null && req.introduction!.isNotEmpty) ...[
              AppSpacing.gapH8,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Text(
                  '“${req.introduction}”',
                  style: AppTypography.labelSmall.colored(colors.textMuted).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Đóng', style: AppTypography.labelLarge.colored(colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              vm.approve(req.id);
            },
            child: Text('Duyệt Vào Nhóm', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, ClubJoinRequestsViewModel vm, JoinRequest req) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            Icon(Icons.highlight_off_rounded, color: colors.error, size: 24),
            AppSpacing.gapW8,
            Text('Từ Chối Đơn Gia Nhập', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn từ chối yêu cầu gia nhập của "${req.fullName}"?',
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
            onPressed: () {
              Navigator.of(ctx).pop();
              vm.reject(req.id);
            },
            child: Text('Xác Nhận Từ Chối', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  final JoinRequest request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _JoinRequestCard({
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateStr = DateFormat('HH:mm - dd/MM/yyyy').format(request.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      padding: AppSpacing.allBase,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Avatar + Name + Contact Info + Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                  image: (request.avatarUrl != null && request.avatarUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(request.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (request.avatarUrl == null || request.avatarUrl!.isEmpty)
                    ? Center(
                        child: Text(
                          request.fullName.isNotEmpty ? request.fullName[0].toUpperCase() : '?',
                          style: AppTypography.titleMedium.bold.colored(colors.primary),
                        ),
                      )
                    : null,
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.fullName,
                      style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                    ),
                    AppSpacing.gapH4,
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (request.phoneNumber != null && request.phoneNumber!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined, size: 13, color: colors.textMuted),
                              AppSpacing.gapW4,
                              Text(request.phoneNumber!, style: AppTypography.labelSmall.colored(colors.textMuted)),
                            ],
                          ),
                        if (request.email != null && request.email!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.email_outlined, size: 13, color: colors.textMuted),
                              AppSpacing.gapW4,
                              Text(request.email!, style: AppTypography.labelSmall.colored(colors.textMuted)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: AppRadius.tag,
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Text(
                  dateStr,
                  style: AppTypography.labelSmall.colored(colors.textMuted),
                ),
              ),
            ],
          ),

          // 2. Introduction / Message from Applicant
          if (request.introduction != null && request.introduction!.isNotEmpty) ...[
            AppSpacing.gapH12,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDark ? colors.surfaceSubtle : colors.background,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, size: 18, color: colors.primary),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      request.introduction!,
                      style: AppTypography.bodySmall.colored(colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppSpacing.gapH12,
          Divider(height: 1, color: colors.cardBorder),
          AppSpacing.gapH12,

          // 3. Actions: Reject & Approve buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isProcessing ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text('Từ chối', style: AppTypography.labelMedium.bold.colored(colors.error)),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text('Duyệt vào CLB', style: AppTypography.labelMedium.bold.colored(AppColors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
