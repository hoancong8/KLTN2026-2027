import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/ui/screen/home/home_screen.dart';
import 'package:sipm_mobile/widget/app_bar/custom_app_bar.dart';
import '../../../../app/provider/localization_provider.dart';
import 'home_shared.dart';

class HomeTablet extends ConsumerWidget {
  final PageController pageController;
  final Function(int) onTabSelected;
  final List<Widget> pages;

  const HomeTablet({
    super.key,
    required this.pageController,
    required this.onTabSelected,
    required this.pages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(homeTabProvider);
    final unreadCount = 0; // TODO: Get unread count from providers

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: _buildAppBar(context, ref),
      body: Row(
        children: [
          _buildNavigationRail(context, ref, tabIndex, unreadCount),
          const VerticalDivider(thickness: 1, width: 1, color: AppColor.cDivider),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                ref.read(homeTabProvider.notifier).state = index;
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
            label: Text(context.l10n.home),
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
          label: Text(context.l10n.tinNhan),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: Text(context.l10n.report),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(context.l10n.setting),
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
            tooltip: context.l10n.search,
            onPressed:
                () => showSearch(context: context, delegate: SimpleSearchDelegate(context.l10n)),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: context.l10n.others, // TODO: Add key for notifications
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