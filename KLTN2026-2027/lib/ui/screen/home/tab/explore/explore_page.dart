import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/explore_clubs/explore_clubs_screen.dart';
import 'explore_recruitments_page.dart';

class ExplorePage extends ConsumerStatefulWidget {
  final int initialSubTab;

  const ExplorePage({
    super.key,
    this.initialSubTab = 0,
  });

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSubTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
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
              child: Icon(
                Icons.explore_rounded,
                color: colors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.nav_explore,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Buổi giao lưu và câu lạc bộ lân cận',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                bottom: BorderSide(color: colors.cardBorder, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: colors.textMuted,
              labelStyle: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.sports_tennis_rounded, size: 20),
                  text: l10n.explore_tab_recruitments,
                ),
                Tab(
                  icon: const Icon(Icons.radar_rounded, size: 20),
                  text: l10n.explore_tab_clubs,
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExploreRecruitmentsPage(isEmbedded: true),
          ExploreClubsScreen(isEmbedded: true),
        ],
      ),
    );
  }
}
