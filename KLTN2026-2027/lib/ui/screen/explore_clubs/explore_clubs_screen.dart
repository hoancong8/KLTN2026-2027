import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/consts/app_config.dart';
import '../../../app/provider/localization_provider.dart';
import '../../../app/utils/exception_ext.dart';
import '../../../domain/enums/session_enums.dart';
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
      backgroundColor: AppColors.neutral50,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              title: const Row(
                children: [
                  Icon(Icons.radar_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Tìm kiếm CLB quanh đây',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
      body: Column(
        children: [
          // 1. Search Box
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên nhóm, tên sân, địa chỉ...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          vm.setSearchTerm('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (val) => vm.setSearchTerm(val),
              textInputAction: TextInputAction.search,
            ),
          ),

          // 2. Filters (Radius & Recruiting & Skill)
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                // Radius Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.explore_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      const Text(
                        'Bán kính: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      ),
                      for (final r in [5.0, 10.0, 20.0, 50.0]) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text('${r.toInt()} km'),
                            selected: state.radiusKm == r,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            backgroundColor: AppColors.surfaceSubtle,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: state.radiusKm == r ? FontWeight.w700 : FontWeight.w500,
                              color: state.radiusKm == r ? AppColors.primary : AppColors.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: state.radiusKm == r ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            onSelected: (_) => vm.setRadius(r),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),

                      // Recruiting Toggle Chip
                      FilterChip(
                        label: const Text('Đang tuyển quân'),
                        selected: state.isRecruitingOnly == true,
                        selectedColor: AppColors.successLight,
                        backgroundColor: AppColors.surfaceSubtle,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: state.isRecruitingOnly == true ? FontWeight.w700 : FontWeight.w500,
                          color: state.isRecruitingOnly == true ? AppColors.roleMember : AppColors.textPrimary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: state.isRecruitingOnly == true ? AppColors.roleMember : Colors.transparent,
                          ),
                        ),
                        onSelected: (selected) => vm.toggleRecruitingOnly(selected ? true : null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Skill Level Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_tennis_rounded, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      const Text(
                        'Trình độ: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('Tất cả'),
                          selected: state.selectedSkillLevel == null,
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          backgroundColor: AppColors.surfaceSubtle,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: state.selectedSkillLevel == null ? FontWeight.w700 : FontWeight.w500,
                            color: state.selectedSkillLevel == null ? AppColors.primary : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: state.selectedSkillLevel == null ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                          onSelected: (_) => vm.setSkillLevel(null),
                        ),
                      ),
                      for (final skill in SkillLevel.values) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(skill.code),
                            selected: state.selectedSkillLevel == skill,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            backgroundColor: AppColors.surfaceSubtle,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: state.selectedSkillLevel == skill ? FontWeight.w700 : FontWeight.w500,
                              color: state.selectedSkillLevel == skill ? AppColors.primary : AppColors.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: state.selectedSkillLevel == skill ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            onSelected: (_) => vm.setSkillLevel(state.selectedSkillLevel == skill ? null : skill),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 3. Results Header & List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Tìm thấy ${state.clubs.length} câu lạc bộ',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(
                  'Quanh bán kính ${state.radiusKm.toInt()} km',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // 4. Clubs List
          Expanded(
            child: state.isLoading && state.clubs.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : state.clubs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.explore_off_outlined, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'Không tìm thấy câu lạc bộ nào phù hợp',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Thử mở rộng bán kính quét hoặc xóa bộ lọc trình độ',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                vm.setSearchTerm('');
                                vm.setSkillLevel(null);
                                vm.setRadius(50.0);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Mở rộng bán kính 50km'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => vm.loadClubs(),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        ],
      ),
    );
  }
}
