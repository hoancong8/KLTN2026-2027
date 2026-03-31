import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ierp_mobile/app/consts/app_colcor.dart';
import 'package:ierp_mobile/app/consts/app_config.dart';
import 'package:ierp_mobile/widget/biometric_settings/biometric_settings_item.dart';
import 'settings_vm/settings_vm.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);

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
          _buildSectionTitle(context, 'Tài khoản', Icons.person_outline),
          const SizedBox(height: 12),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.person_outline,
                color: AppColor.cMain,
                title: 'Tài khoản',
                subtitle: 'Thông tin người dùng, phân quyền',
                onTap: () {
                  context.push(AppConfig.profilePath);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Bảo mật', Icons.security_outlined),
          const SizedBox(height: 12),
          _buildSettingsCard(
            children: [
              _buildSettingsItem(
                context: context,
                icon: Icons.lock_outline,
                color: AppColor.cYanPrimary,
                title: 'Đổi mật khẩu',
                subtitle: 'Thay đổi mật khẩu đăng nhập',
                onTap: () {
                  context.push(AppConfig.changePasswordPath);
                },
              ),
              _buildDivider(),
              const BiometricSettingsItem(),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Khác', Icons.more_horiz),
          const SizedBox(height: 12),
          _buildLogoutCard(context, ref, state.isLoading),
          const SizedBox(height: 24),
        ],
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
          child: Icon(Icons.settings_outlined, color: AppColor.cMain, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cài đặt',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColor.cTitle,
                ),
              ),
              Text(
                'Cấu hình hệ thống & tài khoản',
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
                        isLoading ? 'Đang đăng xuất...' : 'Đăng xuất',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColor.cError,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Đăng xuất khỏi hệ thống',
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
