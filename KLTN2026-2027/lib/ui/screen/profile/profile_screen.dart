import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/consts/app_color.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/utils/exception_ext.dart';
import '../../../../domain/entities/player_profile.dart';
import '../../../../domain/enums/session_enums.dart';
import 'profile_vm/profile_vm.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).reloadProfile();
    });
  }

  void _showEditProfileBottomSheet(BuildContext context, PlayerProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(profile: profile),
    );
  }

  Color _getSkillColor(SkillLevel level) {
    switch (level) {
      case SkillLevel.nb:
        return const Color(0xFF9E9E9E);
      case SkillLevel.y:
        return const Color(0xFF8BC34A);
      case SkillLevel.tby:
        return const Color(0xFF4CAF50);
      case SkillLevel.tb:
        return const Color(0xFF0284C7);
      case SkillLevel.tbk:
        return const Color(0xFF3F51B5);
      case SkillLevel.k:
        return const Color(0xFFF59E0B);
      case SkillLevel.g:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    ref.listen(profileViewModelProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.getDisplayMessage(context.l10n)),
            backgroundColor: AppColor.cError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColor.cMain,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final profile = state.playerProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        title: const Text(
          'Hồ sơ & Trình độ cá nhân',
          style: TextStyle(
            color: AppColor.cDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColor.cDark),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColor.cMain, size: 26),
              tooltip: 'Chỉnh sửa hồ sơ',
              onPressed: () => _showEditProfileBottomSheet(context, profile),
            ),
        ],
      ),
      body: state.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
          : profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off_outlined, size: 64, color: AppColor.cMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'Không thể tải thông tin hồ sơ',
                        style: TextStyle(fontSize: 15, color: AppColor.cDark, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cMain,
                          foregroundColor: AppColor.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => ref.read(profileViewModelProvider.notifier).reloadProfile(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColor.cMain,
                  onRefresh: () => ref.read(profileViewModelProvider.notifier).reloadProfile(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    children: [
                      // 1. Header Card (Avatar, Name, Score, Badges)
                      _buildHeaderCard(profile),
                      const SizedBox(height: 16),

                      // 2. Guest Matching Radar Toggle Card
                      _buildGuestToggleCard(profile),
                      const SizedBox(height: 16),

                      // 3. Skill Level Card with 7 Tiers Explanation
                      _buildSkillLevelCard(profile),
                      const SizedBox(height: 16),

                      // 4. Contact & Personal Info Card
                      _buildContactInfoCard(profile),
                      const SizedBox(height: 24),

                      // 5. Edit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cMain,
                            foregroundColor: AppColor.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showEditProfileBottomSheet(context, profile),
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          label: const Text(
                            'Chỉnh sửa hồ sơ & Trình độ',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard(PlayerProfile profile) {
    final skillColor = _getSkillColor(profile.skillLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColor.cMain.withValues(alpha: 0.12),
                backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                    ? Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName[0].toUpperCase()
                            : profile.userName.isNotEmpty
                                ? profile.userName[0].toUpperCase()
                                : 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColor.cMain,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Name & Identity Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName.isNotEmpty ? profile.fullName : profile.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.cDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${profile.userName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.cMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Gender Chip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: profile.gender == 1
                                ? Colors.blue.withValues(alpha: 0.1)
                                : profile.gender == 2
                                    ? Colors.pink.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                profile.gender == 1
                                    ? Icons.male_rounded
                                    : profile.gender == 2
                                        ? Icons.female_rounded
                                        : Icons.transgender_rounded,
                                size: 14,
                                color: profile.gender == 1
                                    ? Colors.blue[700]
                                    : profile.gender == 2
                                        ? Colors.pink[700]
                                        : Colors.grey[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.gender == 1
                                    ? 'Nam'
                                    : profile.gender == 2
                                        ? 'Nữ'
                                        : 'Khác',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: profile.gender == 1
                                      ? Colors.blue[700]
                                      : profile.gender == 2
                                          ? Colors.pink[700]
                                          : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Skill badge & Reputation chips
          Row(
            children: [
              // Skill badge
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: skillColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: skillColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: skillColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          profile.skillLevel.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profile.skillLevel.displayName,
                          style: TextStyle(
                            color: skillColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Reputation Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      profile.reputationScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Uy tín',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestToggleCard(PlayerProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        activeThumbColor: AppColor.cMain,
        title: const Row(
          children: [
            Icon(Icons.radar_rounded, color: AppColor.cMain, size: 20),
            SizedBox(width: 8),
            Text(
              'Sẵn sàng nhận kèo giao lưu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColor.cDark,
              ),
            ),
          ],
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Bật tùy chọn này để các CLB và nhóm vãng lai xung quanh có thể tìm thấy bạn qua Radar tuyển khách.',
            style: TextStyle(fontSize: 12, color: AppColor.cMuted),
          ),
        ),
        value: profile.isOpenForGuest,
        onChanged: (val) {
          ref.read(profileViewModelProvider.notifier).updateProfile(
                fullName: profile.fullName,
                gender: profile.gender,
                avatarUrl: profile.avatarUrl,
                skillLevel: profile.skillLevel,
                isOpenForGuest: val,
              );
        },
      ),
    );
  }

  Widget _buildSkillLevelCard(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sports_tennis_rounded, color: AppColor.cMain, size: 20),
              SizedBox(width: 8),
              Text(
                'Thang đo trình độ chuẩn hóa (7 bậc)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.cDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hệ thống ghép kèo tự động dựa trên trình độ bạn khai báo để phân chia sân cân bằng nhất.',
            style: TextStyle(fontSize: 12, color: AppColor.cMuted),
          ),
          const SizedBox(height: 12),

          // List of 7 levels
          ...SkillLevel.values.map((level) {
            final isCurrent = level == profile.skillLevel;
            final color = _getSkillColor(level);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? color : Colors.transparent,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      level.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: AppColor.cDark,
                          ),
                        ),
                        Text(
                          level.description,
                          style: const TextStyle(fontSize: 11, color: AppColor.cMuted),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Icon(Icons.check_circle_rounded, color: color, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColor.cMain, size: 20),
              SizedBox(width: 8),
              Text(
                'Thông tin tài khoản',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.cDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Tên đăng nhập', profile.userName, Icons.account_circle_outlined),
          const Divider(height: 20),
          _buildInfoRow('Email', profile.email, Icons.mail_outline_rounded),
          const Divider(height: 20),
          _buildInfoRow(
            'Số điện thoại',
            profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty
                ? profile.phoneNumber!
                : 'Chưa cập nhật',
            Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColor.cMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColor.cMuted),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.cDark,
          ),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final PlayerProfile profile;
  const _EditProfileSheet({required this.profile});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _gender;
  late SkillLevel _skillLevel;
  late bool _isOpenForGuest;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _gender = widget.profile.gender;
    _skillLevel = widget.profile.skillLevel;
    _isOpenForGuest = widget.profile.isOpenForGuest;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileViewModelProvider.notifier).updateProfile(
          fullName: _nameController.text.trim(),
          gender: _gender,
          avatarUrl: widget.profile.avatarUrl,
          skillLevel: _skillLevel,
          isOpenForGuest: _isOpenForGuest,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chỉnh sửa hồ sơ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColor.cDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColor.cMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Full Name
              const Text(
                'Họ và tên',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cDark),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nhập họ và tên...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập họ tên';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Selector
              const Text(
                'Giới tính',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderChip(1, 'Nam', Icons.male_rounded),
                  const SizedBox(width: 8),
                  _buildGenderChip(2, 'Nữ', Icons.female_rounded),
                  const SizedBox(width: 8),
                  _buildGenderChip(0, 'Khác', Icons.transgender_rounded),
                ],
              ),
              const SizedBox(height: 16),

              // Skill Level Selector
              const Text(
                'Trình độ tự đánh giá',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColor.cDark),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SkillLevel.values.map((level) {
                  final isSelected = _skillLevel == level;
                  return ChoiceChip(
                    label: Text('${level.code} - ${level.displayName}'),
                    selected: isSelected,
                    selectedColor: AppColor.cMain.withValues(alpha: 0.15),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColor.cMain : AppColor.cDark,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppColor.cMain : Colors.transparent,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _skillLevel = level);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Open for Guest Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColor.cMain,
                title: const Text(
                  'Nhận kèo giao lưu khách vãng lai',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.cDark),
                ),
                subtitle: const Text(
                  'Cho phép các nhóm quanh vị trí GPS quét tìm bạn',
                  style: TextStyle(fontSize: 12, color: AppColor.cMuted),
                ),
                value: _isOpenForGuest,
                onChanged: (val) => setState(() => _isOpenForGuest = val),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cMain,
                    foregroundColor: AppColor.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: state.isSaving ? null : _submit,
                  child: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(int genderValue, String label, IconData icon) {
    final isSelected = _gender == genderValue;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gender = genderValue),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.cMain.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColor.cMain : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColor.cMain : AppColor.cMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColor.cMain : AppColor.cDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
