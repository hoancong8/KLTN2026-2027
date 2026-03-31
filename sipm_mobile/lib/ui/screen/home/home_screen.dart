import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/ui/screen/home/home_vm/home_vm.dart';
import 'package:sipm_mobile/ui/screen/home/tab/chat/chat_page.dart';
import 'package:sipm_mobile/ui/screen/home/tab/chat/chat_vm/chat_vm.dart';
import 'package:sipm_mobile/ui/screen/home/tab/report/report_page.dart';
import 'package:sipm_mobile/ui/screen/profile/profile_screen.dart';
import 'package:sipm_mobile/widget/app_bar/custom_app_bar.dart';

import 'tab/dashboard/dashboard_page.dart';
import 'tab/settings/settings_page.dart';

// Provider for current tab index
final homeTabProvider = StateProvider<int>((ref) => 0);

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

  void _onPageChanged(int index) {
    ref.read(homeTabProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(homeTabProvider);
    final chatState = ref.watch(chatViewModelProvider);
    final unreadCount = chatState.unreadUsersCount;

    return Theme(
      data: _buildTheme(context),
      child: Scaffold(
        // drawer: _AppDrawer(onTabSelected: _onTabSelected),
        appBar: _buildAppBar(context),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            DashboardPage(),
            ChatPage(),
            ReportPage(),
            SettingsPage(),
          ],
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
            onDestinationSelected: _onTabSelected,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Trang chủ',
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
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: AppColor.white,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColor.cMain,
        secondary: AppColor.cMain,
        surface: AppColor.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.cMain,
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: const IconThemeData(color: AppColor.cMain),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColor.white,
        indicatorColor: AppColor.cMain.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: AppColor.cMain,
            );
          }
          return const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
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
      dividerColor: AppColor.cDivider,
      cardTheme: const CardThemeData(
        color: AppColor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: AppColor.cDivider),
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
          const _CompanyHeader(),
          const Spacer(),
          IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () => showSearch(context: context, delegate: _SimpleSearchDelegate()),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.cDivider),
              ),
              child: const Icon(Icons.person, size: 18),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project TPV',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColor.cTitle),
        ),
        Text('Công ty mẹ', style: t.bodySmall?.copyWith(color: AppColor.cMuted)),
      ],
    );
  }
}

class _SimpleSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(onPressed: () {
      query = '';
    }, icon: const Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: () {
      close(context, '');
    }, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Ket qua cho: $query', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final source = const ['Home', 'Projects', 'Finance', 'Report', 'Settings'];
    final suggestions = source.where((e) {
      return e.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestions[i]),
          onTap: () {
            query = suggestions[i];
            showResults(context);
          },
        );
      },
    );
  }
}
