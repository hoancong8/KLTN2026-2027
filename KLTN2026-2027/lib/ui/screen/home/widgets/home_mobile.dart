import '../tab/dashboard/dashboard_vm/dashboard_vm.dart';
// lib/ui/screen/home/widgets/home_mobile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'home_nav_destination.dart';

class HomeMobile extends ConsumerWidget {
  final PageController pageController;
  final Function(int) onTabSelected;
  final List<Widget> pages;
  final List<HomeNavDestination> destinations;
  final Key? pageViewKey;

  const HomeMobile({
    super.key,
    required this.pageController,
    required this.onTabSelected,
    required this.pages,
    required this.destinations,
    this.pageViewKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final tabIndex = ref.watch(homeTabProvider);
    final colors = context.colors;
    final l10n = context.l10n;

    // 0. Neu chua co token -> dieu huong ve Login
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppConfig.loginPath);
      });
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    // 1. Neu dang nap thong tin nguoi dung ban dau hoac du lieu trang chu
    final dashboardState = ref.watch(dashboardViewModelProvider);
    if (userProfile == null || dashboardState.playerProfile == null) {
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
                  ref.read(dashboardViewModelProvider.notifier).loadData();
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

    // 2. Index an toan khong vuot qua so luong tab
    final currentIndex = tabIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      body: PageView(
        key: pageViewKey,
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildFloatingPillNavBar(context, currentIndex),
      ),
    );
  }

  Widget _buildFloatingPillNavBar(BuildContext context, int currentIndex) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(destinations.length, (index) {
          final isSelected = index == currentIndex;
          final destination = destinations[index];
          return Tooltip(
            message: destination.title,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTabSelected(index);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isSelected ? 48 : 42,
                height: isSelected ? 48 : 42,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : AppColors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(
                      color: isSelected ? AppColors.white : colors.textMuted,
                      size: isSelected ? 22 : 20,
                    ),
                    child: isSelected ? destination.selectedIcon : destination.icon,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

