// lib/ui/screen/home/tab/explore/explore_recruitments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import '../../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../../domain/enums/session_enums.dart';
import '../../../club/session_vm/explore_recruitments_state.dart';
import '../../../club/session_vm/explore_recruitments_vm.dart';

class ExploreRecruitmentsPage extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const ExploreRecruitmentsPage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<ExploreRecruitmentsPage> createState() => _ExploreRecruitmentsPageState();
}

class _ExploreRecruitmentsPageState extends ConsumerState<ExploreRecruitmentsPage> {
  final _searchController = TextEditingController();

  static const List<double> _quickRadii = [3.0, 5.0, 10.0, 20.0];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(exploreRecruitmentsViewModelProvider);
    final vm = ref.read(exploreRecruitmentsViewModelProvider.notifier);
    final filteredList = state.filteredRecruitments;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tìm Kèo Giao Lưu',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              backgroundColor: colors.surface,
              foregroundColor: colors.textPrimary,
              elevation: 0,
              surfaceTintColor: AppColors.transparent,
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
          // 1. Search Box & Filter Bar
          _buildFilterHeader(context, state, vm),

          // 2. Section Header with count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.near_me_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Kèo giao lưu quanh bạn',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${filteredList.length} kèo khả dụng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Matches List (Responsive: Mobile 1 column, Tablet 2 columns)
          Expanded(
            child: state.isLoading
                ? Center(child: CircularProgressIndicator(color: colors.primary))
                : RefreshIndicator(
                    onRefresh: vm.explore,
                    color: colors.primary,
                    child: state.errorMessage != null && state.recruitments.isEmpty
                        ? _buildErrorState(context, state.errorMessage!, vm)
                        : filteredList.isEmpty
                            ? _buildEmptyState(context, state, vm)
                            : ResponsiveLayout(
                                mobile: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                  itemCount: filteredList.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                                  itemBuilder: (ctx, index) {
                                    final match = filteredList[index];
                                    return _RecruitmentMatchCard(
                                      match: match,
                                      isJoining: state.isJoining,
                                      onJoin: () => _showJoinBottomSheet(context, vm, match),
                                    );
                                  },
                                ),
                                tablet: GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1.55,
                                  ),
                                  itemCount: filteredList.length,
                                  itemBuilder: (ctx, index) {
                                    final match = filteredList[index];
                                    return _RecruitmentMatchCard(
                                      match: match,
                                      isJoining: state.isJoining,
                                      onJoin: () => _showJoinBottomSheet(context, vm, match),
                                    );
                                  },
                                ),
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(
    BuildContext context,
    ExploreRecruitmentsState state,
    ExploreRecruitmentsViewModel vm,
  ) {
    final colors = context.colors;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên CLB, sân cầu, quận/huyện...',
              hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
              prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, size: 18, color: colors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        vm.setSearchTerm('');
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: colors.inputFill,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (val) {
              vm.setSearchTerm(val);
              setState(() {});
            },
          ),
          const SizedBox(height: 10),

