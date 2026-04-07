import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/widget/biometric_settings/biometric_settings_item.dart';
import '../../../../../app/provider/localization_provider.dart';
import 'settings_vm/settings_vm.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final currentLocale = ref.watch(localizationProvider);

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
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.l10n.account, Icons.person_outline),
          const SizedBox(height: 12),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.person_outline,
                color: AppColor.cMain,
                title: context.l10n.account,
                subtitle: context.l10n.accountsubtitle,
                onTap: () {
                  context.push(AppConfig.profilePath);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.l10n.security, Icons.security_outlined),
          const SizedBox(height: 12),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.lock_outline,
                color: AppColor.cYanPrimary,
                title: context.l10n.changepassword,
                subtitle: context.l10n.passwordsubtitle,
                onTap: () {
                  context.push(AppConfig.changePasswordPath);
                },
              ),
              _buildDivider(),
              const BiometricSettingsItem(),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.l10n.configuration, Icons.settings_suggest_outlined),
          const SizedBox(height: 12),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.language,
                color: Colors.orange,
                title: context.l10n.language,
                subtitle: currentLocale.languageCode == 'vi' ? context.l10n.vietnamese : context.l10n.english,
                onTap: () => _showLanguageBottomSheet(context, ref, currentLocale),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, context.l10n.others, Icons.more_horiz),
          const SizedBox(height: 12),
          _buildLogoutCard(context, ref, state.isLoading),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(
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
                        child: const Icon(Icons.language, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        context.l10n.language,
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
                  _buildLanguageSelectionItem(
                    label: context.l10n.vietnamese,
                    flag: '🇻🇳',
                    isSelected: selectedLocale == 'vi',
                    onTap: () => setState(() => selectedLocale = 'vi'),
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageSelectionItem(
                    label: context.l10n.english,
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
                            context.l10n.cancel,
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
                            context.l10n.save,
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

  Widget _buildLanguageSelectionItem({
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
          color: isSelected ? AppColor.cMain.withValues(alpha: 0.05) : Colors.grey[50],
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
              const Icon(Icons.circle_outlined, color: AppColor.cDivider, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.cMain.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings_outlined, color: AppColor.cMain, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.setting,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColor.cTitle,
                ),
              ),
              Text(
                context.l10n.systemconfig,
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
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

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                        color: AppColor.cTitle,
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
              Icon(Icons.chevron_right, color: AppColor.cMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColor.cDivider),
    );
  }

  Widget _buildLogoutCard(BuildContext context, WidgetRef ref, bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () async {
                  final success = await ref
                      .read(settingsViewModelProvider.notifier)
                      .logout();
                  if (success && context.mounted) {
                    context.go(AppConfig.loginPath);
                  }
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.cError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout, color: AppColor.cError, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading ? context.l10n.loggingout : context.l10n.logout,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColor.cError,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.logoutsubtitle,
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.cError,
                      ),
                    ),
                  )
                else
                  Icon(Icons.chevron_right, color: AppColor.cMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
