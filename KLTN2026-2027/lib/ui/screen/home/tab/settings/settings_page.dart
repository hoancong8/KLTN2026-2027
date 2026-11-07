import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/widgets/setting_page_mobile.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/widgets/setting_page_tablet.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import 'settings_vm/settings_vm.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(settingsViewModelProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: context.colors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: const SafeArea(
        top: true,
        bottom: false,
        child: ResponsiveLayout(
          mobile: SettingsPageMobile(),
          tablet: SettingsPageTablet(),
        ),
      ),
    );
  }
}
