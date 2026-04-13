import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/ui/screen/home/tab/settings/widgets/setting_page_mobile.dart';
import 'package:sipm_mobile/ui/screen/home/tab/settings/widgets/setting_page_tablet.dart';
import 'package:sipm_mobile/widget/responsive_layout.dart';
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
            backgroundColor: AppColor.cError,
          ),
        );
      }
    });

    return Scaffold(
      appBar: _SettingsAppBar(context),
      body: const ResponsiveLayout(
        mobile: SettingsPageMobile(),
        tablet: SettingsPageTablet(),
      ),
    );
  }

  PreferredSizeWidget _SettingsAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        color: AppColor.white,
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
            Divider(height: 1, color: AppColor.cDivider),
          ],
        ),
      ),
    );
  }
}