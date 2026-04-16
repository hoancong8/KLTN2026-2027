import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import 'change_password_shared.dart';

class ChangePasswordMobile extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> formFields;
  final Widget submitButton;

  const ChangePasswordMobile({
    super.key,
    required this.formKey,
    required this.formFields,
    required this.submitButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: ChangePasswordShared(context.l10n.auth_change_password),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChangePasswordShared.buildHeader(context),
                const SizedBox(height: 24),
                ChangePasswordShared.buildSecurityNote(context),
                const SizedBox(height: 24),
                ...formFields,
                const SizedBox(height: 32),
                submitButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
