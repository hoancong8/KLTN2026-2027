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
                child: Icon(Icons.mark_email_read_outlined, size: 50, color: colors.primary),
              ),
            ),
            AppSpacing.gapH16,
            Text(
              'Không Có Yêu Cầu Chờ Duyệt',
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            Text(
              'Tất cả các đơn xin gia nhập câu lạc bộ đã được xử lý xong.',
              style: AppTypography.bodySmall.colored(colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadRequests,
      color: colors.primary,
      child: ListView.separated(
        padding: AppSpacing.allBase,
        itemCount: state.requests.length,
        separatorBuilder: (_, _) => AppSpacing.gapH12,
        itemBuilder: (ctx, index) {
          final req = state.requests[index];
          return _JoinRequestCard(
            request: req,
            onApprove: () => _confirmApprove(context, vm, req),
            onReject: () => _confirmReject(context, vm, req),
          );
        },
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
        title: Text('Phê Duyệt Thành Viên', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
        content: Text(
          'Bạn có chắc muốn duyệt thành viên "${req.fullName}" vào câu lạc bộ?',
          style: AppTypography.bodyMedium.colored(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: AppTypography.labelLarge.colored(colors.textMuted)),
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
            child: Text('Duyệt ngay', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
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
        title: Text('Từ Chối Yêu Cầu', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
        content: Text(
          'Bạn có chắc muốn từ chối đơn gia nhập của "${req.fullName}"?',
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
            child: Text('Từ chối', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  final JoinRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _JoinRequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: colors.cardBorder),
      ),
      child: Padding(
        padding: AppSpacing.allBase,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    request.fullName.isNotEmpty ? request.fullName[0].toUpperCase() : '?',
                    style: AppTypography.labelLarge.bold.colored(colors.primary),
                  ),
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
                      Text(
                        dateStr,
                        style: AppTypography.labelSmall.colored(colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.introduction != null && request.introduction!.isNotEmpty) ...[
              AppSpacing.gapH12,
              Container(
                width: double.infinity,
                padding: AppSpacing.allSm,
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Text(
                  '“${request.introduction}”',
                  style: AppTypography.bodySmall.colored(colors.textPrimary).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            AppSpacing.gapH12,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  ),
                  child: Text('Từ chối', style: AppTypography.labelMedium.colored(colors.error)),
                ),
                AppSpacing.gapW8,
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                  ),
                  child: Text('Duyệt vào CLB', style: AppTypography.labelMedium.bold.colored(AppColors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
