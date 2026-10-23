import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/app/consts/permissions.dart';
import 'package:kltn2026_2027/app/provider.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../../../../../../widget/club_switcher_dialog.dart';
import '../../../../club/club_vm/club_context_vm.dart';
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
  final canReadUsers = ref.hasPermission(Permissions.usersRead);
  final canReadRoles = ref.hasPermission(Permissions.rolesRead);
  final clubContext = ref.watch(clubContextViewModelProvider);

  return [
    SettingsSection(
      title: 'Câu lạc bộ cầu lông',
      icon: Icons.sports_tennis_rounded,
      items: [
        SettingsItemData(
          icon: Icons.swap_horiz_rounded,
          color: AppColors.roleSky,
          title: clubContext.currentClubName != null
              ? 'Đang chọn: ${clubContext.currentClubName}'
              : 'Chọn câu lạc bộ hoạt động',
          subtitle: clubContext.currentRole != null
              ? 'Vai trò hiện tại: ${clubContext.currentRole!.displayName}'
              : 'Chuyển đổi nhóm và đồng bộ vai trò/quyền hạn',
          onTap: () => ClubSwitcherDialog.show(context),
        ),
        SettingsItemData(
          icon: Icons.groups_outlined,
          color: AppColors.roleMember,
          title: 'Quản lý thành viên & vai trò',
          subtitle: 'Xem danh sách thành viên và phân quyền trong nhóm',
          onTap: () => context.push(AppConfig.clubManagementPath),
        ),
      ],
    ),
    SettingsSection(
      title: context.l10n.set_account,
      icon: Icons.person_outline,
      items: [
        SettingsItemData(
          icon: Icons.person_outline,
          color: context.colors.primary,
          title: context.l10n.set_account,
          subtitle: context.l10n.set_account_subtitle,
          onTap: () => context.push(AppConfig.profilePath),
        ),
      ],
    ),
    
    if (canReadUsers || canReadRoles)
      SettingsSection(
        title: 'Quản trị hệ thống',
        icon: Icons.admin_panel_settings_outlined,
        items: [
          if (canReadUsers)
            SettingsItemData(
              icon: Icons.people_outline,
              color: AppColors.navyDark,
              title: 'Quản lý nhân viên',
              subtitle: 'Xem, thêm, sửa, phân quyền tài khoản',
              onTap: () => context.push(AppConfig.adminUsersPath),
            ),
          if (canReadRoles)
            SettingsItemData(
              icon: Icons.shield_outlined,
              color: AppColors.roleViolet,
              title: 'Quản lý vai trò',
              subtitle: 'Xem và cấu hình nhóm quyền hạn',
              onTap: () => context.push(AppConfig.adminRolesPath),
            ),
        ],
      ),
    SettingsSection(
      title: context.l10n.set_security,
      icon: Icons.security_outlined,
      items: [
        SettingsItemData(
          icon: Icons.lock_outline,
          color: context.colors.primaryLight,
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
          color: AppColors.accentDark,
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
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.settings_outlined,
          color: context.colors.primary,
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
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              context.l10n.set_system_config,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
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
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: context.colors.primary, size: 18),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    ],
  );
}

/// Card container
Widget buildSettingsCard({BuildContext? context, required List<Widget> children}) {
  return Builder(
    builder: (ctx) {
      final colors = ctx.colors;
      return Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(children: children),
      );
    },
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
  final colors = context.colors;
  final titleColor = isDestructive ? colors.error : colors.textPrimary;

  return Material(
    color: AppColors.transparent,
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
                    style: TextStyle(fontSize: 13, color: context.colors.textMuted),
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
                  Icon(Icons.chevron_right, color: context.colors.textMuted),
          ],
        ),
      ),
    ),
  );
}

Widget buildDivider() {
  return Builder(
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: context.colors.divider),
    ),
  );
}

/// Logout card
Widget buildLogoutCard(BuildContext context, WidgetRef ref, bool isLoading) {
  return buildSettingsCard(
    children: [
      buildSettingsItem(
        context: context,
        icon: Icons.logout,
        color: context.colors.error,
        title: isLoading
            ? context.l10n.auth_logging_out
            : context.l10n.auth_logout,
        subtitle: context.l10n.set_logout_subtitle,
        isDestructive: true,
        isLoading: isLoading,
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(context.l10n.auth_logout),
              content: Text(
                context.l10n.localeName == 'vi'
                    ? 'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?'
                    : 'Are you sure you want to log out of the system?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(context.l10n.com_cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.error,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(context.l10n.auth_logout),
                ),
              ],
            ),
          );

          if (confirmed != true) return;

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
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (context) {
      String selectedLocale = currentLocale.languageCode;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surface,
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
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: AppColors.accentDark,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      context.l10n.set_language,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.colors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLanguageOption(
                  context: context,
                  label: context.l10n.set_vietnamese,
                  flag: 'VI',
                  isSelected: selectedLocale == 'vi',
                  onTap: () => setState(() => selectedLocale = 'vi'),
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context: context,
                  label: context.l10n.set_english,
                  flag: 'EN',
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
                          side: BorderSide(color: context.colors.divider),
                        ),
                        child: Text(
                          context.l10n.com_cancel,
                          style: TextStyle(
                            color: context.colors.textPrimary,
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
                          backgroundColor: context.colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.com_save,
                          style: const TextStyle(
                            color: AppColors.white,
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
  required BuildContext context,
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
            ? context.colors.primary.withValues(alpha: 0.05)
            : context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? context.colors.primary : context.colors.divider,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? context.colors.primary.withValues(alpha: 0.1) : context.colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              flag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? context.colors.primary : context.colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? context.colors.primary : context.colors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: context.colors.primary, size: 24)
          else
            Icon(
              Icons.circle_outlined,
              color: context.colors.divider,
              size: 24,
            ),
        ],
      ),
    ),
  );
}
