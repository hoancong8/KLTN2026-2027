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

    // 0. Neu chua dang nhap -> chuyen huong ve Login
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppConfig.loginPath);
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 1. Neu dang nap ho so nguoi dung
    if (userProfile == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Đang đồng bộ phân quyền tài khoản...',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  ref.read(currentUserProfileProvider.notifier).fetchProfile();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final currentIndex = tabIndex.clamp(0, widget.destinations.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BRAND / LOGO HEADER
          _buildHeader(),

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
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                // 5 Core Destinations
                for (int i = 0; i < widget.destinations.length; i++) ...[
                  _buildNavItem(
                    icon: _getIconDataForDestination(i),
                    title: widget.destinations[i].title,
                    isSelected: selectedIndex == i,
                    onTap: () => widget.onTabSelected(i),
                  ),
                ],

                // SECTION: HỆ THỐNG QUẢN TRỊ (Admin Only)
                if (hasAdminSection) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Divider(color: AppColors.border, height: 1),
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
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  if (canReadClubs)
                    _buildNavItem(
                      icon: Icons.apartment_rounded,
                      title: 'Quản lý Câu lạc bộ',
                      isSelected: false,
                      onTap: () => context.push(AppConfig.clubManagementPath),
                    ),
                  if (canReadUsers)
                    _buildNavItem(
                      icon: Icons.people_outline_rounded,
                      title: 'Quản lý Người dùng',
                      isSelected: false,
                      onTap: () => context.push(AppConfig.adminUsersPath),
                    ),
                  if (canReadRoles)
                    _buildNavItem(
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
          _buildFooter(),
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

    if (_isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: IconButton(
          tooltip: '$activeClubName ($roleName)',
          icon: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
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
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => ClubSwitcherDialog.show(context),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: AppColors.primary,
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
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    roleName,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.swap_horiz_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              gradient: const LinearGradient(
                colors: [AppColors.success, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'G',
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
                    'GIG PORTAL',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'QUẢN LÝ CẦU LÔNG',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
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

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2.5,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                )
              else if (!_isCollapsed)
                const SizedBox(width: 0),

              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),

              if (!_isCollapsed) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
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
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'KLTN Mobile v2.0',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
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
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  if (!_isCollapsed) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Thu gọn Sidebar',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
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
