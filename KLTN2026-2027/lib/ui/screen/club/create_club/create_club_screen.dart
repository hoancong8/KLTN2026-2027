// lib/ui/screen/club/create_club/create_club_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kltn2026_2027/app/provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../domain/enums/session_enums.dart';
import '../club_vm/club_context_vm.dart';
import '../../home/tab/club/widgets/club_schedule_planner.dart';
import '../widgets/map_location_picker_sheet.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  AppThemeColors get colors => context.colors;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  int _currentStep = 0;

  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _descController;
  late final TextEditingController _venueController;
  late final TextEditingController _addressController;

  double? _lat;
  double? _lng;
  bool _isGettingLocation = false;
  bool _isUploadingAvatar = false;

  SkillLevel _minLevel = SkillLevel.nb;
  SkillLevel _maxLevel = SkillLevel.k;
  bool _isRecruiting = true;

  bool _hasSchedule = true;
  final List<ClubScheduleEntry> _schedules = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  static const List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=150',
    'https://images.unsplash.com/photo-1613918431703-aa6321ab85ec?w=150',
    'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();
    _descController = TextEditingController();
    _venueController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 0:
        return 'Chủ Nhật';
      default:
        return 'Thứ $dayOfWeek';
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final uploadUseCase = ref.read(uploadImageUseCaseProvider);
      final uploadedUrl = await uploadUseCase.execute(
        pickedFile.path,
        folder: 'badminton_app/clubs',
      );

      if (!mounted) return;
      setState(() {
        _avatarUrlController.text = uploadedUrl;
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tải ảnh đại diện lên thành công!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải ảnh: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.allBase,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn Ảnh Đại Diện CLB',
                style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
              ),
              AppSpacing.gapH4,
              Text(
                'Tải ảnh trực tiếp lên hệ thống lưu trữ Cloudinary',
                style: AppTypography.bodySmall.colored(colors.textMuted),
              ),
              AppSpacing.gapH16,
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: colors.primary),
                ),
                title: Text('Chụp ảnh từ camera', style: AppTypography.labelLarge.bold.colored(colors.textPrimary)),
                subtitle: Text('Sử dụng camera của thiết bị', style: AppTypography.bodySmall.colored(colors.textMuted)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded, color: colors.primary),
                ),
                title: Text('Chọn ảnh từ thư viện', style: AppTypography.labelLarge.bold.colored(colors.textPrimary)),
                subtitle: Text('Tải ảnh có sẵn từ thiết bị', style: AppTypography.bodySmall.colored(colors.textMuted)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocationOnMap() async {
    final result = await MapLocationPickerSheet.show(
      context,
      initialVenueName: _venueController.text.trim(),
      initialAddress: _addressController.text.trim(),
      initialLat: _lat,
      initialLng: _lng,
    );
    if (result != null && mounted) {
      setState(() {
        _venueController.text = result.venueName;
        _addressController.text = result.address;
        _lat = result.latitude;
        _lng = result.longitude;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final locationService = ref.read(locationServiceProvider);
      final loc = await locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _lat = loc.latitude;
        _lng = loc.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật tọa độ GPS: (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)})',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy tọa độ GPS. Vui lòng kiểm tra quyền truy cập vị trí.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _onNextStep() {
    setState(() => _errorMessage = null);
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!_formKeyStep2.currentState!.validate()) return;
      setState(() => _currentStep = 2);
    }
  }

  void _onPrevStep() {
    if (_currentStep > 0) {
      setState(() {
        _errorMessage = null;
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (_hasSchedule && _schedules.isNotEmpty) {
      for (int i = 0; i < _schedules.length; i++) {
        final entry = _schedules[i];
        final startMin = entry.startTime.hour * 60 + entry.startTime.minute;
        final endMin = entry.endTime.hour * 60 + entry.endTime.minute;
        if (startMin >= endMin) {
          setState(() {
            _errorMessage = 'Buổi ${_getDayName(entry.dayOfWeek)}: Giờ bắt đầu (${_formatTime(entry.startTime)}) phải trước giờ kết thúc (${_formatTime(entry.endTime)}).';
          });
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);
    final vm = ref.read(clubContextViewModelProvider.notifier);

    final Map<int, Map<String, dynamic>> distinctSchedules = {};
    if (_hasSchedule && _schedules.isNotEmpty) {
      for (final s in _schedules) {
        distinctSchedules[s.dayOfWeek] = {
          'dayOfWeek': s.dayOfWeek,
          'startTime': _formatTime(s.startTime),
          'endTime': _formatTime(s.endTime),
        };
      }
    }
    final schedulesList = distinctSchedules.isNotEmpty
        ? distinctSchedules.values.toList()
        : null;

    final newClubId = await vm.createClub(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      avatarUrl: _avatarUrlController.text.trim().isNotEmpty ? _avatarUrlController.text.trim() : null,
      fixedVenueName: _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : null,
      fixedAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      lat: _lat,
      lng: _lng,
      minSkillLevel: _minLevel.code,
      maxSkillLevel: _maxLevel.code,
      schedules: schedulesList,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (newClubId != null && newClubId.isNotEmpty) {
      _showSuccessDialog(newClubId, _nameController.text.trim());
    } else {
      setState(() {
        _errorMessage = 'Tạo câu lạc bộ thất bại. Vui lòng kiểm tra lại kết nối mạng.';
      });
    }
  }

  void _showSuccessDialog(String clubId, String clubName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        contentPadding: AppSpacing.allXl,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.allLg,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
            ),
            AppSpacing.gapH16,
            Text(
              'Tạo Nhóm Thành Công!',
              style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            Text(
              'Bạn đã trở thành Chủ nhóm (Host) của $clubName. Hãy chia sẻ mã nhóm để mời bạn bè tham gia.',
              style: AppTypography.bodySmall.colored(colors.textMuted),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH24,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                icon: const Icon(Icons.sports_tennis_rounded, size: AppSpacing.iconSm),
                label: Text('Vào sinh hoạt CLB ngay', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/club/$clubId');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Khởi Tạo Câu Lạc Bộ',
          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _onPrevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Progress Header
            _buildStepperHeader(),

            if (_errorMessage != null)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                    padding: AppSpacing.allMd,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        AppSpacing.gapW8,
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodySmall.colored(AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 768),
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      color: colors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
            child: Row(
              children: [
                _buildStepItem(0, 'Thông tin', Icons.badge_outlined),
                _buildStepDivider(0),
                _buildStepItem(1, 'Sân bãi', Icons.location_on_outlined),
                _buildStepDivider(1),
                _buildStepItem(2, 'Lịch chơi', Icons.calendar_month_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String title, IconData icon) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;
    final itemColor = isActive
        ? AppColors.primary
        : (isDone ? AppColors.success : colors.textMuted);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.15)
                  : (isActive ? colors.primaryContainer : colors.cardBackground),
              shape: BoxShape.circle,
              border: Border.all(color: itemColor, width: isActive ? 2 : 1),
            ),
            child: Icon(
              isDone ? Icons.check_rounded : icon,
              size: 18,
              color: itemColor,
            ),
          ),
          AppSpacing.gapH4,
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: itemColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(int afterStep) {
    final isDone = _currentStep > afterStep;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDone ? AppColors.success : colors.cardBorder,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2VenueGps();
      case 2:
        return _buildStep3SchedulesAndRecruitment();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1BasicInfo() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước 1: Thông tin cơ bản',
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
          Text(
            'Tên nhóm và thông điệp chào đón thành viên mới',
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
          AppSpacing.gapH20,

          // Tên CLB
          Text('Tên Câu Lạc Bộ *', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
          AppSpacing.gapH8,
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Ví dụ: CLB Cầu Lông Tân Bình Legend',
              filled: true,
              fillColor: colors.inputFill,
              prefixIcon: Icon(Icons.groups_rounded, color: colors.primary),
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên câu lạc bộ';
              if (v.trim().length < 3) return 'Tên câu lạc bộ phải từ 3 ký tự trở lên';
              return null;
            },
          ),
          AppSpacing.gapH16,

          // Avatar Upload & Preset Section
          Text('Ảnh Đại Diện Câu Lạc Bộ', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
          AppSpacing.gapH8,
          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _isUploadingAvatar ? null : _showImageSourcePicker,
                  child: Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.primary.withValues(alpha: 0.3), width: 2),
                        ),
                        child: ClipOval(
                          child: _isUploadingAvatar
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                )
                              : (_avatarUrlController.text.trim().isNotEmpty
                                  ? Image.network(
                                      _avatarUrlController.text.trim(),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.sports_tennis_rounded,
                                        size: 32,
                                        color: colors.primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.groups_rounded,
                                      size: 36,
                                      color: colors.textMuted,
                                    )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.cardBackground, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapW16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                        icon: _isUploadingAvatar
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: Text(
                          _isUploadingAvatar ? 'Đang tải lên...' : 'Tải ảnh từ máy',
                          style: AppTypography.labelMedium.bold.colored(colors.primary),
                        ),
                        onPressed: _isUploadingAvatar ? null : _showImageSourcePicker,
                      ),
                      AppSpacing.gapH4,
                      Text(
                        'Hỗ trợ JPG, PNG, WEBP (Tối đa 5MB)',
                        style: AppTypography.caption.colored(colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH12,
          TextFormField(
            controller: _avatarUrlController,
            decoration: InputDecoration(
              hintText: 'Hoặc dán URL ảnh / chọn ảnh mẫu bên dưới',
              filled: true,
              fillColor: colors.inputFill,
              prefixIcon: Icon(Icons.link_rounded, color: colors.textMuted),
              suffixIcon: _avatarUrlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _avatarUrlController.clear()),
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.gapH8,
          Row(
            children: [
              Text('Ảnh mẫu: ', style: AppTypography.bodySmall.colored(colors.textMuted)),
              ..._avatarPresets.map((url) {
                final isSelected = _avatarUrlController.text == url;
                return GestureDetector(
                  onTap: () {
                    setState(() => _avatarUrlController.text = url);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                    ),
                  ),
                );
              }),
            ],
          ),
          AppSpacing.gapH16,

          // Mô tả
          Text('Mô Tả Câu Lạc Bộ', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
          AppSpacing.gapH8,
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Giới thiệu về tinh thần sinh hoạt, đối tượng tham gia, tiêu chí giao lưu...',
              filled: true,
              fillColor: colors.inputFill,
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2VenueGps() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước 2: Sân bãi & Vị trí',
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
          Text(
            'Giúp người chơi xung quanh tìm thấy CLB trên Radar GPS',
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
          AppSpacing.gapH20,

          // Tên sân
          Text('Tên Sân Sinh Hoạt Cố Định *', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
          AppSpacing.gapH8,
          TextFormField(
            controller: _venueController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Sân Cầu Lông Kỳ Hòa Q10',
              filled: true,
              fillColor: colors.inputFill,
              prefixIcon: Icon(Icons.stadium_outlined, color: colors.primary),
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên sân cố định';
              return null;
            },
          ),
          AppSpacing.gapH16,

          // Địa chỉ
          Text('Địa Chỉ Cụ Thể', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
          AppSpacing.gapH8,
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 238 Ba Tháng Hai, Phường 12, Quận 10, TP.HCM',
              filled: true,
              fillColor: colors.inputFill,
              prefixIcon: Icon(Icons.place_outlined, color: colors.textMuted),
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide(color: colors.inputBorder)),
            ),
          ),
          AppSpacing.gapH16,

          // Tọa độ GPS
          Text('Tọa Độ GPS (Định vị Radar)', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
          AppSpacing.gapH8,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_lat != null ? AppColors.success : colors.textMuted).withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(
                    _lat != null ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                    color: _lat != null ? AppColors.success : colors.textMuted,
                    size: 20,
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tọa độ vị trí GPS',
                        style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.gapH4,
                      Text(
                        _lat != null
                            ? '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                            : 'Chưa có tọa độ',
                        style: AppTypography.bodySmall.semiBold.colored(
                          _lat != null ? AppColors.primary : colors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text('Bản đồ'),
                      onPressed: _pickLocationOnMap,
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      icon: _isGettingLocation
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.my_location_rounded, size: 16),
                      label: const Text('GPS'),
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3SchedulesAndRecruitment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước 3: Lịch sinh hoạt & Trình độ',
          style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
        ),
        Text(
          'Cấu hình tiêu chuẩn tuyển chọn và khung giờ sinh hoạt cố định',
          style: AppTypography.bodySmall.colored(colors.textMuted),
        ),
        AppSpacing.gapH20,

        // Mở tuyển thành viên switch
        Container(
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: colors.cardBorder),
          ),
          child: SwitchListTile(
            activeThumbColor: AppColors.primary,
            title: Text('Mở tuyển thành viên mới', style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
            subtitle: Text('Cho phép người chơi xung quanh tìm thấy và nộp đơn xin gia nhập', style: AppTypography.bodySmall.colored(colors.textMuted)),
            value: _isRecruiting,
            onChanged: (val) => setState(() => _isRecruiting = val),
          ),
        ),
        AppSpacing.gapH16,

        // Tiêu chuẩn trình độ
        Text('Khoảng Trình Độ Tiếp Nhận', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
        AppSpacing.gapH8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SkillLevel>(
                  isExpanded: true,
                  initialValue: _minLevel,
                  decoration: InputDecoration(
                    labelText: 'Tối thiểu',
                    labelStyle: AppTypography.labelSmall.colored(colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                  ),
                  items: SkillLevel.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.displayName,
                              style: AppTypography.bodySmall.colored(colors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _minLevel = val;
                        if (_minLevel.level > _maxLevel.level) {
                          _maxLevel = _minLevel;
                        }
                      });
                    }
                  },
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: DropdownButtonFormField<SkillLevel>(
                  isExpanded: true,
                  initialValue: _maxLevel,
                  decoration: InputDecoration(
                    labelText: 'Tối đa',
                    labelStyle: AppTypography.labelSmall.colored(colors.textMuted),
                    filled: true,
                    fillColor: colors.inputFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                  ),
                  items: SkillLevel.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.displayName,
                              style: AppTypography.bodySmall.colored(colors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _maxLevel = val;
                        if (_maxLevel.level < _minLevel.level) {
                          _minLevel = _maxLevel;
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapH20,

        // Lập lịch tuần
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lịch Sinh Hoạt Tuần Cố Định', style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
            Switch(
              value: _hasSchedule,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _hasSchedule = val),
            ),
          ],
        ),
        if (_hasSchedule) ...[
          AppSpacing.gapH8,
          ClubSchedulePlanner(
            initialSchedules: _schedules,
            onChanged: (list) {
              _schedules.clear();
              _schedules.addAll(list);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.cardBorder)),
      ),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      onPressed: _isSubmitting ? null : _onPrevStep,
                      child: const Text('Quay lại'),
                    ),
                  ),
                if (_currentStep > 0) AppSpacing.gapW12,
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : (_currentStep == 2 ? _submit : _onNextStep),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Text(
                            _currentStep == 2 ? 'Hoàn tất tạo CLB' : 'Tiếp tục',
                            style: AppTypography.labelLarge.bold.colored(AppColors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
