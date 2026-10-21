import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/club/club_vm/club_context_vm.dart';
import 'package:kltn2026_2027/widget/club_switcher_dialog.dart';
import 'dashboard_vm/dashboard_state.dart';
import 'dashboard_vm/dashboard_vm.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final vm = ref.read(dashboardViewModelProvider.notifier);
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.transparent,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.cardBackground,
            onRefresh: () async {
              await vm.loadData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, state.userProfile),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.gapH16,
                        _buildQuickActions(context, state.quickActions),
                        AppSpacing.gapH20,
                        _buildSportCategories(context, state.categories, vm),
                        AppSpacing.gapH20,
                        _buildPromoBanner(context, state.promoBanner),
                        AppSpacing.gapH20,
                        _buildNearbyVenues(context, state.venues, vm, state.isLoadingVenues),
                        AppSpacing.gapH24,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER WITH PROFILE & SEARCH BAR
  // ===========================================================================
  Widget _buildHeader(BuildContext context, WidgetRef ref, DashboardUserProfile profile) {
    final topPadding = MediaQuery.of(context).padding.top;
    final clubContext = ref.watch(clubContextViewModelProvider);
    final activeClubName = clubContext.currentClubName ?? context.l10n.club_switch;
    final roleName = clubContext.currentRole?.displayName;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDark ? colors.surface : AppColors.primaryHeader,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + 12,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row user info & badges
          Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.4), width: 2),
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                child: ClipOval(
                  child: profile.avatarUrl.isNotEmpty
                      ? Image.network(
                          profile.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.person, color: AppColors.white, size: 28),
                        )
                      : const Icon(Icons.person, color: AppColors.white, size: 28),
                ),
              ),
              AppSpacing.gapW12,
              // Welcome greeting & Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        'VIP ${profile.memberTier}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AppSpacing.gapH4,
                    Text(
                      profile.name.isNotEmpty ? profile.name : context.l10n.com_welcome_back,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Context Club Switcher Pill Button
              GestureDetector(
                onTap: () {
                  ClubSwitcherDialog.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_tennis_rounded, color: AppColors.white, size: 14),
                      AppSpacing.gapW4,
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 95),
                        child: Text(
                          activeClubName,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (roleName != null) ...[
                        AppSpacing.gapW4,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.3),
                            borderRadius: AppRadius.tag,
                          ),
                          child: Text(
                            roleName,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Icon(Icons.arrow_drop_down, color: AppColors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          // Search Input Bar
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: colors.cardBorder),
              boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
            ),
            child: TextField(
              style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: context.l10n.com_search,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colors.textPlaceholder,
                  fontSize: 13.5,
                ),
                prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 22),
                suffixIcon: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.tune,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. QUICK ACTION CARDS (4 ITEM ROW)
  // ===========================================================================
  Widget _buildQuickActions(BuildContext context, List<QuickActionItem> actions) {
    final colors = context.colors;

    return Row(
      children: actions.map((item) {
        return Expanded(
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () {
                switch (item.id) {
                  case 'schedule':
                    context.push(AppConfig.myBookingsRoutePath);
                    break;
                  case 'matchmaking':
                    context.push(AppConfig.exploreRecruitmentsScreenPath);
                    break;
                  case 'booking':
                    context.push(AppConfig.exploreClubsScreenPath);
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${context.l10n.com_feature_under_dev}: ${item.title}'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                }
              },
              borderRadius: AppRadius.card,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: AppRadius.card,
                  boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 22),
                    ),
                    AppSpacing.gapH8,
                    Text(
                      item.title,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // 3. SPORTS CATEGORY SECTION
  // ===========================================================================
  Widget _buildSportCategories(
    BuildContext context,
    List<SportCategoryItem> categories,
    DashboardViewModel vm,
  ) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.explore_tab_clubs.toUpperCase(),
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    context.l10n.com_view_all,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 12, color: colors.primary),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              return GestureDetector(
                onTap: () => vm.selectCategory(cat.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cat.isSelected ? colors.primaryContainer : colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cat.isSelected ? colors.primary : colors.cardBorder,
                      width: cat.isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 16, color: cat.isSelected ? colors.primary : colors.textSecondary),
                      AppSpacing.gapW8,
                      Text(
                        cat.name,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: cat.isSelected ? FontWeight.bold : FontWeight.w500,
                          color: cat.isSelected ? colors.primary : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. PROMOTIONAL BANNER
  // ===========================================================================
  Widget _buildPromoBanner(BuildContext context, PromoBannerItem promo) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: AppColors.warningGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: AppRadius.tag,
                  ),
                  child: Text(
                    'CODE: ${promo.promoCode}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  promo.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                AppSpacing.gapH4,
                Text(
                  promo.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapW12,
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.accentDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            child: Text(
              promo.buttonText,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. NEARBY VENUES SECTION
  // ===========================================================================
  Widget _buildNearbyVenues(
    BuildContext context,
    List<VenueItem> venues,
    DashboardViewModel vm,
    bool isLoading,
  ) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: colors.primary),
                const SizedBox(width: 4),
                Text(
                  context.l10n.explore_tab_clubs,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                context.l10n.com_view_all,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,
        if (isLoading && venues.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: CircularProgressIndicator(color: colors.primary),
            ),
          )
        else if (venues.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Center(
              child: Text(
                context.l10n.com_empty_data,
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: venues.length,
            separatorBuilder: (_, _) => AppSpacing.gapH12,
            itemBuilder: (context, index) {
              final venue = venues[index];
              return _buildVenueCard(context, venue, vm);
            },
          ),
      ],
    );
  }

  Widget _buildVenueCard(
    BuildContext context,
    VenueItem venue,
    DashboardViewModel vm,
  ) {
    final colors = context.colors;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Row(
        children: [
          // Left Thumbnail with Heart icon overlay
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderMd,
                  color: colors.surfaceSubtle,
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.borderMd,
                  child: venue.imageUrl.isNotEmpty
                      ? Image.network(
                          venue.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Icon(Icons.sports_tennis, color: colors.textMuted, size: 36),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.sports_tennis, color: colors.textMuted, size: 36),
                        ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => vm.toggleFavorite(venue.id),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      venue.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: venue.isFavorite ? colors.error : AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapW12,
          // Right Content Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tags
                Text(
                  venue.categories,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapH4,
                // Title & Rating Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        venue.name,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.gapW4,
                    Icon(Icons.star, size: 14, color: colors.accent),
                    const SizedBox(width: 2),
                    Text(
                      '${venue.rating}',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH4,
                // Address
                Text(
                  venue.address,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapH8,
                // Footer: Distance & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      venue.distance,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    Text(
                      venue.priceText,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
