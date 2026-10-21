// lib/ui/screen/home/widgets/home_tablet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/club/club_vm/club_context_vm.dart';
import 'package:kltn2026_2027/widget/club_switcher_dialog.dart';
import 'home_nav_destination.dart';

class HomeTablet extends ConsumerStatefulWidget {
  final PageController pageController;
  final Function(int) onTabSelected;
  final List<Widget> pages;
  final List<HomeNavDestination> destinations;
  final Key? pageViewKey;

  const HomeTablet({
    super.key,
    required this.pageController,
    required this.onTabSelected,
    required this.pages,
    required this.destinations,
    this.pageViewKey,
  });

  @override
  ConsumerState<HomeTablet> createState() => _HomeTabletState();
}

class _HomeTabletState extends ConsumerState<HomeTablet> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final tabIndex = ref.watch(homeTabProvider);
    final colors = context.colors;
    final l10n = context.l10n;

    // 0. Neu chua dang nhap -> chuyen huong ve Login
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppConfig.loginPath);
        }
      });
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    // 1. Neu dang nap ho so nguoi dung
    if (userProfile == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.home_syncing_permissions,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  ref.read(currentUserProfileProvider.notifier).fetchProfile();
                },
                child: Text(
                  l10n.home_retry,
                  style: TextStyle(color: colors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentIndex = tabIndex.clamp(0, widget.destinations.length - 1);

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          _buildSidebar(context, currentIndex),
          Expanded(
            child: PageView(
              key: widget.pageViewKey,
              controller: widget.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, int selectedIndex) {
    ref.watch(localizationProvider);
    final colors = context.colors;
    final sidebarWidth = _isCollapsed ? 76.0 : 250.0;
    final canReadClubs = ref.hasPermission(Permissions.clubsRead);
    final canReadUsers = ref.hasPermission(Permissions.usersRead);
    final canReadRoles = ref.hasPermission(Permissions.rolesRead);
    final hasAdminSection = canReadClubs || canReadUsers || canReadRoles;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BRAND / LOGO HEADER
          _buildHeader(context),

          // 2. ACTIVE CLUB SELECTOR (FR03 / FR04)
          _buildClubSelector(context),

          const SizedBox(height: AppSpacing.xs),

          // 3. MENU ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              children: [
                // SECTION: CHỨC NĂNG CHÍNH
                if (!_isCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      'ĐIỀU HƯỚNG CHÍNH',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                // 5 Core Destinations
                for (int i = 0; i < widget.destinations.length; i++) ...[
                  _buildNavItem(
                    context,
                    icon: _getIconDataForDestination(i),
                    title: widget.destinations[i].title,
                    isSelected: selectedIndex == i,
                    onTap: () => widget.onTabSelected(i),
                  ),
                ],

                // SECTION: HỆ THỐNG QUẢN TRỊ (Admin Only)
                if (hasAdminSection) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Divider(color: colors.divider, height: 1),
                  ),
                  if (!_isCollapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        'HỆ THỐNG QUẢN TRỊ',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  if (canReadClubs)
                    _buildNavItem(
                      context,
                      icon: Icons.apartment_rounded,
                      title: 'Quản lý Câu lạc bộ',
                      isSelected: false,
                      onTap: () => context.push(AppConfig.clubManagementPath),
                    ),
                  if (canReadUsers)
                    _buildNavItem(
                      context,
                      icon: Icons.people_outline_rounded,
                      title: 'Quản lý Người dùng',
                      isSelected: false,
                      onTap: () => context.push(AppConfig.adminUsersPath),
                    ),
                  if (canReadRoles)
                    _buildNavItem(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Quản lý Vai trò',
                      isSelected: false,
                      onTap: () => context.push(AppConfig.adminRolesPath),
                    ),
                ],
              ],
            ),
          ),

          // 4. FOOTER: VERSION & COLLAPSE TOGGLE
          _buildFooter(context),
        ],
      ),
    );
  }

  IconData _getIconDataForDestination(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_rounded;
      case 1:
        return Icons.groups_rounded;
      case 2:
        return Icons.explore_rounded;
      case 3:
        return Icons.bar_chart_rounded;
      case 4:
        return Icons.settings_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildClubSelector(BuildContext context) {
    final clubContext = ref.watch(clubContextViewModelProvider);
    final activeClubName = clubContext.currentClubName ?? 'Chưa chọn CLB';
    final roleName = clubContext.currentRole?.displayName ?? 'Khách';
    final colors = context.colors;

    if (_isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: IconButton(
          tooltip: '$activeClubName ($roleName)',
          icon: Icon(Icons.sports_tennis_rounded, color: colors.primary),
          onPressed: () => ClubSwitcherDialog.show(context),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => ClubSwitcherDialog.show(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_tennis_rounded,
                color: colors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeClubName,
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    roleName,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.swap_horiz_rounded,
              size: 16,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isCollapsed ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.success, colors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (!_isCollapsed) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'KLTN BADMINTON',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'HỘI NHÓM CẦU LÔNG',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 9.5,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2.5,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: colors.primary.withValues(alpha: 0.1),
        highlightColor: colors.primary.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryContainer : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              if (isSelected)
                Container(
                  width: 3.5,
                  height: 20,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                )
              else if (!_isCollapsed)
                const SizedBox(width: 0),

              Icon(
                icon,
                size: 20,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),

              if (!_isCollapsed) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? colors.primary : colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isCollapsed) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'KLTN Badminton v2.0',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          InkWell(
            onTap: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: _isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    _isCollapsed
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    color: colors.textMuted,
                    size: 18,
                  ),
                  if (!_isCollapsed) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Thu gọn Sidebar',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
