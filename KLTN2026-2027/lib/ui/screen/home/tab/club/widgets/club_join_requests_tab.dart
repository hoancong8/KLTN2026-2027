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
    final state = ref.watch(clubJoinRequestsViewModelProvider(clubId));
    final vm = ref.read(clubJoinRequestsViewModelProvider(clubId).notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColor.cMain));
    }

    if (state.requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: vm.loadRequests,
        color: AppColor.cMain,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.cMain.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 50, color: AppColor.cMain),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không Có Yêu Cầu Chờ Duyệt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.cTitle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Tất cả các đơn xin gia nhập câu lạc bộ đã được xử lý xong.',
              style: TextStyle(fontSize: 13, color: AppColor.cMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadRequests,
      color: AppColor.cMain,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Phê Duyệt Thành Viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text('Bạn có chắc muốn duyệt thành viên "${req.fullName}" vào câu lạc bộ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cMain,
              foregroundColor: AppColor.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              vm.approve(req.id);
            },
            child: const Text('Duyệt ngay'),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, ClubJoinRequestsViewModel vm, JoinRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Từ Chối Yêu Cầu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text('Bạn có chắc muốn từ chối đơn gia nhập của "${req.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.cRed,
              foregroundColor: AppColor.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              vm.reject(req.id);
            },
            child: const Text('Từ chối'),
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
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt);

    return Card(
      elevation: 0.8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColor.cMain.withValues(alpha: 0.15),
                  child: Text(
                    request.fullName.isNotEmpty ? request.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColor.cMain),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColor.cTitle),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12, color: AppColor.cMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.introduction != null && request.introduction!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '“${request.introduction}”',
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColor.cTitle),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.cRed,
                    side: const BorderSide(color: AppColor.cRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Từ chối', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cMain,
                    foregroundColor: AppColor.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Duyệt vào CLB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
