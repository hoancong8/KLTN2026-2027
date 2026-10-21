// lib/ui/screen/home/tab/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/domain/entities/club/explore_club.dart';
import 'package:kltn2026_2027/domain/entities/player_profile.dart';
import 'package:kltn2026_2027/domain/entities/session/guest_recruitment.dart';
import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';
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
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (context.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
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
              await vm.refreshData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, state.playerProfile),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.gapH16,
                        _buildQuickActions(context, ref),
                        AppSpacing.gapH16,
                        _buildPlayerQuickStats(context, state),
                        AppSpacing.gapH20,
                        if (isTablet)
                          _buildTabletLayout(context, ref, state, vm)
                        else
                          _buildMobileLayout(context, ref, state, vm),
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
  // 1. TOP HEADER WITH PLAYER IDENTITY & ACTIVE CLUB CONTEXT
  // ===========================================================================
  Widget _buildHeader(BuildContext context, WidgetRef ref, PlayerProfile? playerProfile) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final clubContext = ref.watch(clubContextViewModelProvider);
    final activeClubName = clubContext.currentClubName ?? context.l10n.club_switch;
    final roleName = clubContext.currentRole?.displayName;
    final colors = context.colors;
    final userProfile = ref.watch(currentUserProfileProvider);

    final displayName = playerProfile?.fullName.isNotEmpty == true
        ? playerProfile!.fullName
        : (userProfile?.userName.isNotEmpty == true ? userProfile!.userName : 'Player');

    final skillLevelName = playerProfile?.skillLevel.displayName ?? 'NB';
    final isOpenForGuest = playerProfile?.isOpenForGuest ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDark ? colors.surface : colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: colors.cardBorder),
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + 12,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 2),
                  color: colors.primaryContainer,
                ),
                child: ClipOval(
                  child: playerProfile?.avatarUrl != null && playerProfile!.avatarUrl!.isNotEmpty
                      ? Image.network(
                          playerProfile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(Icons.person, color: colors.primary, size: 28),
                        )
                      : Icon(Icons.person, color: colors.primary, size: 28),
                ),
              ),
              AppSpacing.gapW12,
              // User Name & Skill Level Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: AppRadius.chip,
                            border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sports_tennis_rounded, size: 11, color: colors.primary),
                              AppSpacing.gapW4,
                              Text(
                                '${context.l10n.home_skill_level_label}: $skillLevelName',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOpenForGuest) ...[
                          AppSpacing.gapW4,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.15),
                              borderRadius: AppRadius.chip,
                              border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              context.l10n.home_open_guest,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.gapH4,
                    Text(
                      displayName,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Context Club Switcher Pill Button (FR04)
              GestureDetector(
                onTap: () => ClubSwitcherDialog.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.cardBorder),
                    boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_rounded, color: colors.primary, size: 15),
                      AppSpacing.gapW4,
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 90),
                        child: Text(
                          activeClubName,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.textPrimary,
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
                            color: colors.primaryContainer,
                            borderRadius: AppRadius.tag,
                          ),
                          child: Text(
                            roleName,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      Icon(Icons.arrow_drop_down, color: colors.textSecondary, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          // Search Input Quick Access
          GestureDetector(
            onTap: () => context.push(AppConfig.exploreClubsScreenPath),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.cardBorder),
                boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.textSecondary, size: 20),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      context.l10n.home_search_hint,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textPlaceholder,
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: colors.primary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. QUICK ACTION BUTTONS (4 CORE DOMAIN SHORTCUTS)
  // ===========================================================================
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;

    final actions = [
      _QuickActionData(
        title: l10n.home_my_schedule,
        icon: Icons.calendar_month_rounded,
        bgColor: colors.primary.withValues(alpha: 0.12),
        iconColor: colors.primary,
        onTap: () => context.push(AppConfig.myBookingsRoutePath),
      ),
      _QuickActionData(
        title: l10n.home_find_match,
        icon: Icons.radar_rounded,
        bgColor: colors.accent.withValues(alpha: 0.15),
        iconColor: colors.accent,
        onTap: () => context.push(AppConfig.exploreRecruitmentsScreenPath),
      ),
      _QuickActionData(
        title: l10n.home_my_clubs,
        icon: Icons.groups_rounded,
        bgColor: colors.success.withValues(alpha: 0.12),
        iconColor: colors.success,
        onTap: () {
          ref.read(homeTabProvider.notifier).state = 1;
        },
      ),
      _QuickActionData(
        title: l10n.home_explore_clubs,
        icon: Icons.explore_rounded,
        bgColor: colors.info.withValues(alpha: 0.12),
        iconColor: colors.info,
        onTap: () => context.push(AppConfig.exploreClubsScreenPath),
      ),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: colors.cardBackground,
              borderRadius: AppRadius.card,
              child: InkWell(
                onTap: action.onTap,
                borderRadius: AppRadius.card,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.card,
                    border: Border.all(color: colors.cardBorder),
                    boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: action.bgColor,
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Icon(action.icon, color: action.iconColor, size: 22),
                      ),
                      AppSpacing.gapH8,
                      Text(
                        action.title,
                        style: AppTypography.labelSmall.copyWith(
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
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // 3. PLAYER QUICK STATS (3 MINI CARDS)
  // ===========================================================================
  Widget _buildPlayerQuickStats(BuildContext context, DashboardState state) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              label: l10n.home_stat_clubs,
              value: '${state.activeClubCount}',
              icon: Icons.groups_outlined,
              iconColor: colors.primary,
            ),
          ),
          Container(height: 28, width: 1, color: colors.divider),
          Expanded(
            child: _buildStatItem(
              context,
              label: l10n.home_stat_sessions,
              value: '${state.upcomingSessionCount}',
              icon: Icons.event_available_outlined,
              iconColor: colors.success,
            ),
          ),
          Container(height: 28, width: 1, color: colors.divider),
          Expanded(
            child: _buildStatItem(
              context,
              label: l10n.home_stat_reputation,
              value: state.reputationScore.toStringAsFixed(1),
              icon: Icons.star_rounded,
              iconColor: colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: iconColor),
        AppSpacing.gapW8,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: colors.textSecondary,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. MOBILE & TABLET LAYOUTS
  // ===========================================================================
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    DashboardViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUpcomingSessionHero(context, state.nextBooking),
        AppSpacing.gapH20,
        _buildRadarRecruitments(context, state.nearbyRecruitments, vm, state.joiningRecruitmentId),
        AppSpacing.gapH20,
        _buildNearbyClubs(context, state.nearbyClubs),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    DashboardViewModel vm,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUpcomingSessionHero(context, state.nextBooking),
              AppSpacing.gapH20,
              _buildRadarRecruitments(context, state.nearbyRecruitments, vm, state.joiningRecruitmentId),
            ],
          ),
        ),
        AppSpacing.gapW16,
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNearbyClubs(context, state.nearbyClubs),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. HERO CARD: UPCOMING SESSION / BOOKING (FR08 - FR10)
  // ===========================================================================
  Widget _buildUpcomingSessionHero(BuildContext context, MyBookingItem? booking) {
    final colors = context.colors;
    final l10n = context.l10n;

    if (booking == null) {
      return Container(
        width: double.infinity,
        padding: AppSpacing.card,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: AppRadius.card,
          border: Border.all(color: colors.cardBorder),
          boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(Icons.event_busy_rounded, color: colors.primary, size: 26),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.home_upcoming_sessions,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.home_no_upcoming_sessions,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapW8,
            ElevatedButton(
              onPressed: () => context.push(AppConfig.exploreRecruitmentsScreenPath),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: Text(
                l10n.home_find_matches_now,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('EEE, dd/MM/yyyy', 'vi');
    final timeStr = '${timeFormatter.format(booking.startTime)} - ${timeFormatter.format(booking.endTime)}, ${dateFormatter.format(booking.startTime)}';

    Color statusBgColor = colors.success.withValues(alpha: 0.15);
    Color statusTextColor = colors.success;
    String statusText = l10n.booking_status_confirmed;

    if (booking.isWaiting) {
      statusBgColor = colors.warning.withValues(alpha: 0.15);
      statusTextColor = colors.warning;
      statusText = l10n.home_queue_order(booking.queueOrder);
    } else if (booking.isCheckedIn) {
      statusBgColor = colors.primary.withValues(alpha: 0.15);
      statusTextColor = colors.primary;
      statusText = 'Đã điểm danh';
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_tennis_rounded, size: 16, color: colors.primary),
                  AppSpacing.gapW4,
                  Text(
                    booking.clubName,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  statusText,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            booking.sessionTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: colors.textSecondary),
              AppSpacing.gapW4,
              Expanded(
                child: Text(
                  timeStr,
                  style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          AppSpacing.gapH4,
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: colors.textSecondary),
              AppSpacing.gapW4,
              Expanded(
                child: Text(
                  booking.courtLocation,
                  style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.feePerMember > 0
                    ? '${(booking.feePerMember / 1000).toInt()}k / người'
                    : 'Miễn phí / Quỹ CLB',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/session/${booking.sessionId}'),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Chi tiết ca đấu'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. RADAR MATCH RECRUITMENTS SECTION (FR11, FR12)
  // ===========================================================================
  Widget _buildRadarRecruitments(
    BuildContext context,
    List<GuestRecruitment> recruitments,
    DashboardViewModel vm,
    String? joiningId,
  ) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.radar_rounded, size: 18, color: colors.accent),
                AppSpacing.gapW4,
                Text(
                  l10n.home_radar_recruitments,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => context.push(AppConfig.exploreRecruitmentsScreenPath),
              child: Text(
                l10n.com_view_all,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,
        if (recruitments.isEmpty)
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
                'Chưa có bài đăng tuyển quân quanh khu vực',
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recruitments.length > 3 ? 3 : recruitments.length,
            separatorBuilder: (_, _) => AppSpacing.gapH12,
            itemBuilder: (context, index) {
              final item = recruitments[index];
              return _buildRecruitmentCard(context, item, vm, joiningId == item.id);
            },
          ),
      ],
    );
  }

  Widget _buildRecruitmentCard(
    BuildContext context,
    GuestRecruitment item,
    DashboardViewModel vm,
    bool isJoining,
  ) {
    final colors = context.colors;
    final l10n = context.l10n;
    final timeFormatter = DateFormat('HH:mm');
    final timeStr = '${timeFormatter.format(item.startTime)} - ${timeFormatter.format(item.endTime)}';

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.clubName,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.distanceKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.near_me_outlined, size: 10, color: colors.textSecondary),
                      AppSpacing.gapW4,
                      Text(
                        l10n.home_distance_km(item.distanceKm!.toStringAsFixed(1)),
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: colors.textSecondary),
              AppSpacing.gapW4,
              Expanded(
                child: Text(
                  item.courtLocation,
                  style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.gapH4,
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 13, color: colors.textSecondary),
              AppSpacing.gapW4,
              Text(
                timeStr,
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text(
                      l10n.home_slots_remaining(item.slotsRemaining),
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppSpacing.gapW4,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.15),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text(
                      '${context.l10n.home_skill_level_label}: ${item.minSkillLevel.displayName}',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isJoining
                    ? null
                    : () async {
                        final success = await vm.joinRecruitment(item.id);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.home_joined_match_success),
                              backgroundColor: colors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                child: isJoining
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10n.home_join_match,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. NEARBY BADMINTON CLUBS (FR06)
  // ===========================================================================
  Widget _buildNearbyClubs(
    BuildContext context,
    List<ExploreClub> clubs,
  ) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.place_outlined, size: 18, color: colors.primary),
                AppSpacing.gapW4,
                Text(
                  l10n.home_nearby_clubs,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => context.push(AppConfig.exploreClubsScreenPath),
              child: Text(
                l10n.com_view_all,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,
        if (clubs.isEmpty)
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
                l10n.com_empty_data,
                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clubs.length > 4 ? 4 : clubs.length,
            separatorBuilder: (_, _) => AppSpacing.gapH12,
            itemBuilder: (context, index) {
              final club = clubs[index];
              return _buildClubCard(context, club);
            },
          ),
      ],
    );
  }

  Widget _buildClubCard(BuildContext context, ExploreClub club) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Material(
      color: colors.cardBackground,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: () => context.push(AppConfig.clubDetailRoutePath(club.id)),
        borderRadius: AppRadius.card,
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.cardBorder),
            boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderMd,
                  color: colors.primaryContainer.withValues(alpha: 0.5),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.borderMd,
                  child: club.avatarUrl != null && club.avatarUrl!.isNotEmpty
                      ? Image.network(
                          club.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(Icons.groups_rounded, color: colors.primary, size: 28),
                        )
                      : Icon(Icons.groups_rounded, color: colors.primary, size: 28),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            club.groupName,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (club.isRecruiting)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.15),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              l10n.home_recruiting_badge,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    AppSpacing.gapH4,
                    if (club.fixedVenueName != null)
                      Text(
                        club.fixedVenueName!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    AppSpacing.gapH4,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${club.memberCount} thành viên',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                        if (club.distanceKm != null)
                          Text(
                            l10n.home_distance_km(club.distanceKm!.toStringAsFixed(1)),
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}
