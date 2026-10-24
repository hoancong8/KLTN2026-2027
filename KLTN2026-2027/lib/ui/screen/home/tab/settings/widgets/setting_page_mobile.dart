import 'package:kltn2026_2027/ui/screen/profile/profile_vm/profile_vm.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/consts/app_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/theme/theme.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/settings/widgets/setting_page_shared.dart';
import 'package:kltn2026_2027/widget/biometric_settings/biometric_settings_item.dart';
import '../../../../../../app/provider/localization_provider.dart';
import '../settings_vm/settings_vm.dart';

class SettingsPageMobile extends ConsumerWidget {
  const SettingsPageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(settingsViewModelProvider);
    final sections = buildSettingsSections(
      context,
      ref,
      isLoading: state.isLoading,
    );

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ hồ sơ cá nhân nổi bật ở đầu trang
          _buildUserProfileHeaderCard(context, ref),
          const SizedBox(height: 16),
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

  Widget _buildUserProfileHeaderCard(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profileState = ref.watch(profileViewModelProvider);
    final profile = profileState.playerProfile;
    final user = ref.watch(currentUserProfileProvider);
    final name = (profile != null && profile.fullName.isNotEmpty)
        ? profile.fullName
        : (user?.userName ?? 'Hội viên cầu lông');
    final skill = profile?.skillLevel.displayName ?? 'Trung bình (TB)';
    final reputation = profile?.reputationScore != null ? profile!.reputationScore.toStringAsFixed(1) : '5.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primaryContainer,
            backgroundImage: (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: AppTypography.titleMedium.bold.colored(colors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        skill,
                        style: AppTypography.labelSmall.bold.colored(colors.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: colors.warning),
                        const SizedBox(width: 2),
                        Text(
                          reputation,
                          style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.primary),
            tooltip: 'Chỉnh sửa hồ sơ',
            onPressed: () => context.push(AppConfig.profilePath),
          ),
        ],
      ),
    );
  }
}
