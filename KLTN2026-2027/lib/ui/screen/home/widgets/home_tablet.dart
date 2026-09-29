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
import '../../admin/role_management/role_management_screen.dart';
import '../../admin/user_management/user_management_screen.dart';
import '../../../../app/provider/localization_provider.dart';

/// Model định nghĩa từng mục Menu Navigation kèm Quyền & Màn hình
class NavigationItem {
  final String title;
  final IconData icon;
  final String? permission; // null = public, hoặc chuỗi quyền cụ thể
  final Widget page;
  final String? badge;
  final Color? badgeColor;

  const NavigationItem({
    required this.title,
    required this.icon,
    this.permission,
    required this.page,
    this.badge,
    this.badgeColor,
  });
}

class HomeTablet extends ConsumerStatefulWidget {
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
  ConsumerState<HomeTablet> createState() => _HomeTabletState();
}

class _HomeTabletState extends ConsumerState<HomeTablet> {
  bool _isCollapsed = false;
  int _activeItemIndex = 0;

  /// Toàn bộ danh mục Menu hệ thống
  List<NavigationItem> _getAllNavItems(int unreadCount) {
    return [
      const NavigationItem(
        title: 'Dashboard',
        icon: Icons.grid_view_rounded,
        permission: Permissions.dashboardView,
        page: DashboardPage(),
      ),
      NavigationItem(
        title: 'Quản lý Đối tác',
        icon: Icons.storefront_outlined,
        permission: Permissions.venuesRead,
        badge: '2',
        badgeColor: AppColor.cNeedCheck,
        page: const SettingsPage(),
      ),
      NavigationItem(
        title: 'Khiếu nại Đối tác',
        icon: Icons.error_outline_rounded,
        permission: Permissions.venuesRead,
        badge: '3',
        badgeColor: AppColor.cAlert,
        page: const SettingsPage(),
      ),
      const NavigationItem(
        title: 'Quản lý Người dùng',
        icon: Icons.people_outline_rounded,
        permission: Permissions.usersRead,
        page: UserManagementScreen(),
      ),
      const NavigationItem(
        title: 'Quản lý vai trò',
        icon: Icons.shield_outlined,
        permission: Permissions.rolesRead,
        page: RoleManagementScreen(),
      ),
      const NavigationItem(
        title: 'Thống kê Nền tảng',
        icon: Icons.bar_chart_rounded,
        permission: Permissions.courtPricingsRead,
        page: ReportPage(),
      ),
      NavigationItem(
        title: 'Trung tâm Thông báo',
        icon: Icons.notifications_none_rounded,
        permission: 'Chat.Read',
        badge: unreadCount > 0 ? '$unreadCount' : '3',
        badgeColor: AppColor.cMain,
        page: const ChatPage(),
      ),
      const NavigationItem(
        title: 'Hồ sơ Super Admin',
        icon: Icons.person_outline_rounded,
        permission: 'Settings.Read',
        page: SettingsPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(authTokenProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final userPerms = ref.watch(userPermissionsProvider);
    final unreadCount = 0; // Get unread count from providers

    // 0. Nếu token không tồn tại (chưa đăng nhập hoặc session mất) -> chuyển về Login
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppConfig.loginPath);
        }
      });
      return const Scaffold(
        backgroundColor: AppColor.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColor.cMain),
        ),
      );
    }

    // 1. Nếu đang trong quá trình nạp thông tin User Profile ban đầu
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

    // 2. Lọc danh sách item theo quyền của người dùng hiện tại
    final allItems = _getAllNavItems(unreadCount);
    final accessibleItems = allItems.where((item) {
      if (item.permission == null || item.permission!.isEmpty) return true;
      return userPerms.contains(item.permission);
    }).toList();

    // 3. Nếu User KHÔNG CÓ BẤT KỲ QUYỀN NÀO -> Hiển thị Màn hình 403 Access Denied
    if (accessibleItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: Row(
          children: [
            _buildSidebar(context, [], 0, unreadCount),
            Expanded(
              child: _buildAccessDeniedScreen(context),
            ),
          ],
        ),
      );
    }

    // 3. Đảm bảo index đang chọn không vượt quá số lượng item có quyền
    final currentIndex = _activeItemIndex.clamp(0, accessibleItems.length - 1);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Row(
        children: [
          _buildSidebar(context, accessibleItems, currentIndex, unreadCount),
          Expanded(
            child: PageView(
              key: widget.pageViewKey,
              controller: widget.pageController,
              onPageChanged: (index) {
                if (_activeItemIndex != index) {
                  setState(() => _activeItemIndex = index);
                }
              },
              children: accessibleItems.map((item) => item.page).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    List<NavigationItem> items,
    int selectedIndex,
    int unreadCount,
  ) {
    ref.watch(localizationProvider);
    final sidebarWidth = _isCollapsed ? 76.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColor.white,
        border: Border(right: BorderSide(color: AppColor.cDivider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BRAND / LOGO HEADER
          _buildHeader(),

          const SizedBox(height: 12),

          // 2. SECTION TITLE
          if (!_isCollapsed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'HỆ THỐNG QUẢN TRỊ',
                style: TextStyle(
                  color: AppColor.cMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),

          // 3. DYNAMIC MENU ITEMS
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _isCollapsed ? '' : 'Không có chức năng khả dụng',
                        style: const TextStyle(
                          color: AppColor.cMuted,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildMenuItem(
                        icon: item.icon,
                        title: item.title,
                        badge: item.badge,
                        badgeColor: item.badgeColor,
                        isSelected: selectedIndex == index,
                        onTap: () {
                          setState(() => _activeItemIndex = index);
                          if (widget.pageController.hasClients) {
                            widget.pageController.jumpToPage(index);
                          }
                        },
                      );
                    },
                  ),
          ),

          // 4. FOOTER: VERSION & COLLAPSE TOGGLE
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isCollapsed ? 16 : 18,
        vertical: 18,
      ),
      child: Row(
        children: [
          // Green Brand Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.cGreen_50, AppColor.cMain],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColor.cMain.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: AppColor.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (!_isCollapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GIG PORTAL',
                    style: TextStyle(
                      color: AppColor.cTitle,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'SPORTS MANAGEMENT',
                    style: TextStyle(
                      color: AppColor.cMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColor.cMain.withValues(alpha: 0.1),
        highlightColor: AppColor.cMain.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColor.cChip : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Left Active Indicator Bar
              if (isSelected)
                Container(
                  width: 3.5,
                  height: 20,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColor.cMain,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )
              else if (!_isCollapsed)
                const SizedBox(width: 0),

              // Icon
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColor.cMain : AppColor.cMuted,
              ),

              // Title Text
              if (!_isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColor.cMain : AppColor.cTitle,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColor.cMain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: AppColor.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Màn hình thông báo 403 Forbidden khi không có bất kỳ quyền nào
  Widget _buildAccessDeniedScreen(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.cAlert.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 40,
                color: AppColor.cAlert,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Tài khoản của bạn chưa được cấp quyền truy cập vào bất kỳ chức năng nào trong hệ thống.\nVui lòng liên hệ Quản trị viên để được phân quyền.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColor.cMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cAlert,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColor.cDivider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isCollapsed) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColor.cMain,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'GIG Platform v2.4',
                    style: TextStyle(
                      color: AppColor.cMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          InkWell(
            onTap: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: _isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    _isCollapsed
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    color: AppColor.cMuted,
                    size: 18,
                  ),
                  if (!_isCollapsed) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Thu gọn Sidebar',
                      style: TextStyle(
                        color: AppColor.cMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
