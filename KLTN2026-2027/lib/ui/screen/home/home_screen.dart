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
    ref.listen<int>(homeTabProvider, (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        if ((next - (previous ?? 0)).abs() > 1) {
          _pageController.jumpToPage(next);
        } else {
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });

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
    final colors = context.colors;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: colors.primary,
        surface: colors.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            );
          }
          return AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 24);
          }
          return IconThemeData(color: colors.textSecondary, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        groupAlignment: -1,
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.primary,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
        selectedIconTheme: IconThemeData(color: colors.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: colors.textSecondary,
          size: 24,
        ),
      ),
      dividerColor: colors.divider,
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          side: BorderSide(color: colors.cardBorder),
        ),
      ),
    );
  }
}
