import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../settings_vm/settings_vm.dart';

class SettingsSection {
  final String title;
  final IconData icon;
  final List<SettingsItemData> items;

  const SettingsSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class SettingsItemData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;
  final Widget? trailing; // custom trailing (e.g. BiometricSettingsItem)

  const SettingsItemData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
    this.trailing,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED BUILDER: builds the sections list from context + ref
// ─────────────────────────────────────────────────────────────────────────────
List<SettingsSection> buildSettingsSections(
  BuildContext context,
  WidgetRef ref, {
  required bool isLoading,
}) {
  final currentLocale = ref.watch(localizationProvider);

  return [
    SettingsSection(
      title: context.l10n.set_account,
      icon: Icons.person_outline,
      items: [
        SettingsItemData(
          icon: Icons.person_outline,
          color: AppColor.cMain,
          title: context.l10n.set_account,
          subtitle: context.l10n.set_account_subtitle,
          onTap: () => context.push(AppConfig.profilePath),
        ),
      ],
    ),
    SettingsSection(
      title: context.l10n.set_security,
      icon: Icons.security_outlined,
      items: [
        SettingsItemData(
          icon: Icons.lock_outline,
          color: AppColor.cYanPrimary,
          title: context.l10n.auth_change_password,
          subtitle: context.l10n.set_password_subtitle,
          onTap: () => context.push(AppConfig.changePasswordPath),
        ),
        // BiometricSettingsItem is handled inline — see buildSettingsItemWidget
      ],
    ),
    SettingsSection(
      title: context.l10n.set_config,
      icon: Icons.settings_suggest_outlined,
      items: [
        SettingsItemData(
          icon: Icons.language,
          color: Colors.orange,
          title: context.l10n.set_language,
          subtitle: currentLocale.languageCode == 'vi'
              ? context.l10n.set_vietnamese
              : context.l10n.set_english,
          onTap: () => showLanguageBottomSheet(context, ref, currentLocale),
        ),
      ],
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Header: icon + "Setting / System & Account Configuration"
Widget buildSettingsHeader(BuildContext context) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.cMain.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.settings_outlined,
          color: AppColor.cMain,
          size: 24,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.set_title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColor.cTitle,
              ),
            ),
            Text(
              context.l10n.set_system_config,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColor.cMuted),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Section title row: icon + label
Widget buildSectionTitle(BuildContext context, String title, IconData icon) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.cMain.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColor.cMain, size: 18),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColor.cTitle,
        ),
      ),
    ],
  );
}

/// Card container
Widget buildSettingsCard({required List<Widget> children}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.cDivider),
    ),
    child: Column(children: children),
  );
}

/// Single settings row item
Widget buildSettingsItem({
  required BuildContext context,
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Widget? customTrailing,
  bool isLoading = false,
  bool isDestructive = false,
}) {
  final titleColor = isDestructive ? AppColor.cError : AppColor.cTitle;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColor.cMuted),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              customTrailing ??
                  Icon(Icons.chevron_right, color: AppColor.cMuted),
          ],
        ),
      ),
    ),
  );
}

Widget buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, color: AppColor.cDivider),
  );
}

/// Logout card
Widget buildLogoutCard(BuildContext context, WidgetRef ref, bool isLoading) {
  return buildSettingsCard(
    children: [
      buildSettingsItem(
        context: context,
        icon: Icons.logout,
        color: AppColor.cError,
        title: isLoading
            ? context.l10n.auth_logging_out
            : context.l10n.auth_logout,
        subtitle: context.l10n.set_logout_subtitle,
        isDestructive: true,
        isLoading: isLoading,
        onTap: () async {
          final success = await ref
              .read(settingsViewModelProvider.notifier)
              .logout();
          if (success && context.mounted) {
            context.go(AppConfig.loginPath);
          }
        },
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE BOTTOM SHEET  (shared)
// ─────────────────────────────────────────────────────────────────────────────
void showLanguageBottomSheet(
  BuildContext context,
  WidgetRef ref,
  Locale currentLocale,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      String selectedLocale = currentLocale.languageCode;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      context.l10n.set_language,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColor.cTitle,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColor.cMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLanguageOption(
                  label: context.l10n.set_vietnamese,
                  flag: '🇻🇳',
                  isSelected: selectedLocale == 'vi',
                  onTap: () => setState(() => selectedLocale = 'vi'),
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  label: context.l10n.set_english,
                  flag: '🇺🇸',
                  isSelected: selectedLocale == 'en',
                  onTap: () => setState(() => selectedLocale = 'en'),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppColor.cDivider),
                        ),
                        child: Text(
                          context.l10n.com_cancel,
                          style: const TextStyle(
                            color: AppColor.cTitle,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(localizationProvider.notifier)
                              .changeLocale(selectedLocale);
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cMain,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.com_save,
                          style: const TextStyle(
                            color: AppColor.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildLanguageOption({
  required String label,
  required String flag,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColor.cMain.withValues(alpha: 0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColor.cMain : AppColor.cDivider,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColor.cMain : AppColor.cTitle,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColor.cMain, size: 24)
          else
            const Icon(
              Icons.circle_outlined,
              color: AppColor.cDivider,
              size: 24,
            ),
        ],
      ),
    ),
  );
}
