import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/club/my_clubs_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/dashboard/dashboard_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/explore/explore_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/report_page.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/settings_page.dart';

class HomeNavDestination {
  final String title;
  final Widget icon;
  final Widget selectedIcon;
  final Widget page;

  const HomeNavDestination({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}

List<HomeNavDestination> getHomeNavDestinations(BuildContext context) {
  final l10n = context.l10n;

  return [
    HomeNavDestination(
      title: l10n.nav_home,
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard_rounded),
      page: const DashboardPage(),
    ),
    HomeNavDestination(
      title: l10n.nav_clubs,
      icon: const Icon(Icons.groups_outlined),
      selectedIcon: const Icon(Icons.groups_rounded),
      page: const MyClubsPage(),
    ),
    HomeNavDestination(
      title: l10n.nav_explore,
      icon: const Icon(Icons.explore_outlined),
      selectedIcon: const Icon(Icons.explore_rounded),
      page: const ExplorePage(),
    ),
    HomeNavDestination(
      title: l10n.nav_report,
      icon: const Icon(Icons.bar_chart_outlined),
      selectedIcon: const Icon(Icons.bar_chart_rounded),
      page: const ReportPage(),
    ),
    HomeNavDestination(
      title: l10n.nav_settings,
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings_rounded),
      page: const SettingsPage(),
    ),
  ];
}
