import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/ui/screen/home/tab/settings/widgets/setting_page_shared.dart';
import 'package:sipm_mobile/widget/biometric_settings/biometric_settings_item.dart';
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
          // ── Account ──────────────────────────────────────────
          buildSectionTitle(context, sections[0].title, sections[0].icon),
          const SizedBox(height: 12),
          buildSettingsCard(
            children: sections[0].items
                .map(
                  (item) => buildSettingsItem(
                    context: context,
                    icon: item.icon,
                    color: item.color,
                    title: item.title,
                    subtitle: item.subtitle,
                    onTap: item.onTap,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // ── Security ─────────────────────────────────────────
          buildSectionTitle(context, sections[1].title, sections[1].icon),
          const SizedBox(height: 12),
          buildSettingsCard(
            children: [
              buildSettingsItem(
                context: context,
                icon: sections[1].items[0].icon,
                color: sections[1].items[0].color,
                title: sections[1].items[0].title,
                subtitle: sections[1].items[0].subtitle,
                onTap: sections[1].items[0].onTap,
              ),
              buildDivider(),
              const BiometricSettingsItem(),
            ],
          ),
          const SizedBox(height: 20),

          // ── Configuration ─────────────────────────────────────
          buildSectionTitle(context, sections[2].title, sections[2].icon),
          const SizedBox(height: 12),
          buildSettingsCard(
            children: sections[2].items
                .map(
                  (item) => buildSettingsItem(
                    context: context,
                    icon: item.icon,
                    color: item.color,
                    title: item.title,
                    subtitle: item.subtitle,
                    onTap: item.onTap,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

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
