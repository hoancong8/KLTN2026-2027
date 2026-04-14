import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import 'change_password_shared.dart';

class ChangePasswordTablet extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> formFields;
  final Widget submitButton;

  const ChangePasswordTablet({
    super.key,
    required this.formKey,
    required this.formFields,
    required this.submitButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColor.cGray_50,
      appBar: ChangePasswordShared(context.l10n.changepassword),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ), // Giới hạn chiều rộng
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChangePasswordShared.buildHeader(context),
                    const SizedBox(height: 32),
                    ...formFields,
                    const SizedBox(height: 40),
                    submitButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
