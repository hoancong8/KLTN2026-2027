import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/widgets/setting_page_mobile.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/widgets/setting_page_tablet.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
import 'settings_vm/settings_vm.dart';
import 'widgets/setting_page_shared.dart';
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
      appBar: _buildSettingsAppBar(context),
      body: const ResponsiveLayout(
        mobile: SettingsPageMobile(),
        tablet: SettingsPageTablet(),
      ),
    );
  }

  PreferredSizeWidget _buildSettingsAppBar(BuildContext context) {
    final colors = context.colors;
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        color: colors.surface,
        child: Column(
          children: [
            // Safe area top padding
            SizedBox(height: MediaQuery.of(context).padding.top),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: buildSettingsHeader(context),
              ),
            ),
            Divider(height: 1, color: colors.divider),
          ],
        ),
      ),
    );
  }
}
