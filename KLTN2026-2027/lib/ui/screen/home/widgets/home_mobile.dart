import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/ui/screen/home/home_vm/home_vm.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/chat/chat_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/dashboard/dashboard_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/settings_page.dart';
import '../../../../app/provider/localization_provider.dart';

/// Model định nghĩa từng mục Menu Navigation Mobile kèm Quyền & Màn hình
class _MobileNavigationItem {
  final String title;
  final Widget icon;
  final Widget selectedIcon;
  final String? permission;
  final Widget page;

  const _MobileNavigationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.permission,
    required this.page,
  });
}

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

  List<_MobileNavigationItem> _getAllNavItems(
    BuildContext context,
    int unreadCount,
  ) {
    return [
      _MobileNavigationItem(
        title: context.l10n.com_home,
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        permission: Permissions.dashboardView,
        page: const DashboardPage(),
      ),
      _MobileNavigationItem(
        title: context.l10n.chat_messages,
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
        permission: 'Chat.Read',
        page: const ChatPage(),
      ),
      _MobileNavigationItem(
        title: context.l10n.set_report,
        icon: const Icon(Icons.bar_chart_outlined),
        selectedIcon: const Icon(Icons.bar_chart),
        permission: Permissions.courtPricingsRead,
        page: const ReportPage(),
      ),
      _MobileNavigationItem(
        title: context.l10n.set_title,
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        permission: Permissions.courtPricingsRead,
        page: const SettingsPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final userPerms = ref.watch(userPermissionsProvider);
    final tabIndex = ref.watch(homeTabProvider);
    final unreadCount = 0; // Get unread count from providers
    ref.watch(localizationProvider);

    // 0. Nếu token không tồn tại -> chuyển hướng về Login
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppConfig.loginPath);
      });
      return const Scaffold(
        backgroundColor: AppColor.white,
        body: Center(child: CircularProgressIndicator(color: AppColor.cMain)),
      );
    }

    // 1. Nếu đang nạp User Profile lần đầu
    if (userProfile == null) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColor.cMain),
              const SizedBox(height: 16),
              const Text(
                'Đang đồng bộ phân quyền tài khoản...',
                style: TextStyle(color: AppColor.cMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
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

    // 2. Lọc danh sách Navigation Item theo quyền của người dùng
    final allItems = _getAllNavItems(context, unreadCount);
    final accessibleItems = allItems.where((item) {
      if (item.permission == null || item.permission!.isEmpty) return true;
      return userPerms.contains(item.permission);
    }).toList();

    // 3. Nếu không có bất kỳ quyền nào -> Hiển thị Màn hình 403 Access Denied
    if (accessibleItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: _buildAccessDeniedScreen(context, ref),
      );
    }

    // 4. Nếu chỉ có duy nhất 1 quyền -> Hiển thị trực tiếp màn hình đó (ẩn NavigationBar vì Flutter yêu cầu >= 2 destinations)
    if (accessibleItems.length == 1) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: accessibleItems.first.page,
      );
    }

    // 5. Đảm bảo index an toàn không vượt quá số lượng item được phép
    final currentIndex = tabIndex.clamp(0, accessibleItems.length - 1);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: PageView(
        key: pageViewKey,
        controller: pageController,
        onPageChanged: (index) {
          if (ref.read(homeTabProvider) != index) {
            ref.read(homeTabProvider.notifier).state = index;
          }
        },
        children: accessibleItems.map((e) => e.page).toList(),
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
          selectedIndex: currentIndex,
          onDestinationSelected: onTabSelected,
          backgroundColor: AppColor.white,
          indicatorColor: AppColor.cMain.withValues(alpha: 0.15),
          destinations: accessibleItems.map((item) {
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

  Widget _buildAccessDeniedScreen(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không có quyền truy cập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.cTitle,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tài khoản của bạn chưa được cấp quyền truy cập bất kỳ tính năng nào trên hệ thống. Vui lòng liên hệ Quản trị viên để được cấp quyền.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.cMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cMain,
                foregroundColor: AppColor.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
