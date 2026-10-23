// lib/ui/screen/home/tab/explore/explore_recruitments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../../domain/enums/session_enums.dart';
import '../../../club/session_vm/explore_recruitments_vm.dart';

class ExploreRecruitmentsPage extends ConsumerWidget {
  final bool isEmbedded;

  const ExploreRecruitmentsPage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(exploreRecruitmentsViewModelProvider);
    final vm = ref.read(exploreRecruitmentsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: isEmbedded
          ? null
          : AppBar(
        title: const Row(
          children: [
            Icon(Icons.radar_rounded, color: AppColors.roleViolet, size: 24),
            SizedBox(width: 8),
            Text('Tìm Kèo Giao Lưu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.explore,
            tooltip: 'Quét lại',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Card: Radius Slider & Skill Chips
          Container(
            color: colors.cardBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Bán kính tìm kiếm:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.roleViolet.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.isLocating ? Icons.sync_rounded : Icons.my_location_rounded,
                                size: 11,
                                color: AppColors.roleViolet,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                state.isLocating ? 'Đang định vị...' : 'GPS Vị trí thật',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.roleViolet,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${state.radiusKm.toStringAsFixed(0)} km quanh đây',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.roleViolet, fontSize: 13),
                    ),
                  ],
                ),
                Slider(
                  value: state.radiusKm,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  activeColor: AppColors.roleViolet,
                  onChanged: (val) => vm.setRadius(val),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tất cả trình độ'),
                        selected: state.selectedSkillLevel == null,
                        selectedColor: AppColors.roleViolet.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.roleViolet,
                        onSelected: (_) => vm.setSkillLevel(null),
                      ),
                      const SizedBox(width: 6),
                      ...SkillLevel.values.map((s) {
                        final isSelected = state.selectedSkillLevel == s.code;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(s.displayName),
                            selected: isSelected,
                            selectedColor: AppColors.roleViolet.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.roleViolet,
                            onSelected: (_) => vm.setSkillLevel(isSelected ? null : s.code),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Matches List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.roleViolet))
                : RefreshIndicator(
                    onRefresh: vm.explore,
                    color: AppColors.roleViolet,
                    child: state.errorMessage != null && state.recruitments.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.warning),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: vm.explore,
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Thử lại'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.roleViolet,
                                      foregroundColor: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : state.recruitments.isEmpty
                            ? _buildEmptyState(context, vm)
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: state.recruitments.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (ctx, index) {
                                  final match = state.recruitments[index];
                                  return _RecruitmentCard(
                                    match: match,
                                    isJoining: state.isJoining,
                                    onJoin: () => _confirmJoin(context, vm, match),
                                  );
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmJoin(BuildContext context, ExploreRecruitmentsViewModel vm, GuestRecruitment match) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sports_tennis_rounded, color: AppColors.roleViolet),
            SizedBox(width: 8),
            Text('Nhận Suất Giao Lưu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đang nhận suất chơi tại CLB: ${match.clubName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Sân: ${match.courtLocation}'),
            Text('Giờ: ${DateFormat('HH:mm').format(match.startTime)} - ${DateFormat('HH:mm, dd/MM').format(match.endTime)}'),
            Text('Tiền sân: ${NumberFormat('#,###').format(match.sharedCost)} đ / người'),
            const SizedBox(height: 12),
            Text(
              'Lưu ý: Sau khi nhận suất, hãy đến sân đúng giờ để giao lưu cùng các thành viên!',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roleViolet,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await vm.joinRecruitment(match.id);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã nhận suất giao lưu thành công! Hãy đến sân đúng giờ nhé.'),
                    backgroundColor: AppColors.roleViolet,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.push(AppConfig.sessionDetailRoutePath(match.sessionId));
              }
            },
            child: const Text('Xác nhận nhận suất'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ExploreRecruitmentsViewModel vm) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.roleViolet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.radar_outlined, size: 54, color: AppColors.roleViolet),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa Tìm Thấy Kèo Giao Lưu Nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Hiện không có buổi chơi nào đang tuyển khách trong bán kính này. Hãy thử tăng bán kính quét hoặc quay lại sau.',
              style: TextStyle(fontSize: 13, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => vm.setRadius(20.0),
              icon: const Icon(Icons.zoom_out_map, size: 18),
              label: const Text('Mở rộng bán kính 20km'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecruitmentCard extends StatelessWidget {
  final GuestRecruitment match;
  final bool isJoining;
  final VoidCallback onJoin;

  const _RecruitmentCard({
    required this.match,
    required this.isJoining,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final timeStr = '${DateFormat('HH:mm').format(match.startTime)} - ${DateFormat('HH:mm, dd/MM/yyyy').format(match.endTime)}';
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.clubName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Còn ${match.slotsRemaining} suất',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.roleTreasurer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Venue location
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: colors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.courtLocation,
                    style: TextStyle(fontSize: 13, color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (match.distanceKm != null)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.roleViolet.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me_rounded, size: 11, color: AppColors.roleViolet),
                        const SizedBox(width: 3),
                        Text(
                          'Cách ${match.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.roleViolet,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Time
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: colors.textMuted),
                const SizedBox(width: 4),
                Text(timeStr, style: TextStyle(fontSize: 13, color: colors.textPrimary)),
              ],
            ),
            const Divider(height: 20),

            // Footer: Cost, Skill & Join Button
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${NumberFormat('#,###').format(match.sharedCost)} đ',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text(
                      'Yêu cầu: ${match.minSkillLevel.displayName}',
                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isJoining ? null : onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roleViolet,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Nhận Suất Ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
