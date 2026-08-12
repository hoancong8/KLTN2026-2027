import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/widget/app_bar/custom_app_bar.dart';
import '../../../../app/provider/localization_provider.dart';
import 'home_shared.dart';

class HomeTablet extends ConsumerWidget {
  final PageController pageController;
  final Function(int) onTabSelected;
  final List<Widget> pages;
  final Key? pageViewKey;

  const HomeTablet({
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

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: tabIndex == 0 ? null : _buildAppBar(context, ref),
      body: Row(
        children: [
          _buildNavigationRail(context, ref, tabIndex, unreadCount),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: AppColor.cDivider,
          ),
          Expanded(
            child: PageView(
              key: pageViewKey,
              controller: pageController,
              onPageChanged: (index) {
                if (ref.read(homeTabProvider) != index) {
                  ref.read(homeTabProvider.notifier).state = index;
                }
              },
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail(
    BuildContext context,
    WidgetRef ref,
    int tabIndex,
    int unreadCount,
  ) {
    ref.watch(localizationProvider);
    return NavigationRail(
      selectedIndex: tabIndex,
      onDestinationSelected: onTabSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: AppColor.white,
      indicatorColor: AppColor.cMain.withValues(alpha: 0.15),
      groupAlignment: -0.9,
      minWidth: 90,
      selectedLabelTextStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: AppColor.cMain,
      ),
      unselectedLabelTextStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: AppColor.cMuted,
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(context.l10n.com_home),
        ),
        NavigationRailDestination(
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
          label: Text(context.l10n.chat_messages),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: Text(context.l10n.set_report),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(context.l10n.set_title),
        ),
      ],
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
            tooltip: context.l10n.com_search,
            onPressed: () => showSearch(
              context: context,
              delegate: SimpleSearchDelegate(context.l10n),
            ),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: context.l10n.set_others,
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
