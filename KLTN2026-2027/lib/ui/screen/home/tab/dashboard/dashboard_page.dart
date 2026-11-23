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
import 'package:kltn2026_2027/widget/app_network_image.dart';
import '../../../notification/notification_vm/notification_vm.dart';
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
            child: (state.playerProfile == null)
                ? SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    child: Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  )
                : SingleChildScrollView(
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
                        _buildHeroStartMatchCard(context, ref),
                        AppSpacing.gapH16,
                        _buildQuickActions(context, ref),
                        AppSpacing.gapH16,
                        _buildPlayerQuickStats(context, state),
                        AppSpacing.gapH20,
                        if (isTablet)
                          _buildTabletLayout(context, ref, state, vm)
                        else
                          _buildMobileLayout(context, ref, state, vm),
                        const SizedBox(height: 120),
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
  // 1. TOP HEADER WITH PLAYER IDENTITY (LIGHT NEO-SPORT THEME)
  // ===========================================================================
  Widget _buildHeader(BuildContext context, WidgetRef ref, PlayerProfile? playerProfile) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final colors = context.colors;
    final userProfile = ref.watch(currentUserProfileProvider);

    final displayName = playerProfile?.fullName.isNotEmpty == true
        ? playerProfile!.fullName
        : (userProfile?.userName.isNotEmpty == true ? userProfile!.userName : 'Tay vợt');

    final skillLevelName = playerProfile?.skillLevel.displayName ?? 'NB';
    final isOpenForGuest = playerProfile?.isOpenForGuest ?? false;
    final reputation = (playerProfile?.reputationScore ?? 5.0).toStringAsFixed(1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.isDark ? null : AppColors.limeAuraGradient,
        color: context.isDark ? colors.surface : null,
      ),
      padding: EdgeInsets.only(
        top: topPadding + 14,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with Safe Network Image & Neon Lime Glow Ring
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonLimeDark, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonLime.withValues(alpha: 0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: AppNetworkImage(
                  imageUrl: playerProfile?.avatarUrl,
                  width: 44,
                  height: 44,
                  isCircle: true,
                  defaultFallbackIcon: Icons.person,
                  backgroundColor: colors.primaryContainer,
                ),
              ),
              AppSpacing.gapW12,
              // User Greeting & Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Xin chào, ',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.neonLime.withValues(alpha: 0.3),
                            borderRadius: AppRadius.chip,
                            border: Border.all(color: AppColors.neonLimeDark.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            skillLevelName,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                        if (isOpenForGuest) ...[
                          AppSpacing.gapW4,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
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
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: AppTypography.titleLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              // Compact Reputation Badge
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: colors.accent, size: 15),
                    AppSpacing.gapW4,
                    Text(
                      reputation,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              // Notification Bell (Dark circular badge with Neon Lime accent)
              _buildNotificationBell(context, ref),
            ],
          ),
          AppSpacing.gapH12,
          // Search Input Quick Access (Sport Pill)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(homeTabProvider.notifier).state = 2;
            },
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
                  Icon(Icons.tune, color: AppColors.neonLimeDark, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1.1 HERO START MATCH CAPSULE (ALL-WHITE SPORT CAPSULE)
  // ===========================================================================
  Widget _buildHeroStartMatchCard(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Racket Icon in Mint / Emerald Gradient
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer,
                  AppColors.neonLimeLight.withValues(alpha: 0.5),
                ],
              ),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.sports_tennis_rounded,
                color: colors.primary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Title & Mint Emerald Pill CTA Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bắt đầu trận đấu mới',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ghép cặp & phân sân thi đấu tức thì',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(homeTabProvider.notifier).state = 2;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Trận Đấu Mới'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final unreadCount = ref.watch(notificationViewModelProvider.select((s) => s.unreadCount));

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(AppConfig.notificationsPath);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: colors.cardBorder, width: 1.2),
          boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: 20, color: colors.textPrimary),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
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
        title: l10n.home_find_match,
        icon: Icons.radar_rounded,
        bgColor: colors.accent.withValues(alpha: 0.15),
        iconColor: colors.accent,
        onTap: () => ref.read(homeTabProvider.notifier).state = 2,
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
        onTap: () => ref.read(homeTabProvider.notifier).state = 2,
      ),
      _QuickActionData(
        title: l10n.payment_my_fees,
        icon: Icons.receipt_long_rounded,
        bgColor: colors.warning.withValues(alpha: 0.12),
        iconColor: colors.warning,
        onTap: () => context.push(AppConfig.myFeesPath),
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
                      SizedBox(
                        height: 36,
                        child: Center(
                          child: Text(
                            action.title,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
        _buildUpcomingSessionHero(context, ref, state.nextBooking),
        AppSpacing.gapH20,
        _buildRadarRecruitments(context, ref, state.nearbyRecruitments, vm, state.joiningRecruitmentId, state.upcomingBookings.map((b) => b.sessionId.trim().toLowerCase()).toSet()),
        AppSpacing.gapH20,
        _buildNearbyClubs(context, ref, state.nearbyClubs),
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
              _buildUpcomingSessionHero(context, ref, state.nextBooking),
              AppSpacing.gapH20,
              _buildRadarRecruitments(context, ref, state.nearbyRecruitments, vm, state.joiningRecruitmentId, state.upcomingBookings.map((b) => b.sessionId.trim().toLowerCase()).toSet()),
            ],
          ),
        ),
        AppSpacing.gapW16,
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNearbyClubs(context, ref, state.nearbyClubs),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. HERO CARD: UPCOMING SESSION / BOOKING (FR08 - FR10)
  // ===========================================================================
  Widget _buildUpcomingSessionHero(BuildContext context, WidgetRef ref, MyBookingItem? booking) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.2),
                        colors.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(Icons.event_available_rounded, color: colors.primary, size: 24),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
              ],
            ),
            AppSpacing.gapH12,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.read(homeTabProvider.notifier).state = 2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  textStyle: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    inherit: false,
                  ),
                ),
                child: Text(l10n.home_find_matches_now),
              ),
            ),
          ],
        ),
      );
    }

    final timeStr = _formatSessionDateTime(booking.startTime, booking.endTime);

    Color statusBgColor = colors.success.withValues(alpha: 0.15);
    Color statusTextColor = colors.success;
    String statusText = l10n.booking_status_confirmed;

    if (booking.isOngoing) {
      statusBgColor = colors.info.withValues(alpha: 0.15);
      statusTextColor = colors.info;
      statusText = 'Đang diễn ra';
    } else if (booking.isWaiting) {
      statusBgColor = colors.warning.withValues(alpha: 0.15);
      statusTextColor = colors.warning;
      statusText = l10n.home_queue_order(booking.queueOrder);
    } else if (booking.isCheckedIn) {
      statusBgColor = colors.primary.withValues(alpha: 0.15);
      statusTextColor = colors.primary;
      statusText = 'Đã Ra Sân';
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonLimeDark.withValues(alpha: 0.35), width: 1.2),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.neonLimeDark.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.neonLimeDark),
                    AppSpacing.gapW4,
                    Text(
                      timeStr,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
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
          AppSpacing.gapH12,
          Row(
            children: [
              AppNetworkImage(
                imageUrl: booking.clubAvatarUrl,
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(8),
                defaultFallbackIcon: Icons.sports_tennis_rounded,
                backgroundColor: colors.primaryContainer,
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.clubName,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      booking.sessionTitle,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
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
              ElevatedButton.icon(
                onPressed: () => context.push('/session/${booking.sessionId}'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('Chi tiết ca đấu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
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
    WidgetRef ref,
    List<GuestRecruitment> recruitments,
    DashboardViewModel vm,
    String? joiningId,
    Set<String> joinedSessionIds,
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
              onTap: () => ref.read(homeTabProvider.notifier).state = 2,
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
                'Chưa có buổi nào tuyển vãng lai quanh đây',
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
              return _buildRecruitmentCard(context, item, vm, joiningId == item.id, isJoined: joinedSessionIds.contains(item.sessionId.trim().toLowerCase()));
            },
          ),
      ],
    );
  }

  Widget _buildRecruitmentCard(
    BuildContext context,
    GuestRecruitment item,
    DashboardViewModel vm,
    bool isJoining, {
    bool isJoined = false,
  }) {
    final colors = context.colors;
    final l10n = context.l10n;
    final timeStr = _formatSessionDateTime(item.startTime, item.endTime);
    final isPassCourt = item.isPassCourt;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isPassCourt
              ? colors.warning.withValues(alpha: 0.35)
              : colors.cardBorder,
        ),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: () => context.push(AppConfig.sessionDetailRoutePath(item.sessionId)),
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          AppNetworkImage(
                            imageUrl: null,
                            width: 26,
                            height: 26,
                            borderRadius: BorderRadius.circular(6),
                            defaultFallbackIcon: isPassCourt
                                ? Icons.swap_horiz_rounded
                                : Icons.groups_rounded,
                            backgroundColor: isPassCourt
                                ? colors.warning.withValues(alpha: 0.15)
                                : colors.surfaceSubtle,
                          ),
                          AppSpacing.gapW8,
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
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPassCourt) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.15),
                              borderRadius: AppRadius.tag,
                              border: Border.all(
                                color: colors.warning.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz_rounded, size: 11, color: colors.warning),
                                AppSpacing.gapW4,
                                Text(
                                  'PASS SÂN',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.gapW4,
                        ],
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
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: isPassCourt ? colors.warning : colors.textSecondary,
                    ),
                    AppSpacing.gapW4,
                    Expanded(
                      child: Text(
                        isPassCourt ? item.cleanCourtLocation : item.courtLocation,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: isPassCourt ? FontWeight.w500 : FontWeight.normal,
                        ),
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
                    Expanded(
                      child: Text(
                        timeStr,
                        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH4,
                if (!isPassCourt)
                  Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 13, color: colors.textSecondary),
                      AppSpacing.gapW4,
                      Text(
                        'Tiền sân: ',
                        style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                      ),
                      Icon(Icons.male_rounded, size: 13, color: colors.primary),
                      Text(
                        '${NumberFormat('#,###').format(item.maleCost)} đ',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      AppSpacing.gapW8,
                      Icon(Icons.female_rounded, size: 13, color: colors.secondary),
                      Text(
                        '${NumberFormat('#,###').format(item.femaleCost)} đ',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 13, color: colors.warning),
                      AppSpacing.gapW4,
                      Text(
                        'Giá pass trọn gói: ',
                        style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(item.passCourtPrice > 0 ? item.passCourtPrice : item.sharedCost)} đ',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.warning,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isPassCourt)
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
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.12),
                          borderRadius: AppRadius.tag,
                        ),
                        child: Text(
                          'Nhượng lại giờ sân',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isPassCourt) ...[
                          OutlinedButton(
                            onPressed: () => context.push(AppConfig.sessionDetailRoutePath(item.sessionId)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.textPrimary,
                              side: BorderSide(color: colors.cardBorder),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                            ),
                            child: Text(
                              l10n.com_view_detail,
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          AppSpacing.gapW8,
                          if (isJoined)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: AppRadius.button,
                                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12, color: colors.primary),
                                  AppSpacing.gapW4,
                                  Text(
                                    'Đã tham gia',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
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
                                        context.push(AppConfig.sessionDetailRoutePath(item.sessionId));
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                visualDensity: VisualDensity.compact,
                                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                textStyle: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  inherit: false,
                                ),
                              ),
                              child: isJoining
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                                    )
                                  : Text(l10n.home_join_match),
                            ),
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: () => context.push(AppConfig.sessionDetailRoutePath(item.sessionId)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.warning,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                              textStyle: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                inherit: false,
                              ),
                            ),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                            label: const Text('Xem tin pass sân'),
                          ),
                        ],
                      ],
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

  // ===========================================================================
  // 7. NEARBY BADMINTON CLUBS (FR06)
  // ===========================================================================
  Widget _buildNearbyClubs(
    BuildContext context,
    WidgetRef ref,
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
              onTap: () => ref.read(homeTabProvider.notifier).state = 2,
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
              AppNetworkImage(
                imageUrl: club.avatarUrl,
                width: 60,
                height: 60,
                borderRadius: AppRadius.borderMd,
                defaultFallbackIcon: Icons.groups_rounded,
                backgroundColor: colors.primaryContainer.withValues(alpha: 0.5),
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

  // ===========================================================================
  // 8. DEFENSIVE TIME FORMATTING (ZERO RUNTIME LOCALE CRASH)
  // ===========================================================================
  String _formatSessionDateTime(DateTime startTime, DateTime endTime) {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');

    const weekdays = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ Nhật',
    ];
    final weekday = weekdays[(startTime.weekday - 1).clamp(0, 6)];
    final day = startTime.day.toString().padLeft(2, '0');
    final month = startTime.month.toString().padLeft(2, '0');

    return '$startHour:$startMin - $endHour:$endMin, $weekday $day/$month';
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
