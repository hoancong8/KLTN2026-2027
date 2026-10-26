import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/consts/app_config.dart';
import '../../../app/provider/localization_provider.dart';
import '../../../app/utils/exception_ext.dart';
import '../../../domain/enums/session_enums.dart';
import '../../../widget/responsive_layout.dart';
import 'explore_clubs_vm/explore_clubs_vm.dart';
import 'widgets/club_explore_card.dart';

class ExploreClubsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const ExploreClubsScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<ExploreClubsScreen> createState() => _ExploreClubsScreenState();
}

class _ExploreClubsScreenState extends ConsumerState<ExploreClubsScreen> {
  final _searchController = TextEditingController();


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(exploreClubsViewModelProvider);
    final vm = ref.read(exploreClubsViewModelProvider.notifier);

    ref.listen(exploreClubsViewModelProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.getDisplayMessage(context.l10n)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: colors.surface,
              elevation: 0,
              surfaceTintColor: AppColors.transparent,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.radar_rounded, color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tìm Kiếm CLB',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => vm.loadClubs(),
                  tooltip: 'Tải lại',
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
                      'Câu lạc bộ quanh bạn',
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
                    '${state.clubs.length} CLB khả dụng',
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

          // 3. Clubs List (Responsive: Mobile 1 column, Tablet 2 columns)
          Expanded(
            child: state.isLoading && state.clubs.isEmpty
                ? Center(child: CircularProgressIndicator(color: colors.primary))
                : state.clubs.isEmpty
                    ? _buildEmptyState(context, state, vm)
                    : RefreshIndicator(
                        color: colors.primary,
                        onRefresh: () => vm.loadClubs(),
                        child: ResponsiveLayout(
                          mobile: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: state.clubs.length,
                            itemBuilder: (ctx, index) {
                              final club = state.clubs[index];
                              return ClubExploreCard(
                                club: club,
                                onTap: () {
                                  context.push(AppConfig.clubDetailRoutePath(club.id));
                                },
                              );
                            },
                          ),
                          tablet: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.55,
                            ),
                            itemCount: state.clubs.length,
                            itemBuilder: (ctx, index) {
                              final club = state.clubs[index];
                              return ClubExploreCard(
                                club: club,
                                onTap: () {
                                  context.push(AppConfig.clubDetailRoutePath(club.id));
                                },
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
    dynamic state,
    ExploreClubsViewModel vm,
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
              hintText: 'Tìm theo tên nhóm, tên sân, địa chỉ...',
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
            onSubmitted: (val) => vm.setSearchTerm(val),
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 10),

          // 2. Filter Toggles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Recruiting Toggle Pill
                InkWell(
                  onTap: () => vm.toggleRecruitingOnly(state.isRecruitingOnly == true ? null : true),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: state.isRecruitingOnly == true ? AppColors.successLight : colors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.isRecruitingOnly == true ? AppColors.success : colors.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 13,
                          color: state.isRecruitingOnly == true ? AppColors.success : colors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đang tuyển thành viên',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: state.isRecruitingOnly == true ? FontWeight.bold : FontWeight.w500,
                            color: state.isRecruitingOnly == true ? AppColors.success : colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                  final isSelected = state.selectedSkillLevel == s;
                  return _buildSkillChip(
                    context,
                    label: s.displayName,
                    isSelected: isSelected,
                    onTap: () => vm.setSkillLevel(isSelected ? null : s),
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

  Widget _buildEmptyState(
    BuildContext context,
    dynamic state,
    ExploreClubsViewModel vm,
  ) {
    final colors = context.colors;
    final isSearching = _searchController.text.trim().isNotEmpty;

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
              isSearching ? 'Không Tìm Thấy CLB Phù Hợp' : 'Chưa Tìm Thấy Câu Lạc Bộ Nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Không có CLB nào khớp với từ khóa "${_searchController.text}". Hãy thử từ khóa khác hoặc xóa lọc.'
                  : 'Hiện chưa có câu lạc bộ nào phù hợp. Hãy thử tìm theo tên hoặc khu vực.',
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
              OutlinedButton.icon(
                onPressed: vm.loadClubs,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tải lại danh sách'),
              ),
          ],
        ),
      ),
    );
  }
}
