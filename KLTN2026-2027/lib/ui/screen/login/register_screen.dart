// lib/ui/screen/login/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/consts/app_config.dart';
import '../../../domain/enums/session_enums.dart';
import '../../../widget/loading_overlay.dart';
import 'register_vm/register_vm.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmPasswordCtl = TextEditingController();

  int _selectedGender = 1; // 1: Nam, 2: Nữ, 0: Khác
  SkillLevel _selectedSkillLevel = SkillLevel.tb;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passwordCtl.dispose();
    _confirmPasswordCtl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtl.text != _confirmPasswordCtl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp!'),
          backgroundColor: AppColor.cRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final vm = ref.read(registerViewModelProvider.notifier);
    final success = await vm.register(
      fullName: _fullNameCtl.text.trim(),
      email: _emailCtl.text.trim().isNotEmpty ? _emailCtl.text.trim() : null,
      phoneNumber: _phoneCtl.text.trim().isNotEmpty ? _phoneCtl.text.trim() : null,
      password: _passwordCtl.text,
      gender: _selectedGender,
      skillLevel: _selectedSkillLevel.code,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Chào mừng bạn gia nhập hệ thống'),
          backgroundColor: AppColor.cMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppConfig.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Đăng Ký Tài Khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.cTitle,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppConfig.loginPath);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.neutral900, AppColors.neutral800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.cMain.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.sports_tennis_rounded, color: AppColor.cMain, size: 36),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Cầu Lông Phong Trào Legends',
                              style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tạo tài khoản để tham gia các CLB và đặt sân giao lưu',
                              style: TextStyle(color: AppColors.white.withAlpha(180), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (state.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColor.cRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.cRed.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColor.cRed, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(color: AppColor.cRed, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Full Name
                      _buildFieldLabel('Họ và tên *'),
                      TextFormField(
                        controller: _fullNameCtl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          hint: 'Nguyễn Văn A',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildFieldLabel('Email'),
                      TextFormField(
                        controller: _emailCtl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hint: 'nguyenvana@gmail.com',
                          prefixIcon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildFieldLabel('Số điện thoại'),
                      TextFormField(
                        controller: _phoneCtl,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          hint: '0987654321',
                          prefixIcon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gender & Skill Level in 2 columns
                      Row(
                        children: [
                          // Gender
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Giới tính'),
                                DropdownButtonFormField<int>(
                                  initialValue: _selectedGender,
                                  decoration: _inputDecoration(),
                                  items: const [
                                    DropdownMenuItem(value: 1, child: Text('Nam')),
                                    DropdownMenuItem(value: 2, child: Text('Nữ')),
                                    DropdownMenuItem(value: 0, child: Text('Khác')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedGender = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Skill Level
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Trình độ'),
                                DropdownButtonFormField<SkillLevel>(
                                  initialValue: _selectedSkillLevel,
                                  decoration: _inputDecoration(),
                                  items: SkillLevel.values.map((s) {
                                    return DropdownMenuItem(value: s, child: Text(s.displayName));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedSkillLevel = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _buildFieldLabel('Mật khẩu *'),
                      TextFormField(
                        controller: _passwordCtl,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hint: 'Tối thiểu 6 ký tự',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColor.cMuted,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (v.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildFieldLabel('Xác nhận mật khẩu *'),
                      TextFormField(
                        controller: _confirmPasswordCtl,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          hint: 'Nhập lại mật khẩu',
                          prefixIcon: Icons.lock_clock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColor.cMuted,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                          if (v != _passwordCtl.text) return 'Mật khẩu xác nhận không khớp';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      ElevatedButton(
                        onPressed: state.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cMain,
                          foregroundColor: AppColor.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Đăng Ký Tài Khoản',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Đã có tài khoản? ', style: TextStyle(color: AppColor.cMuted, fontSize: 14)),
                          GestureDetector(
                            onTap: () => context.go(AppConfig.loginPath),
                            child: const Text(
                              'Đăng nhập ngay',
                              style: TextStyle(color: AppColor.cMain, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.isLoading) const LoadingOverlay.processing(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColor.cMuted, fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColor.cMuted, size: 20) : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: AppColor.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.cMain, width: 1.8),
      ),
    );
  }
}
