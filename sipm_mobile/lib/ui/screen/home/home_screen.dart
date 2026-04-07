import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/ui/screen/home/home_vm/home_vm.dart';
import 'package:sipm_mobile/ui/screen/home/tab/chat/chat_page.dart';
import 'package:sipm_mobile/ui/screen/home/tab/chat/chat_vm/chat_vm.dart';
import 'package:sipm_mobile/ui/screen/home/tab/report/report_page.dart';
import 'package:sipm_mobile/ui/screen/home/widgets/home_mobile.dart';
import 'package:sipm_mobile/ui/screen/home/widgets/home_tablet.dart';
import 'package:sipm_mobile/ui/screen/profile/profile_screen.dart';
import 'package:sipm_mobile/widget/app_bar/custom_app_bar.dart';

import '../../../widget/responsive_layout.dart';
import 'tab/dashboard/dashboard_page.dart';
import 'tab/settings/settings_page.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(homeTabProvider));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final token = ref.read(authTokenProvider);
      if (token != null) {
        ref.read(homeViewModelProvider.notifier).initialize(
          token.accessToken,
          token.userId,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    final currentIndex = ref.read(homeTabProvider);
    ref
        .read(homeTabProvider.notifier)
        .state = index;

    // Nếu khoảng cách > 1 tab, dùng jumpToPage để không chạy qua các tab ở giữa
    if ((index - currentIndex).abs() > 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const ChatPage(),
      const ReportPage(),
      const SettingsPage(),
    ];

    return ResponsiveLayout(
      mobile: HomeMobile(
        pageController: _pageController,
        onTabSelected: _onTabSelected,
        pages: pages,
      ),
      tablet: HomeTablet(
        pageController: _pageController,
        onTabSelected: _onTabSelected,
        pages: pages,
      ),
    );
  }
}



