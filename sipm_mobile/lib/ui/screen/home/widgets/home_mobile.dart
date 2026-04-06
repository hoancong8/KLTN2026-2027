import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/widget/app_bar/custom_app_bar.dart';
import 'home_shared.dart';

class HomeMobile extends ConsumerWidget {
  final PageController pageController;
  final Function(int) onTabSelected;
  final List<Widget> pages;

  const HomeMobile({
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
      appBar: _buildAppBar(context),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          ref.read(homeTabProvider.notifier).state = index;
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
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            const NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Dự án',
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
              label: 'Tin nhắn',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Báo cáo',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
            tooltip: 'Tìm kiếm',
            onPressed:
                () => showSearch(context: context, delegate: SimpleSearchDelegate()),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Thông báo',
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