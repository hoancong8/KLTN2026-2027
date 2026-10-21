// lib/ui/screen/home/widgets/home_mobile.dart

import 'package:flutter/material.dart';
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

    // 1. Neu dang nap thong tin nguoi dung ban dau
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

    // 2. Index an toan khong vuot qua so luong tab
    final currentIndex = tabIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      backgroundColor: colors.background,
      body: PageView(
        key: pageViewKey,
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.divider, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTabSelected,
          backgroundColor: colors.surface,
          indicatorColor: colors.primaryContainer,
          elevation: 0,
          height: 68,
          destinations: destinations.map((item) {
            return NavigationDestination(
              icon: item.icon,
              selectedIcon: item.selectedIcon,
              label: item.title,
            );
          }).toList(),
        ),
      ),
    );
  }
}
