import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/home/widgets/home_mobile.dart';
import 'package:kltn2026_2027/ui/screen/home/widgets/home_nav_destination.dart';
import 'package:kltn2026_2027/ui/screen/home/widgets/home_tablet.dart';
import '../../../widget/responsive_layout.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Tự động tải thông tin user & permissions nếu Riverpod chưa có
      if (ref.read(currentUserProfileProvider) == null) {
        await ref.read(currentUserProfileProvider.notifier).fetchProfile();
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

    if (!_pageController.hasClients) return;

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
    final destinations = getHomeNavDestinations(context);
    final pages = destinations.map((d) => d.page).toList();

    return Theme(
      data: _buildTheme(context),
      child: ResponsiveLayout(
        mobile: HomeMobile(
          pageViewKey: _pageViewKey,
          pageController: _pageController,
          onTabSelected: _onTabSelected,
          pages: pages,
          destinations: destinations,
        ),
        tablet: HomeTablet(
          pageViewKey: _pageViewKey,
          pageController: _pageController,
          onTabSelected: _onTabSelected,
          pages: pages,
          destinations: destinations,
        ),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final baseTheme = Theme.of(context);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        groupAlignment: -1,
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        selectedIconTheme: const IconThemeData(color: AppColors.primary, size: 24),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),
      dividerColor: AppColors.border,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
