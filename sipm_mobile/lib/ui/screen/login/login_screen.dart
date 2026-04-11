import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/widget/loading_overlay.dart';
import 'package:sipm_mobile/widget/responsive_layout.dart'; // Đảm bảo import ResponsiveLayout

import 'login_vm/login_vm.dart';
import 'widgets/login_mobile.dart';
import 'widgets/login_tablet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final vm = ref.read(loginViewModelProvider.notifier);
    await vm.login(
      username: _usernameCtl.text.trim(),
      password: _passwordCtl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe navigation và snackbar ở mức Wrapper
    ref.listen(loginViewModelProvider, (prev, next) {
      if (next.biometricError != null &&
          next.biometricError != prev?.biometricError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.biometricError!),
            backgroundColor: AppColor.cNeedCheck, // Đảm bảo màu này có trong AppColor
          ),
        );
      }

      if (next.isSuccess && (prev == null || !prev.isSuccess)) {
        context.go(AppConfig.homePath);
      }
    });

    final state = ref.watch(loginViewModelProvider);

    return Stack(
      children: [
        // Responsive Layout rẽ nhánh giao diện
        ResponsiveLayout(
          mobile: LoginMobile(
            formKey: _formKey,
            usernameCtl: _usernameCtl,
            passwordCtl: _passwordCtl,
            onLogin: _handleLogin,
          ),
          tablet: LoginTablet(
            formKey: _formKey,
            usernameCtl: _usernameCtl,
            passwordCtl: _passwordCtl,
            onLogin: _handleLogin,
          ),
        ),

        // Loading Overlay phủ toàn màn hình (áp dụng chung cho cả Mobile/Tablet)
        if (state.isLoading) const LoadingOverlay.processing(),
      ],
    );
  }
}