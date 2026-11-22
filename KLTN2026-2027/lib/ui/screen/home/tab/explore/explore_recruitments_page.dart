// lib/ui/screen/home/tab/explore/explore_recruitments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/app/utils/exception_ext.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import '../../../../../domain/entities/session/create_court_pass_params.dart';
import '../../../../../domain/entities/session/guest_recruitment.dart';
import '../../../../../domain/enums/session_enums.dart';
import '../../../club/widgets/map_location_picker_sheet.dart';
import '../../../club/club_vm/club_context_vm.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = ref.read(exploreRecruitmentsViewModelProvider);
        if (state.recruitments.isEmpty && !state.isLoading) {
          ref.read(exploreRecruitmentsViewModelProvider.notifier).explore();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ExploreRecruitmentsState>(exploreRecruitmentsViewModelProvider, (prev, next) {
      if (next.error != null && next.recruitments.isNotEmpty && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.getDisplayMessage(context.l10n)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.errorMessage != null && next.recruitments.isNotEmpty && prev?.errorMessage != next.errorMessage && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

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
                TextButton.icon(
                  onPressed: () => _showPassCourtModal(context),
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text('Pass sân', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                  ),
                ),
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

          // 2. Section Header with count and Pass Sân action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: colors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.near_me_rounded, size: 16, color: colors.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Kèo giao lưu quanh bạn',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
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
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showPassCourtModal(context),
                  icon: const Icon(Icons.flash_on_rounded, size: 14),
                  label: const Text('Pass Sân', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),

          // 3. Matches List (Responsive: Mobile 1 column, Tablet 2 columns)
          Expanded(
            child: Builder(
              builder: (ctx) {
                if (state.isLoading) {
                  return Center(child: CircularProgressIndicator(color: colors.primary));
                }
                if ((state.error != null || state.errorMessage != null) && state.recruitments.isEmpty) {
                  return _buildErrorState(context, state, vm);
                }
                if (filteredList.isEmpty) {
                  return _buildEmptyState(context, state, vm);
                }
                final myClubs = ref.watch(clubContextViewModelProvider).myClubs;
                final allMyClubNames = {
                  ...state.myClubNames,
                  ...myClubs.map((c) => c.clubName.trim().toLowerCase()),
                };
                return RefreshIndicator(
                  onRefresh: vm.explore,
                  color: colors.primary,
                  child: ResponsiveLayout(
                    mobile: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (ctx, index) {
                        final match = filteredList[index];
                        final sid = match.sessionId.trim().toLowerCase();
                        final isWaiting = match.isWaitingApproval || state.waitingSessionIds.contains(sid);
                        final isJoined = !isWaiting && (match.isConfirmedParticipant || state.joinedSessionIds.contains(sid));
                        final isMyClub = allMyClubNames.contains(match.clubName.trim().toLowerCase());
                        return _RecruitmentMatchCard(
                          match: match,
                          isJoining: state.isJoining,
                          isJoined: isJoined,
                          isWaiting: isWaiting,
                          isMyClub: isMyClub,
                          onJoin: () => _showJoinBottomSheet(context, vm, match),
                        );
                      },
                    ),
                    tablet: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (ctx, index) {
                        final match = filteredList[index];
                        final sid = match.sessionId.trim().toLowerCase();
                        final isWaiting = match.isWaitingApproval || state.waitingSessionIds.contains(sid);
                        final isJoined = !isWaiting && (match.isConfirmedParticipant || state.joinedSessionIds.contains(sid));
                        final isMyClub = allMyClubNames.contains(match.clubName.trim().toLowerCase());
                        return _RecruitmentMatchCard(
                          match: match,
                          isJoining: state.isJoining,
                          isJoined: isJoined,
                          isWaiting: isWaiting,
                          isMyClub: isMyClub,
                          onJoin: () => _showJoinBottomSheet(context, vm, match),
                        );
                      },
                    ),
                  ),
                );
              },
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

          // Skill Level Chips
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
                      value: '${match.minSkillLevel.displayName} (${match.minSkillLevel.description})',
                      valueColor: colors.primary,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.payments_rounded,
                      label: 'Tiền sân',
                      value: 'Nam: ${NumberFormat('#,###').format(match.maleCost)} đ • Nữ: ${NumberFormat('#,###').format(match.femaleCost)} đ',
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
                        'Lưu ý: Vui lòng đến sân đúng giờ. Tiền sân thanh toán trực tiếp tại sân sau buổi chơi. Nếu bận đột xuất, vui lòng hủy chỗ sớm để nhường người khác.',
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
                      icon: const Icon(Icons.sports_tennis_rounded, size: 18),
                      label: const Text('Nhận Suất Giao Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final ok = await vm.joinRecruitment(match.id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Nhận suất giao lưu thành công!'),
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
              isSearching ? 'Không Tìm Thấy Kèo Giao Lưu Phù Hợp' : 'Chưa Tìm Thấy Kèo Giao Lưu Nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Không có bài tuyển khách nào khớp với từ khóa "${state.searchTerm}". Hãy thử từ khóa khác hoặc xóa lọc.'
                  : 'Hiện chưa có bài tuyển khách giao lưu nào. Hãy thử tìm theo tên sân hoặc tải lại danh sách.',
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
            else ...[
              OutlinedButton.icon(
                onPressed: vm.explore,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tải lại danh sách'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showPassCourtModal(context),
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: const Text('Đăng tin pass sân ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ExploreRecruitmentsState state, ExploreRecruitmentsViewModel vm) {
    final colors = context.colors;
    final displayMessage = state.error?.getDisplayMessage(context.l10n) ??
        state.errorMessage ??
        context.l10n.error_system_retry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.explore,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.l10n.com_retry),
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

  void _showPassCourtModal(BuildContext context) async {
    final activeClubId = ref.read(activeClubContextProvider)?.clubId;
    final vm = ref.read(exploreRecruitmentsViewModelProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final primaryColor = context.colors.primary;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _IndependentPassCourtBottomSheet(
        vm: vm,
        activeClubId: activeClubId,
      ),
    );

    if (ok == true && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Đăng tin pass sân thành công! Tin đã xuất hiện trên Radar giao lưu.'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      vm.explore();
    }
  }
}

class _RecruitmentMatchCard extends StatelessWidget {
  final GuestRecruitment match;
  final bool isJoining;
  final bool isJoined;
  final bool isWaiting;
  final bool isMyClub;
  final VoidCallback onJoin;

  const _RecruitmentMatchCard({
    required this.match,
    required this.isJoining,
    this.isJoined = false,
    this.isWaiting = false,
    this.isMyClub = false,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final timeStr = '${DateFormat('HH:mm').format(match.startTime)} - ${DateFormat('HH:mm').format(match.endTime)}, ${DateFormat('dd/MM/yyyy').format(match.startTime)}';
    final isPassCourt = match.isPassCourt;

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
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (match.clubQualityScore != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 13, color: colors.warning),
                                  const SizedBox(width: 2),
                                  Text(
                                    match.clubQualityScore!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            if (match.distanceKm != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                ],
                              ),
                            if (isPassCourt)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isMyClub ? colors.primary.withValues(alpha: 0.15) : colors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isMyClub ? colors.primary.withValues(alpha: 0.4) : colors.warning.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  isMyClub ? 'Sân bạn pass' : 'Pass Sân',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: isMyClub ? colors.primary : colors.warning,
                                  ),
                                ),
                              ),
                            if (isWaiting)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Đang chờ duyệt',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors.warning,
                                  ),
                                ),
                              )
                            else if (isJoined)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Đã duyệt',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              )
                            else
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
                            if (match.hidePlayerList)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline_rounded, size: 9.5, color: colors.textMuted),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Ẩn danh',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Remaining Slots Badge or Pass Court Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isPassCourt
                          ? (isMyClub ? colors.primary.withValues(alpha: 0.12) : colors.warning.withValues(alpha: 0.15))
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPassCourt
                            ? (isMyClub ? colors.primary.withValues(alpha: 0.4) : colors.warning.withValues(alpha: 0.4))
                            : AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPassCourt ? (isMyClub ? Icons.person_pin_rounded : Icons.swap_horiz_rounded) : Icons.people_alt_rounded,
                          size: 12,
                          color: isPassCourt ? (isMyClub ? colors.primary : colors.warning) : colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPassCourt ? (isMyClub ? 'Sân của bạn' : 'Pass Sân') : 'Còn ${match.slotsRemaining} slot',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isPassCourt ? (isMyClub ? colors.primary : colors.warning) : colors.textSecondary,
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
                      isPassCourt ? match.cleanCourtLocation : match.courtLocation,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: match.courtLocation));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã sao chép địa chỉ sân: ${match.courtLocation}'),
                          backgroundColor: colors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Icon(Icons.copy_rounded, size: 14, color: colors.textMuted),
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

              // Skill requirement (Only for regular session recruitment)
              if (!isPassCourt) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.military_tech_rounded, size: 15, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Trình độ: ',
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        match.minSkillLevel.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Divider(height: 1, color: colors.cardBorder),
              const SizedBox(height: 10),

              // 3. Footer: Price & CTA Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPassCourt ? 'Giá pass trọn gói:' : 'Tiền sân:',
                          style: TextStyle(fontSize: 10.5, color: colors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        if (isPassCourt)
                          Text(
                            '${NumberFormat("#,###").format(match.passCourtPrice)} đ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.male_rounded, size: 13, color: colors.primary),
                                  Text(
                                    '${NumberFormat("#,###").format(match.maleCost)} đ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.female_rounded, size: 13, color: colors.secondary),
                                  Text(
                                    '${NumberFormat("#,###").format(match.femaleCost)} đ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isWaiting)
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppConfig.sessionDetailRoutePath(match.sessionId)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.warning,
                        side: BorderSide(color: colors.warning.withValues(alpha: 0.6)),
                        backgroundColor: colors.warning.withValues(alpha: 0.08),
                        minimumSize: const Size(64, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(Icons.hourglass_top_rounded, size: 14, color: colors.warning),
                      label: const Text(
                        'Đang chờ duyệt',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )
                  else if (isJoined)
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppConfig.sessionDetailRoutePath(match.sessionId)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.success,
                        side: BorderSide(color: colors.success.withValues(alpha: 0.5)),
                        backgroundColor: colors.success.withValues(alpha: 0.08),
                        minimumSize: const Size(64, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                      label: const Text(
                        'Đã duyệt',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )
                  else if (isPassCourt && isMyClub)
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppConfig.sessionDetailRoutePath(match.sessionId)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(color: colors.primary.withValues(alpha: 0.6)),
                        backgroundColor: colors.primary.withValues(alpha: 0.08),
                        minimumSize: const Size(64, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 14),
                      label: const Text(
                        'Xem chi tiết',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )
                  else if (isMyClub && !isPassCourt)
                    OutlinedButton.icon(
                      onPressed: () => context.push(AppConfig.sessionDetailRoutePath(match.sessionId)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.cardBorder),
                        backgroundColor: colors.surfaceSubtle,
                        minimumSize: const Size(64, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(Icons.groups_rounded, size: 14, color: colors.primary),
                      label: const Text(
                        'CLB của bạn',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: isPassCourt
                          ? () => context.push(AppConfig.sessionDetailRoutePath(match.sessionId))
                          : (isJoining ? null : onJoin),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPassCourt ? colors.warning : colors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(64, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(isPassCourt ? Icons.swap_horiz_rounded : Icons.sports_tennis_rounded, size: 14),
                      label: Text(
                        isPassCourt ? 'Nhận pass sân' : 'Tham gia ngay',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
}

class _IndependentPassCourtBottomSheet extends StatefulWidget {
  final ExploreRecruitmentsViewModel vm;
  final String? activeClubId;

  const _IndependentPassCourtBottomSheet({
    required this.vm,
    this.activeClubId,
  });

  @override
  State<_IndependentPassCourtBottomSheet> createState() => _IndependentPassCourtBottomSheetState();
}

class _IndependentPassCourtBottomSheetState extends State<_IndependentPassCourtBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _courtLocationController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  int _courtCount = 1;
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now.hour >= 21 ? now.add(const Duration(days: 1)) : now;
  }

  @override
  void dispose() {
    _courtLocationController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await MapLocationPickerSheet.show(
      context,
      initialVenueName: _courtLocationController.text.trim(),
      initialAddress: _addressController.text.trim(),
      initialLat: _latitude,
      initialLng: _longitude,
    );

    if (result != null && mounted) {
      setState(() {
        if (_courtLocationController.text.trim().isEmpty && result.venueName.isNotEmpty) {
          _courtLocationController.text = result.venueName;
        }
        _addressController.text = result.address;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _pickDate() async {
    final colors = context.colors;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: colors.primary,
            onPrimary: AppColors.white,
            surface: colors.surface,
            onSurface: colors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _inlineError = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawPrice = _priceController.text.replaceAll('.', '').replaceAll(',', '').replaceAll(' ', '').trim();
    final price = double.tryParse(rawPrice) ?? 0.0;
    if (price <= 0) {
      setState(() => _inlineError = 'Vui lòng nhập giá pass sân hợp lệ');
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (!endDateTime.isAfter(startDateTime)) {
      setState(() => _inlineError = 'Giờ kết thúc phải sau giờ bắt đầu');
      return;
    }

    if (startDateTime.isBefore(DateTime.now())) {
      setState(() => _inlineError = 'Khung giờ pass sân phải ở tương lai');
      return;
    }

    setState(() => _isSubmitting = true);

    final params = CreateCourtPassParams(
      clubId: widget.activeClubId,
      courtLocation: _courtLocationController.text.trim(),
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      startTime: startDateTime,
      endTime: endDateTime,
      courtCount: _courtCount,
      passPrice: price,
      contactPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      lat: _latitude,
      lng: _longitude,
      minSkillLevel: 'NB',
    );

    final sessionId = await widget.vm.createCourtPass(params);
    if (!mounted) return;

    if (sessionId != null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _inlineError = widget.vm.lastErrorMessage ?? 'Đăng tin thất bại. Vui lòng thử lại sau.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.flash_on_rounded, color: colors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đăng Tin Pass Sân',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Nhượng lại suất sân khi bạn đã thuê trước nhưng không chơi được',
                            style: TextStyle(fontSize: 12, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Error alert if any
                if (_inlineError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _inlineError!,
                            style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 1. Tên sân cầu lông
                Text(
                  'Tên sân cầu lông *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _courtLocationController,
                  decoration: InputDecoration(
                    hintText: 'VD: Sân Cầu Lông Kỳ Hòa - Sân 3',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    prefixIcon: Icon(Icons.sports_tennis_rounded, size: 18, color: colors.primary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tên sân';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 2. Địa chỉ sân & Chọn trên bản đồ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Địa chỉ sân (Tùy chọn)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    TextButton.icon(
                      onPressed: _openMapPicker,
                      icon: Icon(Icons.map_rounded, size: 16, color: colors.primary),
                      label: Text(
                        'Chọn trên bản đồ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'VD: 238 Đường 3/2, Quận 10, TP.HCM',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    prefixIcon: Icon(Icons.location_on_rounded, size: 18, color: colors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.map_rounded, size: 20, color: colors.primary),
                      tooltip: 'Mở bản đồ chọn vị trí',
                      onPressed: _openMapPicker,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
                if (_latitude != null && _longitude != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: colors.success),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Đã ghim vị trí trên bản đồ (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})',
                            style: TextStyle(fontSize: 11.5, color: colors.success, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // 3. Ngày chơi & Khung giờ
                Text(
                  'Thời gian chơi *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Ngày
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.inputFill,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dateStr,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Giờ bắt đầu
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => _pickTime(isStart: true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.inputFill,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time_rounded, size: 15, color: colors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                startTimeStr,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('-', style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.bold)),
                    ),
                    // Giờ kết thúc
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () => _pickTime(isStart: false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.inputFill,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time_filled_rounded, size: 15, color: colors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                endTimeStr,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Số lượng sân & Giá pass
                Row(
                  children: [
                    // Số lượng sân
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số sân',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: colors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _courtCount,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down_rounded, color: colors.textMuted),
                                items: [1, 2, 3, 4].map((count) {
                                  return DropdownMenuItem<int>(
                                    value: count,
                                    child: Text('$count sân', style: TextStyle(fontSize: 13, color: colors.textPrimary)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _courtCount = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Giá pass
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá pass lại (VNĐ) *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'VD: 150000',
                              hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                              suffixText: 'đ',
                              suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
                              filled: true,
                              fillColor: colors.inputFill,
                              prefixIcon: Icon(Icons.payments_rounded, size: 18, color: colors.primary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: colors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: colors.cardBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: colors.primary, width: 1.5),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Vui lòng nhập giá';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. Số điện thoại liên hệ
                Text(
                  'Số điện thoại liên hệ (Tùy chọn)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'VD: 0912345678 để người nhận pass liên hệ',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    prefixIcon: Icon(Icons.phone_rounded, size: 18, color: colors.primary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 6. Ghi chú thêm (Tùy chọn)
                Text(
                  'Ghi chú thêm (Tùy chọn)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'VD: Nhóm bận đột xuất cần pass lại, sân đẹp thảm mới...',
                    hintStyle: TextStyle(fontSize: 13, color: colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                              )
                            : const Icon(Icons.flash_on_rounded, size: 18),
                        label: Text(
                          _isSubmitting ? 'Đang đăng tin...' : 'Đăng Tin Pass Sân',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
