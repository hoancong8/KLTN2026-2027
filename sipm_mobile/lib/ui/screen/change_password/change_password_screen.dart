import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import 'package:sipm_mobile/ui/screen/change_password/widgets/change_password_mobile.dart';
import 'package:sipm_mobile/ui/screen/change_password/widgets/change_password_shared.dart';
import 'package:sipm_mobile/ui/screen/change_password/widgets/change_password_tablet.dart';
import 'package:sipm_mobile/widget/responsive_layout.dart';

import 'change_password_vm/change_password_vm.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordCtl = TextEditingController();
  final _newPasswordCtl = TextEditingController();
  final _repeatPasswordCtl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRepeat = true;

  @override
  void dispose() {
    _currentPasswordCtl.dispose();
    _newPasswordCtl.dispose();
    _repeatPasswordCtl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    ref
        .read(changePasswordViewModelProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordCtl.text,
          newPassword: _newPasswordCtl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(changePasswordViewModelProvider, (prev, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.changePasswordSuccess),
            backgroundColor: AppColor.cMain,
          ),
        );
        context.pop();
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColor.cError,
          ),
        );
      }
    });

    final state = ref.watch(changePasswordViewModelProvider);
    final formFields = [
      ChangePasswordShared.buildSectionTitle(context.l10n.currentPassword),
      const SizedBox(height: 12),
      ChangePasswordShared.buildPasswordField(
        controller: _currentPasswordCtl,
        hint: context.l10n.enterCurrentPasswordHint,
        obscureText: _obscureCurrent,
        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
        validator: (v) => (v == null || v.isEmpty)
            ? context.l10n.enterCurrentPasswordHint
            : null,
      ),
      const SizedBox(height: 20),
      ChangePasswordShared.buildSectionTitle(context.l10n.newPassword),
      const SizedBox(height: 12),
      ChangePasswordShared.buildPasswordField(
        controller: _newPasswordCtl,
        hint: context.l10n.enterNewPasswordHint,
        obscureText: _obscureNew,
        onToggle: () => setState(() => _obscureNew = !_obscureNew),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return context.l10n.enterNewPasswordHint;
          }
          if (v.length < 6) return context.l10n.securityNote;
          return null;
        },
      ),
      const SizedBox(height: 20),
      ChangePasswordShared.buildSectionTitle(context.l10n.confirmNewPassword),
      const SizedBox(height: 12),
      ChangePasswordShared.buildPasswordField(
        controller: _repeatPasswordCtl,
        hint: context.l10n.enterConfirmPasswordHint,
        obscureText: _obscureRepeat,
        onToggle: () => setState(() => _obscureRepeat = !_obscureRepeat),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return context.l10n.enterConfirmPasswordHint;
          }
          if (v != _newPasswordCtl.text) return context.l10n.passwordNotMatch;
          return null;
        },
      ),
    ];
    final submitButton = _buildSubmitButton(state.isLoading);

    return ResponsiveLayout(
      mobile: ChangePasswordMobile(
        formKey: _formKey,
        formFields: formFields,
        submitButton: submitButton,
      ),
      tablet: ChangePasswordTablet(
        formKey: _formKey,
        formFields: formFields,
        submitButton: submitButton,
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.cMain,
          foregroundColor: AppColor.white,
          disabledBackgroundColor: AppColor.cMain.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.updatePassword,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}
