import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/widgets/setting_page_shared.dart';
import 'package:kltn2026_2027/widget/biometric_settings/biometric_settings_item.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../settings_vm/settings_vm.dart';

class SettingsPageMobile extends ConsumerWidget {
  const SettingsPageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final sections = buildSettingsSections(
      context,
      ref,
      isLoading: state.isLoading,
    );

    return RefreshIndicator(
      color: AppColor.cMain,
      backgroundColor: AppColor.white,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Render tất cả các section một cách động
          for (final section in sections) ...[
            buildSectionTitle(context, section.title, section.icon),
            const SizedBox(height: 12),
            buildSettingsCard(
              children: [
                for (int i = 0; i < section.items.length; i++) ...[
                  if (i > 0) buildDivider(),
                  buildSettingsItem(
                    context: context,
                    icon: section.items[i].icon,
                    color: section.items[i].color,
                    title: section.items[i].title,
                    subtitle: section.items[i].subtitle,
                    onTap: section.items[i].onTap,
                  ),
                ],
                // Nếu là mục Bảo mật (Security), thêm mục Sinh trắc học vào cuối card
                if (section.title == context.l10n.set_security) ...[
                  buildDivider(),
                  const BiometricSettingsItem(),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ── Others / Logout ───────────────────────────────────
          buildSectionTitle(context, context.l10n.set_others, Icons.more_horiz),
          const SizedBox(height: 12),
          buildLogoutCard(context, ref, state.isLoading),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
