import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/widget/app_bar/custom_app_bar.dart';
import '../../../../app/provider/localization_provider.dart';
import 'home_shared.dart';

class HomeMobile extends ConsumerWidget {
  final PageController pageController;
  final Function(int) onTabSelected;
  final List<Widget> pages;
  final Key? pageViewKey;

  const HomeMobile({
    super.key,
    required this.pageController,
    required this.onTabSelected,
    required this.pages,
    this.pageViewKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(homeTabProvider);
    final unreadCount = 0; // Get unread count from providers
    ref.watch(localizationProvider);
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: _buildAppBar(context, ref),
      body: PageView(
        key: pageViewKey,
        controller: pageController,
        onPageChanged: (index) {
          if (ref.read(homeTabProvider) != index) {
            ref.read(homeTabProvider.notifier).state = index;
          }
        },
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: tabIndex,
          onDestinationSelected: onTabSelected,
          backgroundColor: AppColor.white,
          indicatorColor: AppColor.cMain.withValues(alpha: 0.15),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.l10n.home,
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                child: const Icon(Icons.message_outlined),
              ),
              selectedIcon: Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                child: const Icon(Icons.message),
              ),
              label: context.l10n.tinNhan,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: context.l10n.report,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.l10n.setting,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    return CustomAppBar(
      showLogo: true,
      backgroundColor: AppColor.white,
      foregroundColor: AppColor.cMain,
      titleSpacing: 0,
      logoSize: 62,
      titleWidget: Row(
        children: [
          const CompanyHeader(),
          const Spacer(),
          IconButton(
            tooltip: context.l10n.search,
            onPressed: () => showSearch(
              context: context,
              delegate: SimpleSearchDelegate(context.l10n),
            ),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: context.l10n.others,
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          buildProfileButton(context),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
