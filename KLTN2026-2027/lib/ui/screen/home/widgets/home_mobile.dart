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
    ref.watch(localizationProvider);

    // 0. Neu chua co token -> dieu huong ve Login
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppConfig.loginPath);
      });
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 1. Neu dang nap thong tin nguoi dung ban dau
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

    // 2. Index an toan khong vuot qua so luong tab
    final currentIndex = tabIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        key: pageViewKey,
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTabSelected,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryContainer,
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
