// lib/ui/screen/club/create_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../widget/responsive_layout.dart';
import '../../../app/provider.dart';
import '../../../domain/usecases/session/session_usecases.dart';
import 'session_vm/club_sessions_vm.dart';
import 'widgets/map_location_picker_sheet.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  final String clubId;
  final String clubName;

  const CreateSessionScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  AppThemeColors get colors => context.colors;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtl;
  late final TextEditingController _courtNameCtl;
  late final TextEditingController _addressCtl;
  late final TextEditingController _rentalCostCtl;

  double? _latitude;
  double? _longitude;

  DateTime _startTime = DateTime.now().add(const Duration(days: 1, hours: 2)).copyWith(minute: 0, second: 0);
  DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 4)).copyWith(minute: 0, second: 0);
  late DateTime _deadlineBooking;
  int _courtCount = 2;
  int _targetPlayerPerCourt = 6;
  bool _isSubmitting = false;

  int get _maxPlayers => _courtCount * _targetPlayerPerCourt;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: 'Buổi sinh hoạt ${widget.clubName}');
    _courtNameCtl = TextEditingController(text: 'Sân Cầu Lông Kỳ Hòa');
    _addressCtl = TextEditingController(text: '238 Đường 3/2, Phường 12, Quận 10, TP. Hồ Chí Minh');
    _rentalCostCtl = TextEditingController(text: '300.000');
    _deadlineBooking = _startTime.subtract(const Duration(hours: 2));
    _latitude = 10.7725;
    _longitude = 106.6698;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _courtNameCtl.dispose();
    _addressCtl.dispose();
    _rentalCostCtl.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await MapLocationPickerSheet.show(
      context,
      initialVenueName: _courtNameCtl.text.trim(),
      initialAddress: _addressCtl.text.trim(),
      initialLat: _latitude,
      initialLng: _longitude,
    );

    if (result != null && mounted) {
      setState(() {
        _courtNameCtl.text = result.venueName;
        _addressCtl.text = result.address;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initialDate = isStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      final newDt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startTime = newDt;
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 2));
        }
        _deadlineBooking = _startTime.subtract(const Duration(hours: 2));
      } else {
        _endTime = newDt;
      }
    });
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadlineBooking.isBefore(DateTime.now()) ? DateTime.now() : _deadlineBooking,
      firstDate: DateTime.now(),
      lastDate: _startTime,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadlineBooking),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (picked.isAfter(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hạn chốt giữ chỗ phải trước giờ bắt đầu buổi chơi!'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _deadlineBooking = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endTime.isBefore(_startTime) || _endTime.isAtSameMomentAs(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Giờ kết thúc phải sau giờ bắt đầu!'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_deadlineBooking.isAfter(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hạn chốt giữ chỗ phải trước giờ bắt đầu!'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final vm = ref.read(clubSessionsViewModelProvider(widget.clubId).notifier);
    final costStr = _rentalCostCtl.text.replaceAll('.', '').replaceAll(',', '').replaceAll(' ', '');
    final cost = double.tryParse(costStr) ?? 0.0;

    final venueName = _courtNameCtl.text.trim();
    final address = _addressCtl.text.trim();

    final sessionId = await vm.createSession(
      CreateSessionParams(
        clubId: widget.clubId,
        title: _titleCtl.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        courtLocation: venueName.isNotEmpty ? venueName : address,
        address: address.isNotEmpty ? address : venueName,
        lat: _latitude,
        lng: _longitude,
        courtCount: _courtCount,
        targetPlayerPerCourt: _targetPlayerPerCourt,
        maxPlayers: _maxPlayers,
        deadlineBooking: _deadlineBooking,
        courtRentalCost: cost,
      ),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (sessionId != null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tạo buổi chơi thành công!'),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khởi Tạo Buổi Chơi',
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
            ),
            Text(
              widget.clubName,
              style: AppTypography.labelSmall.colored(colors.textMuted),
            ),
          ],
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          border: Border(top: BorderSide(color: colors.cardBorder)),
          boxShadow: AppShadows.md,
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                : Text(
                    'Tạo buổi chơi ngay',
                    style: AppTypography.bodyMedium.bold.colored(AppColors.white),
                  ),
          ),
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildBody(maxWidth: double.infinity),
        tablet: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _buildBody(maxWidth: 640),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({required double maxWidth}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tên buổi chơi Card
            _buildSectionCard(
              title: 'Thông tin buổi chơi',
              icon: Icons.sports_tennis_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Tên buổi chơi *'),
                  TextFormField(
                    controller: _titleCtl,
                    style: AppTypography.bodyMedium.colored(colors.textPrimary),
                    decoration: _inputDecoration(hint: 'VD: Buổi chơi thứ 4 sân Kỳ Hòa'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên buổi chơi' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Địa điểm sân & Bản đồ
            _buildSectionCard(
              title: 'Địa điểm sân cầu lông',
              icon: Icons.location_on_rounded,
              action: TextButton.icon(
                onPressed: _openMapPicker,
                icon: const Icon(Icons.map_rounded, size: 16),
                label: const Text('Chọn trên bản đồ'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Preview Box (Tap to pick)
                  InkWell(
                    onTap: _openMapPicker,
                    borderRadius: AppRadius.card,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Icon(Icons.location_on_rounded, color: colors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _courtNameCtl.text.isNotEmpty ? _courtNameCtl.text : 'Chưa đặt tên sân',
                                  style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _addressCtl.text.isNotEmpty ? _addressCtl.text : 'Chưa có địa chỉ',
                                  style: AppTypography.bodySmall.colored(colors.textSecondary),
                                ),
                                if (_latitude != null && _longitude != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.cardBackground,
                                      borderRadius: AppRadius.borderXs,
                                      border: Border.all(color: colors.cardBorder),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.gps_fixed_rounded, size: 12, color: colors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)} (OpenStreetMap)',
                                          style: AppTypography.labelSmall.colored(colors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tên sân editable
                  _buildFieldLabel('Tên sân hiển thị *'),
                  TextFormField(
                    controller: _courtNameCtl,
                    style: AppTypography.bodySmall.colored(colors.textPrimary),
                    decoration: _inputDecoration(hint: 'VD: Sân Cầu Lông Kỳ Hòa'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên sân' : null,
                  ),

                  const SizedBox(height: 10),

                  // Địa chỉ editable
                  _buildFieldLabel('Địa chỉ chi tiết *'),
                  TextFormField(
                    controller: _addressCtl,
                    maxLines: 2,
                    style: AppTypography.bodySmall.colored(colors.textPrimary),
                    decoration: _inputDecoration(hint: 'Địa chỉ cụ thể của sân...'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Thời gian & Hạn chốt
            _buildSectionCard(
              title: 'Thời gian tổ chức & Hạn chốt',
              icon: Icons.access_time_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Giờ bắt đầu *'),
                            InkWell(
                              onTap: () => _pickDateTime(isStart: true),
                              borderRadius: AppRadius.button,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colors.inputBorder),
                                  borderRadius: AppRadius.button,
                                  color: colors.surfaceSubtle,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DateFormat('HH:mm - dd/MM').format(_startTime),
                                        style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Giờ kết thúc *'),
                            InkWell(
                              onTap: () => _pickDateTime(isStart: false),
                              borderRadius: AppRadius.button,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colors.inputBorder),
                                  borderRadius: AppRadius.button,
                                  color: colors.surfaceSubtle,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded, size: 16, color: colors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DateFormat('HH:mm - dd/MM').format(_endTime),
                                        style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildFieldLabel('Hạn chốt giữ chỗ (Khóa đăng ký tự động)'),
                  InkWell(
                    onTap: _pickDeadline,
                    borderRadius: AppRadius.button,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.inputBorder),
                        borderRadius: AppRadius.button,
                        color: colors.surfaceSubtle,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: colors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('HH:mm - dd/MM/yyyy').format(_deadlineBooking),
                              style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                            ),
                          ),
                          Text(
                            'Thay đổi',
                            style: AppTypography.labelSmall.bold.colored(colors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Quy mô sân & Sức chứa
            _buildSectionCard(
              title: 'Quy mô sân & Sức chứa',
              icon: Icons.groups_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Số lượng sân'),
                            DropdownButtonFormField<int>(
                              initialValue: _courtCount,
                              decoration: _inputDecoration(),
                              items: List.generate(10, (i) => i + 1).map((c) {
                                return DropdownMenuItem(value: c, child: Text('$c sân'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _courtCount = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Số người / sân'),
                            DropdownButtonFormField<int>(
                              initialValue: _targetPlayerPerCourt,
                              decoration: _inputDecoration(),
                              items: [4, 5, 6, 7, 8].map((p) {
                                return DropdownMenuItem(value: p, child: Text('$p người'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _targetPlayerPerCourt = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Sức chứa tối đa: $_maxPlayers người chính thức',
                          style: AppTypography.bodySmall.bold.colored(colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Chi phí thuê sân (nếu dynamic)
            Builder(
              builder: (context) {
                final feeRuleAsync = ref.watch(clubFeeRuleProvider(widget.clubId));
                final isDynamic = feeRuleAsync.asData?.value.isDynamic ?? true;
                if (!isDynamic) return const SizedBox.shrink();

                return _buildSectionCard(
                  title: 'Chi phí thuê sân',
                  icon: Icons.payments_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Tổng chi phí thuê sân (VNĐ)'),
                      TextFormField(
                        controller: _rentalCostCtl,
                        keyboardType: TextInputType.number,
                        style: AppTypography.bodyMedium.bold.colored(colors.textPrimary),
                        decoration: _inputDecoration(
                          hint: '300.000',
                          suffixText: 'VNĐ',
                          prefixIcon: Icons.attach_money_rounded,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CLB chia thực tế: tiền thuê sân sẽ được cộng với tiền cầu và phụ phí để chia đều cuối buổi.',
                        style: AppTypography.bodySmall.colored(colors.textMuted),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                ),
              ),
              ?action,
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? suffixText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySmall.colored(colors.textMuted),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: colors.textMuted) : null,
      suffixText: suffixText,
      suffixStyle: AppTypography.bodySmall.bold.colored(colors.textSecondary),
      filled: true,
      fillColor: colors.surfaceSubtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: colors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }
}