          // 2. GPS Location & Quick Radius Pills
          Row(
            children: [
              // GPS indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isLocating ? Icons.sync_rounded : Icons.my_location_rounded,
                      size: 13,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.isLocating ? 'Đang định vị' : 'GPS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Radius Pills
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickRadii.map((r) {
                      final isSelected = (state.radiusKm - r).abs() < 0.1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => vm.setRadius(r),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.primary : colors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.cardBorder,
                              ),
                            ),
                            child: Text(
                              '${r.toStringAsFixed(0)} km',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.white : colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Skill Level Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSkillChip(
                  context,
                  label: 'Tất cả trình độ',
                  isSelected: state.selectedSkillLevel == null,
                  onTap: () => vm.setSkillLevel(null),
                ),
                ...SkillLevel.values.map((s) {
                  final isSelected = state.selectedSkillLevel == s.code;
                  return _buildSkillChip(
                    context,
                    label: s.displayName,
                    isSelected: isSelected,
                    onTap: () => vm.setSkillLevel(isSelected ? null : s.code),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryContainer : AppColors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.primary : colors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? colors.primary : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  void _showJoinBottomSheet(
    BuildContext context,
    ExploreRecruitmentsViewModel vm,
    GuestRecruitment match,
  ) {
    final colors = context.colors;
    final timeStr = '${DateFormat('HH:mm').format(match.startTime)} - ${DateFormat('HH:mm, dd/MM/yyyy').format(match.endTime)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xác Nhận Nhận Suất Giao Lưu',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Vui lòng kiểm tra kỹ thông tin trước khi xác nhận',
                          style: TextStyle(fontSize: 12, color: colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Match Details Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      icon: Icons.groups_rounded,
                      label: 'CLB tổ chức',
                      value: match.clubName,
                      valueColor: colors.textPrimary,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.location_on_rounded,
                      label: 'Địa điểm sân',
                      value: match.courtLocation,
                      valueColor: colors.textPrimary,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.access_time_filled_rounded,
                      label: 'Khung giờ',
                      value: timeStr,
                      valueColor: colors.textPrimary,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.military_tech_rounded,
                      label: 'Yêu cầu trình độ',
                      value: match.minSkillLevel.displayName,
                      valueColor: AppColors.roleViolet,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.payments_rounded,
                      label: 'Chi phí chia sẻ',
                      value: '${NumberFormat('#,###').format(match.sharedCost)} đ / người',
                      valueColor: colors.primary,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Fair Play Commitment Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cam kết văn hóa sân cầu: Hãy đến sân đúng giờ để giao lưu cùng mọi người. Nếu có việc bận đột xuất, vui lòng hủy suất sớm để nhường chỗ cho người khác.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Để sau', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Xác Nhận Tham Gia', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final ok = await vm.joinRecruitment(match.id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Nhận suất giao lưu thành công! Hãy đến sân đúng giờ nhé.'),
                              backgroundColor: colors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          context.push(AppConfig.sessionDetailRoutePath(match.sessionId));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textMuted),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12.5, color: colors.textMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ExploreRecruitmentsState state,
    ExploreRecruitmentsViewModel vm,
  ) {
    final colors = context.colors;
    final isSearching = state.searchTerm.trim().isNotEmpty;

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
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.radar_rounded,
                size: 52,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'Không Tìm Thấy Kèo Phù Hợp' : 'Chưa Tìm Thấy Kèo Giao Lưu Nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Không có bài tuyển khách nào khớp với từ khóa "${state.searchTerm}". Hãy thử từ khóa khác hoặc xóa lọc.'
                  : 'Hiện không có buổi chơi nào tuyển khách trong bán kính ${state.radiusKm.toStringAsFixed(0)} km. Hãy thử mở rộng bán kính quét.',
              style: TextStyle(fontSize: 13, color: colors.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            if (isSearching)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  vm.setSearchTerm('');
                  setState(() {});
                },
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text('Xóa bộ lọc tìm kiếm'),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => vm.setRadius(20.0),
                icon: const Icon(Icons.zoom_out_map_rounded, size: 18),
                label: const Text('Mở rộng bán kính 20km', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, ExploreRecruitmentsViewModel vm) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.explore,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecruitmentMatchCard extends StatelessWidget {
  final GuestRecruitment match;
  final bool isJoining;
  final VoidCallback onJoin;

  const _RecruitmentMatchCard({
    required this.match,
    required this.isJoining,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final timeStr = '${DateFormat('HH:mm').format(match.startTime)} - ${DateFormat('HH:mm').format(match.endTime)}, ${DateFormat('dd/MM/yyyy').format(match.startTime)}';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.cardBorder, width: 1),
      ),
      color: colors.cardBackground,
      child: InkWell(
        onTap: () => context.push(AppConfig.sessionDetailRoutePath(match.sessionId)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Club Avatar & Name + GPS Distance + Remaining Slots
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Club Initial Avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        match.clubName.isNotEmpty ? match.clubName[0].toUpperCase() : 'C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Club Name & Distance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.clubName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (match.distanceKm != null) ...[
                              Icon(Icons.near_me_rounded, size: 11, color: colors.primary),
                              const SizedBox(width: 3),
                              Text(
                                'Cách ${match.distanceKm!.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Đang tuyển',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Remaining Slots Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.roleTreasurer),
                        const SizedBox(width: 4),
                        Text(
                          'Còn ${match.slotsRemaining} slot',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.roleTreasurer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colors.cardBorder),
              const SizedBox(height: 10),

              // 2. Middle Details: Location, Time & Skill
              // Venue
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 15, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      match.courtLocation,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Time
              Row(
                children: [
                  Icon(Icons.access_time_filled_rounded, size: 15, color: colors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 12.5, color: colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Skill requirement
              Row(
                children: [
                  Icon(Icons.military_tech_rounded, size: 15, color: AppColors.roleViolet),
                  const SizedBox(width: 6),
                  Text(
                    'Trình độ: ',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.roleViolet.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.minSkillLevel.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.roleViolet,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colors.cardBorder),
              const SizedBox(height: 10),

              // 3. Footer: Price & CTA Actions
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi phí:',
                        style: TextStyle(fontSize: 10.5, color: colors.textMuted),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            NumberFormat('#,###').format(match.sharedCost),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          Text(
                            ' đ/người',
                            style: TextStyle(fontSize: 11, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: isJoining ? null : onJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.sports_tennis_rounded, size: 14),
                    label: const Text('Nhận Suất Giao Lưu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
