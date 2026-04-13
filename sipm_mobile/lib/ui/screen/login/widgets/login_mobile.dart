import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/l10n_gen/app_localizations.dart';
import 'package:sipm_mobile/widget/app_text_field/app_text_field.dart';

import '../login_vm/login_vm.dart';
import '../../../../app/l10n/flutter_app_messages.dart';
import 'login_shared.dart';

class LoginMobile extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtl;
  final TextEditingController passwordCtl;
  final VoidCallback onLogin;

  const LoginMobile({
    super.key,
    required this.formKey,
    required this.usernameCtl,
    required this.passwordCtl,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(loginViewModelProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.cMain.withValues(alpha: 0.08),
                  AppColor.white,
                  AppColor.white,
                ],
              ),
            ),
          ),

          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildLoginHeader(l10n: l10n),
                      const SizedBox(height: 32),
                      _buildForm(context, ref, l10n, state),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, AppLocalizations l10n, state) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppEditText(
            controller: usernameCtl,
            labelText: l10n.username,
            hintText: l10n.enterusernamehint,
            prefixIcon: const Icon(Icons.person_outline, color: AppColor.cMuted, size: 22),
            keyboardType: TextInputType.emailAddress,
            fillColor: AppColor.cGray_50,
            borderColor: AppColor.cDivider,
            focusedBorderColor: AppColor.cMain,
            errorBorderColor: AppColor.cError,
            textStyle: const TextStyle(fontSize: 15, color: AppColor.cTitle),
            hintStyle: TextStyle(fontSize: 15, color: AppColor.cMuted.withValues(alpha: 0.7)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.usernamerequired;
              return null;
            },
          ),
          const SizedBox(height: 14),

          AppEditText(
            controller: passwordCtl,
            labelText: l10n.password,
            hintText: l10n.enterpasswordhint,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColor.cMuted, size: 22),
            obscureText: true,
            fillColor: AppColor.cGray_50,
            borderColor: AppColor.cDivider,
            focusedBorderColor: AppColor.cMain,
            errorBorderColor: AppColor.cError,
            textStyle: const TextStyle(fontSize: 15, color: AppColor.cTitle),
            hintStyle: TextStyle(fontSize: 15, color: AppColor.cMuted.withValues(alpha: 0.7)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.passwordrequired;
              if (v.length < 4) return l10n.passwordtooshort;
              return null;
            },
          ),

         // Quên mật khẩu (Align right)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Thêm logic chuyển hướng đến màn quên mật khẩu
                // Ví dụ: context.push(AppConfig.forgotPasswordPath);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child:  Text(
                l10n.forgotpassword,
                style: TextStyle(
                  color: AppColor.cMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // -----------------------------------------

          buildPrimaryButton(
            text: state.isLoading ? l10n.loggingin : l10n.login,
            onPressed: state.isLoading ? null : onLogin,
          ),

          if (state.error != null) ...[
            const SizedBox(height: 12),
            buildErrorBox(context, state.error!),
          ],

          if (state.biometricSetup) ...[
            const SizedBox(height: 42),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColor.cDivider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('hoặc', style: TextStyle(fontSize: 12, color: AppColor.cMuted)),
                ),
                const Expanded(child: Divider(color: AppColor.cDivider)),
              ],
            ),
            const SizedBox(height: 16),
            buildBiometricButton(
              l10n: l10n,
              onPressed: state.isLoading || state.biometricLoading
                  ? null
                  : () => ref.read(loginViewModelProvider.notifier).authenticateWithBiometric(FlutterAppMessages(l10n)),
            ),
          ],
        ],
      ),
    );
  }
}