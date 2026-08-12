import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:kltn2026_2027/widget/biometric_settings/biometric_settings_item.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../settings_vm/settings_vm.dart';
import 'setting_page_shared.dart';

// ─────────────────────────────────────────────────────────────────────────────
// INDEX CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const int kSettingsAccountIndex = 0;
const int kSettingsSecurityIndex = 1;
const int kSettingsConfigIndex = 2;
const int kSettingsLogoutIndex = 4;

class SettingsPageTablet extends ConsumerStatefulWidget {
  const SettingsPageTablet({super.key});

  @override
  ConsumerState<SettingsPageTablet> createState() => _SettingsPageTabletState();
}

class _SettingsPageTabletState extends ConsumerState<SettingsPageTablet> {
  int _selectedIndex = kSettingsAccountIndex;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final sections = buildSettingsSections(
      context,
      ref,
      isLoading: state.isLoading,
    );

    final sidebarItems = [
      _SidebarEntry(icon: sections[0].icon, label: sections[0].title),
      _SidebarEntry(icon: sections[1].icon, label: sections[1].title),
      _SidebarEntry(icon: sections[2].icon, label: sections[2].title),
      const _SidebarEntry.divider(),
      _SidebarEntry(
        icon: Icons.logout,
        label: context.l10n.auth_logout,
        isDestructive: true,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: Sidebar (no header) ──────────────────────────
        _SettingsSidebar(
          items: sidebarItems,
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            if (index != 3) {
              // skip divider
              setState(() => _selectedIndex = index);
            }
          },
        ),

        VerticalDivider(width: 1, color: AppColor.cDivider),

        // ── RIGHT: Detail panel ────────────────────────────────
        Expanded(child: _buildDetailPanel(context, sections, state.isLoading)),
      ],
    );
  }

  Widget _buildDetailPanel(
    BuildContext context,
    List<SettingsSection> sections,
    bool isLoading,
  ) {
    switch (_selectedIndex) {
      case kSettingsAccountIndex:
        return _DetailPanel(section: sections[0], extraItems: const []);
      case kSettingsSecurityIndex:
        return _DetailPanel(
          section: sections[1],
          extraItems: const [BiometricSettingsItem()],
        );
      case kSettingsConfigIndex:
        return _DetailPanel(section: sections[2], extraItems: const []);
      case kSettingsLogoutIndex:
        return _LogoutPanel(isLoading: isLoading);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SidebarEntry {
  final IconData icon;
  final String label;
  final bool isDivider;
  final bool isDestructive;

  const _SidebarEntry({
    this.icon = Icons.circle,
    required this.label,
    this.isDivider = false,
    this.isDestructive = false,
  });

  const _SidebarEntry.divider()
    : icon = Icons.circle,
      label = '',
      isDivider = true,
      isDestructive = false;
}

class _SettingsSidebar extends StatelessWidget {
  final List<_SidebarEntry> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _SettingsSidebar({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColor.white,

      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item.isDivider) {
            return Divider(
              height: 24,
              indent: 16,
              endIndent: 16,
              color: AppColor.cDivider,
            );
          }

          final isSelected = selectedIndex == index;
          final activeColor = item.isDestructive
              ? AppColor.cError
              : AppColor.cMain;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Material(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onItemSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isSelected
                            ? activeColor
                            : item.isDestructive
                            ? AppColor.cError
                            : AppColor.cMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? activeColor
                                : item.isDestructive
                                ? AppColor.cError
                                : AppColor.cTitle,
                          ),
                        ),
                      ),
                      if (isSelected && !item.isDestructive)
                        Icon(Icons.chevron_right, size: 16, color: activeColor),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final SettingsSection section;
  final List<Widget> extraItems;

  const _DetailPanel({required this.section, required this.extraItems});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColor.cTitle,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColor.cDivider),
          const SizedBox(height: 16),
          buildSettingsCard(
            children: [
              ...section.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    buildSettingsItem(
                      context: context,
                      icon: item.icon,
                      color: item.color,
                      title: item.title,
                      subtitle: item.subtitle,
                      onTap: item.onTap,
                    ),
                    if (i < section.items.length - 1 || extraItems.isNotEmpty)
                      buildDivider(),
                  ],
                );
              }),
              ...extraItems,
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT PANEL — hiển thị bên phải khi chọn Logout ở sidebar
// Dùng buildLogoutCard từ shared: có loading + l10n giống mobile
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutPanel extends ConsumerWidget {
  final bool isLoading;

  const _LogoutPanel({required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.set_others,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColor.cTitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.set_logout_subtitle,
            style: TextStyle(fontSize: 13, color: AppColor.cMuted),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColor.cDivider),
          const SizedBox(height: 16),
          buildLogoutCard(context, ref, isLoading),
        ],
      ),
    );
  }
}
