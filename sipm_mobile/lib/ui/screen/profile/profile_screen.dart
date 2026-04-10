import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/provider.dart';
import 'package:sipm_mobile/domain/entities/employee.dart';
import 'package:sipm_mobile/widget/app_button/app_button.dart';
import 'package:sipm_mobile/widget/app_button/app_button_common.dart';
import 'package:sipm_mobile/widget/app_text_field/app_text_field.dart';
import 'package:sipm_mobile/widget/loading_overlay.dart';
import 'profile_vm/profile_vm.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
class ProfileScreen extends ConsumerStatefulWidget {
  final Employee? initialEmployee;

  const ProfileScreen({super.key, this.initialEmployee});

  @override
  ConsumerState<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameCtl;
  late final TextEditingController _emailCtl;
  late final TextEditingController _phoneCtl;
  late final TextEditingController _addressCtl;
  late final TextEditingController _hometownCtl;

  DateTime? _selectedDoB;
  int _selectedGender = 0;

  @override
  void initState() {
    super.initState();
    final emp = widget.initialEmployee;

    _fullNameCtl = TextEditingController(text: emp?.fullName ?? '');
    _emailCtl = TextEditingController(text: emp?.email ?? '');
    _phoneCtl = TextEditingController(text: emp?.phone ?? '');
    _addressCtl = TextEditingController(text: emp?.address ?? '');
    _hometownCtl = TextEditingController(text: emp?.hometown ?? '');
    _selectedDoB = emp?.doB;
    _selectedGender = emp?.gender ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (emp != null) {
        ref.read(profileViewModelProvider.notifier).setEmployee(emp);
      } else {
        final token = ref.read(authTokenProvider);
        final userId = token?.userId ?? 0;
        ref.read(profileViewModelProvider.notifier).loadProfile(userId);
      }
    });
  }

  @override
  void dispose() {
    _fullNameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _addressCtl.dispose();
    _hometownCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    ref.listen(profileViewModelProvider, (prev, next) {
      if (next.employee != null && prev?.employee == null) {
        final emp = next.employee!;
        _fullNameCtl.text = emp.fullName ?? '';
        _emailCtl.text = emp.email ?? '';
        _phoneCtl.text = emp.phone ?? '';
        _addressCtl.text = emp.address ?? '';
        _hometownCtl.text = emp.hometown ?? '';
        setState(() {
          _selectedDoB = emp.doB;
          _selectedGender = emp.gender ?? 0;
        });
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.getDisplayMessage(context.l10n)),
            backgroundColor: AppColor.cError,
          ),
        );
      }
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColor.cMain,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColor.cGray_50,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.cTitle),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Cập nhật thông tin',
          style: TextStyle(
            color: AppColor.cTitle,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.cMain),
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatarSection(),
                          const SizedBox(height: 24),
                          _buildBasicInfoSection(),
                          const SizedBox(height: 20),
                          _buildAddressSection(),
                          const SizedBox(height: 20),
                          _buildWorkInfoSection(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
          if (state.isSaving)
            const LoadingOverlay(message: 'Đang lưu thông tin...'),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColor.cMain.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.cMain.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColor.cMain,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: AppButton(
                  onTap: () {
                    // Pick avatar
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColor.cMain,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullNameCtl.text.isNotEmpty
                      ? _fullNameCtl.text
                      : 'Chưa cập nhật',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.cTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailCtl.text.isNotEmpty ? _emailCtl.text : 'Chưa có email',
                  style: TextStyle(fontSize: 13, color: AppColor.cMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_outline,
            title: 'Thông tin cơ bản',
          ),
          const SizedBox(height: 16),
          AppEditText(
            controller: _fullNameCtl,
            labelText: 'Họ và tên',
            hintText: 'Nhập họ và tên',
            prefixIcon: const Icon(
              Icons.badge_outlined,
              color: AppColor.cMuted,
              size: 20,
            ),
            focusedBorderColor: AppColor.cMain,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppEditText(
            controller: _emailCtl,
            labelText: 'Email',
            hintText: 'Nhập địa chỉ email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColor.cMuted,
              size: 20,
            ),
            focusedBorderColor: AppColor.cMain,
          ),
          const SizedBox(height: 16),
          AppEditText(
            controller: _phoneCtl,
            labelText: 'Số điện thoại',
            hintText: 'Nhập số điện thoại',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: AppColor.cMuted,
              size: 20,
            ),
            focusedBorderColor: AppColor.cMain,
          ),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildGenderField(),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ',
          ),
          const SizedBox(height: 16),
          AppEditText(
            controller: _addressCtl,
            labelText: 'Địa chỉ hiện tại',
            hintText: 'Nhập địa chỉ hiện tại',
            maxLines: 2,
            prefixIcon: const Icon(
              Icons.home_outlined,
              color: AppColor.cMuted,
              size: 20,
            ),
            focusedBorderColor: AppColor.cMain,
          ),
          const SizedBox(height: 16),
          AppEditText(
            controller: _hometownCtl,
            labelText: 'Quê quán',
            hintText: 'Nhập quê quán',
            prefixIcon: const Icon(
              Icons.place_outlined,
              color: AppColor.cMuted,
              size: 20,
            ),
            focusedBorderColor: AppColor.cMain,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoSection() {
    final emp = widget.initialEmployee;
    if (emp == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.work_outline,
            title: 'Thông tin công việc',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.business_outlined,
            'Phòng ban',
            emp.workDepartmentName ?? '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.badge_outlined,
            'Chức vụ',
            emp.workPositionName ?? '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.admin_panel_settings_outlined,
            'Vai trò',
            emp.roleName ?? '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.person_outline,
            'Tên đăng nhập',
            emp.userName ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.cMain.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColor.cMain, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.cTitle,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày sinh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColor.cMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDoB != null
                        ? '${_selectedDoB!.day.toString().padLeft(2, '0')}/${_selectedDoB!.month.toString().padLeft(2, '0')}/${_selectedDoB!.year}'
                        : 'Chọn ngày sinh',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedDoB != null
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColor.cMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                onTap: () {
                  setState(() {
                    _selectedGender = 0;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 0
                        ? AppColor.cMain.withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 0
                          ? AppColor.cMain
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: _selectedGender == 0
                            ? AppColor.cMain
                            : AppColor.cMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nam',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedGender == 0
                              ? AppColor.cMain
                              : AppColor.cMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                onTap: () {
                  setState(() {
                    _selectedGender = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 1
                        ? AppColor.cMain.withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 1
                          ? AppColor.cMain
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: _selectedGender == 1
                            ? AppColor.cMain
                            : AppColor.cMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nữ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedGender == 1
                              ? AppColor.cMain
                              : AppColor.cMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColor.cMuted, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColor.cMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cTitle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return AppButtonCommon(
      text: 'Lưu thay đổi',
      type: AppButtonType.primary,
      backgroundColor: AppColor.cMain,
      prefixIcon: const Icon(
        Icons.save_outlined,
        color: AppColor.white,
        size: 20,
      ),
      onPressed: () async {
        await _onSave();
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDoB ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.cMain,
              onPrimary: AppColor.white,
              surface: AppColor.white,
              onSurface: AppColor.cTitle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDoB = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    ref
        .read(profileViewModelProvider.notifier)
        .updateField(
          fullName: _fullNameCtl.text.trim(),
          email: _emailCtl.text.trim(),
          phone: _phoneCtl.text.trim(),
          address: _addressCtl.text.trim(),
          hometown: _hometownCtl.text.trim(),
          doB: _selectedDoB,
          gender: _selectedGender,
        );

    await ref.read(profileViewModelProvider.notifier).saveProfile();
  }
}
