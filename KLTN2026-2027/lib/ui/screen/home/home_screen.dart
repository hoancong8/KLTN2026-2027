import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/ui/screen/home/home_vm/home_vm.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/chat/chat_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_page.dart';
import 'package:kltn2026_2027/ui/screen/home/widgets/home_mobile.dart';
import 'package:kltn2026_2027/ui/screen/home/widgets/home_tablet.dart';

import '../../../widget/responsive_layout.dart';
import 'tab/dashboard/dashboard_page.dart';
import 'tab/settings/settings_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  final GlobalKey _pageViewKey = GlobalKey(debugLabel: 'home_page_view');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(homeTabProvider));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final token = ref.read(authTokenProvider);
      if (token != null) {
        ref
            .read(homeViewModelProvider.notifier)
            .initialize(token.accessToken, token.userId);
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
    ref.read(homeTabProvider.notifier).state = index;

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

    return Theme(
      data: _buildTheme(context),
      child: ResponsiveLayout(
        mobile: HomeMobile(
          pageViewKey: _pageViewKey,
          pageController: _pageController,
          onTabSelected: _onTabSelected,
          pages: pages,
        ),
        tablet: HomeTablet(
          pageViewKey: _pageViewKey,
          pageController: _pageController,
          onTabSelected: _onTabSelected,
          pages: pages,
        ),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final baseTheme = Theme.of(context);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColor.white,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColor.cMain,
        surface: AppColor.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColor.white,
        indicatorColor: AppColor.cMain.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColor.cMain,
            );
          }
          return const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: AppColor.cMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColor.cMain, size: 24);
          }
          return const IconThemeData(color: AppColor.cMuted, size: 24);
        }),
        elevation: 0,
        height: 65,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColor.white,
        indicatorColor: AppColor.cMain.withAlpha(38),
        groupAlignment: -1,
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: AppColor.cMain,
        ),
        unselectedLabelTextStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          color: AppColor.cMuted,
        ),
        selectedIconTheme: const IconThemeData(color: AppColor.cMain, size: 24),
        unselectedIconTheme: const IconThemeData(
          color: AppColor.cMuted,
          size: 24,
        ),
      ),
      dividerColor: AppColor.cDivider,
      cardTheme: CardThemeData(
        color: AppColor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: AppColor.cDivider.withAlpha(100)),
        ),
      ),
    );
  }
}
