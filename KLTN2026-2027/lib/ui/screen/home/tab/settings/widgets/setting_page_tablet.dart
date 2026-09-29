import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/widget/biometric_settings/biometric_settings_item.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../settings_vm/settings_vm.dart';
import 'setting_page_shared.dart';

class SettingsPageTablet extends ConsumerStatefulWidget {
  const SettingsPageTablet({super.key});

  @override
  ConsumerState<SettingsPageTablet> createState() => _SettingsPageTabletState();
}

class _SettingsPageTabletState extends ConsumerState<SettingsPageTablet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final sections = buildSettingsSections(
      context,
      ref,
      isLoading: state.isLoading,
    );

    final sidebarItems = [
      for (final section in sections)
        _SidebarEntry(icon: section.icon, label: section.title),
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
            if (index != sections.length) {
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
    if (_selectedIndex >= 0 && _selectedIndex < sections.length) {
      final section = sections[_selectedIndex];
      final isSecurity = section.title == context.l10n.set_security;
      return _DetailPanel(
        section: section,
        extraItems: isSecurity ? const [BiometricSettingsItem()] : const [],
      );
    } else if (_selectedIndex == sections.length + 1) {
      return _LogoutPanel(isLoading: isLoading);
    }
    return const SizedBox.shrink();
  }
}

class _SidebarEntry {
  final IconData icon;
  final String label;
  final bool isDivider;
  final bool isDestructive;

  const _SidebarEntry({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  }) : isDivider = false;

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
    return SizedBox(
      width: 280,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: items.length,
        separatorBuilder: (_, index) {
          if (items[index].isDivider) return const SizedBox.shrink();
          return const SizedBox(height: 4);
        },
        itemBuilder: (context, index) {
          final item = items[index];

          if (item.isDivider) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColor.cDivider),
            );
          }

          final isSelected = index == selectedIndex;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (item.isDestructive
                          ? Colors.red.withAlpha(25)
                          : AppColor.cMain.withAlpha(25))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: item.isDestructive
                              ? Colors.red.withAlpha(70)
                              : AppColor.cMain.withAlpha(70),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: item.isDestructive
                          ? Colors.red
                          : isSelected
                              ? AppColor.cMain
                              : AppColor.cMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: item.isDestructive
                              ? Colors.red
                              : isSelected
                                  ? AppColor.cMain
                                  : AppColor.cTitle,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: item.isDestructive ? Colors.red : AppColor.cMain,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final SettingsSection section;
  final List<Widget> extraItems;

  const _DetailPanel({
    required this.section,
    required this.extraItems,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        buildSectionTitle(context, section.title, section.icon),
        const SizedBox(height: 16),
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
            if (extraItems.isNotEmpty) ...[
              buildDivider(),
              ...extraItems,
            ],
          ],
        ),
      ],
    );
  }
}

class _LogoutPanel extends StatelessWidget {
  final bool isLoading;

  const _LogoutPanel({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            buildSectionTitle(
              context,
              context.l10n.auth_logout,
              Icons.logout,
            ),
            const SizedBox(height: 16),
            buildLogoutCard(context, ref, isLoading),
          ],
        );
      },
    );
  }
}
