import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';
import 'package:sipm_mobile/app/consts/app_config.dart';
import 'package:sipm_mobile/app/consts/app_dimens.dart';
import 'package:sipm_mobile/app/l10n_gen/app_localizations.dart';
import 'package:sipm_mobile/widget/app_text_field/app_text_field.dart';
import 'package:sipm_mobile/widget/loading_overlay.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import 'login_vm/login_vm.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
    final isMobile = AppDimens.isMobileScreen(context);
    final l10n = AppLocalizations.of(context)!;
    ref.listen(loginViewModelProvider, (prev, next) {
      if (next.biometricError != null &&
          next.biometricError != prev?.biometricError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.biometricError!),
            backgroundColor: AppColor.cNeedCheck,
          ),
        );
      }

      if (next.isSuccess && (prev == null || !prev.isSuccess)) {
        context.go(AppConfig.homePath);
      }
    });

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
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: isMobile ? double.infinity : 480,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(l10n: l10n, isMobile: isMobile),
                        const SizedBox(height: 32),
                        // Login Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AppEditText(
                                controller: _usernameCtl,
                                labelText: 'Tên đăng nhập',
                                hintText: 'Nhập tên đăng nhập hoặc email',
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: AppColor.cMuted,
                                  size: 22,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                fillColor: AppColor.cGray_50,
                                borderColor: AppColor.cDivider,
                                focusedBorderColor: AppColor.cMain,
                                errorBorderColor: AppColor.cError,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: AppColor.cTitle,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: AppColor.cMuted.withValues(alpha: 0.7),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Vui lòng nhập tên đăng nhập';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              AppEditText(
                                controller: _passwordCtl,
                                labelText: 'Mật khẩu',
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColor.cMuted,
                                  size: 22,
                                ),
                                obscureText: true,
                                fillColor: AppColor.cGray_50,
                                borderColor: AppColor.cDivider,
                                focusedBorderColor: AppColor.cMain,
                                errorBorderColor: AppColor.cError,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: AppColor.cTitle,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: AppColor.cMuted.withValues(alpha: 0.7),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Vui lòng nhập mật khẩu';
                                  if (v.length < 4) return 'Mật khẩu quá ngắn';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Login button
                              _buildPrimaryButton(
                                text: state.isLoading
                                    ? 'Đang đăng nhập...'
                                    : 'Đăng nhập',
                                onPressed: state.isLoading
                                    ? null
                                    : _handleLogin,
                              ),

                              // Error message
                              if (state.error != null) ...[
                                const SizedBox(height: 12),
                                _buildErrorBox(state.error!),
                              ],

                              // Biometric button
                              if (state.biometricSetup) ...[
                                const SizedBox(height: 42),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(color: AppColor.cDivider),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'hoặc',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColor.cMuted,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(color: AppColor.cDivider),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildBiometricButton(
                                  onPressed:
                                      state.isLoading || state.biometricLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              loginViewModelProvider.notifier,
                                            )
                                            .authenticateWithBiometric(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (state.isLoading) const LoadingOverlay.processing(),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required AppLocalizations l10n,
    required bool isMobile,
  }) {
    return Column(
      children: [
        // Phần Logo Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColor.cMain,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColor.cMain.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.business_center_outlined,
            color: AppColor.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),

        // Tên ứng dụng (Sử dụng l10n.app_name hoặc hardcode nếu tên không đổi)
        Text(
          'iERP Mobile',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColor.cTitle,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Câu chào mừng (Đã áp dụng l10n)
        Text(
          l10n.welcomeBack, // "Chào mừng trở lại!" hoặc "Welcome back!"
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColor.cTitle,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.cMain,
          foregroundColor: AppColor.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColor.cMain.withValues(alpha: 0.5),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildBiometricButton({required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.cMain,
          side: BorderSide(color: AppColor.cMain, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(Icons.fingerprint, color: AppColor.cMain, size: 22),
        label: Text(
          'Đăng nhập sinh trắc học',
          style: TextStyle(
            color: AppColor.cMain,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox(AppException error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.cError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.cError.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColor.cError, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error.getDisplayMessage(context.l10n),
              style: TextStyle(
                color: AppColor.cError,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
