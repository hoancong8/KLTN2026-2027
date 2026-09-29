import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/domain/entities/app_role.dart';
import 'package:kltn2026_2027/domain/entities/user_profile.dart';

class UserFormDialog extends StatefulWidget {
  final UserProfile? user; // null = Thêm mới, khác null = Sửa
  final List<AppRole> availableRoles;
  final Function({
    required String email,
    required String password,
    required String userName,
    String? phoneNumber,
    required List<String> roles,
  }) onSubmit;

  const UserFormDialog({
    super.key,
    this.user,
    required this.availableRoles,
    required this.onSubmit,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _userNameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late List<String> _selectedRoles;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _userNameController = TextEditingController(text: widget.user?.userName ?? '');
    _phoneController = TextEditingController(text: widget.user?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _selectedRoles = List<String>.from(widget.user?.roles ?? []);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        email: _emailController.text.trim(),
        userName: _userNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        password: _passwordController.text,
        roles: _selectedRoles,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Chỉnh sửa tài khoản' : 'Thêm tài khoản mới',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cTitle,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColor.cMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Email Input
                  const Text(
                    'Email / Tên tài khoản *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Nhập email hoặc tên tài khoản',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                      prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColor.cMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cMain, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Vui lòng nhập Email hoặc Username';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Họ tên / Username
                  const Text(
                    'Họ và tên *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập họ và tên hiển thị',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColor.cMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cMain, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Vui lòng nhập Họ và tên';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Số điện thoại
                  const Text(
                    'Số điện thoại',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại (tùy chọn)',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColor.cMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cDivider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.cMain, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mật khẩu (chỉ bắt buộc khi tạo mới)
                  if (!isEditing) ...[
                    const Text(
                      'Mật khẩu khởi tạo *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu tài khoản',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColor.cMuted),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColor.cMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColor.cMuted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColor.cDivider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColor.cDivider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColor.cMain, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (!isEditing && (v == null || v.trim().length < 6)) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Chọn Vai trò (Roles)
                  const Text(
                    'Vai trò / Quyền hạn',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cTitle),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (widget.availableRoles.isNotEmpty
                            ? widget.availableRoles.map((r) => r.name).toList()
                            : ['Admin', 'Manager', 'Staff', 'User'])
                        .map((roleName) {
                      final isSelected = _selectedRoles.contains(roleName);
                      return FilterChip(
                        label: Text(roleName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedRoles.add(roleName);
                            } else {
                              _selectedRoles.remove(roleName);
                            }
                          });
                        },
                        selectedColor: AppColor.cMain.withAlpha(40),
                        checkmarkColor: AppColor.cMain,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColor.cMain : AppColor.cTitle,
                        ),
                        backgroundColor: AppColor.cChip,
                        side: BorderSide(
                          color: isSelected ? AppColor.cMain : AppColor.cDivider,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Actions Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy', style: TextStyle(color: AppColor.cMuted)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cMain,
                          foregroundColor: AppColor.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isEditing ? 'Lưu thay đổi' : 'Tạo tài khoản',
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
    );
  }
}
