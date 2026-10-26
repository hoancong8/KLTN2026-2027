// lib/ui/screen/club/widgets/create_session_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../../domain/usecases/session/session_usecases.dart';
import '../session_vm/club_sessions_vm.dart';

class CreateSessionDialog extends ConsumerStatefulWidget {
  final String clubId;
  final String clubName;

  const CreateSessionDialog({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  static Future<String?> show(BuildContext context, {required String clubId, required String clubName}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateSessionDialog(clubId: clubId, clubName: clubName),
    );
  }

  @override
  ConsumerState<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends ConsumerState<CreateSessionDialog> {
  AppThemeColors get colors => context.colors;
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _courtLocationCtl = TextEditingController();
  final _rentalCostCtl = TextEditingController(text: '300.000');

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
    _titleCtl.text = 'Buổi sinh hoạt ${widget.clubName}';
    _courtLocationCtl.text = 'Sân Cầu Lông Kỳ Hòa, Quận 10';
    _deadlineBooking = _startTime.subtract(const Duration(hours: 2));
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _courtLocationCtl.dispose();
    _rentalCostCtl.dispose();
    super.dispose();
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
          content: const Text('Hạn chốt phải trước giờ bắt đầu buổi chơi!'),
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

    final sessionId = await vm.createSession(
      CreateSessionParams(
        clubId: widget.clubId,
        title: _titleCtl.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        courtLocation: _courtLocationCtl.text.trim(),
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
        Navigator.of(context).pop(sessionId);
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
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: AppSpacing.allLg,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 24),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Text(
                        'Khởi Tạo Buổi Chơi',
                        style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Tên buổi chơi
                _buildLabel('Tên buổi chơi *'),
                TextFormField(
                  controller: _titleCtl,
                  decoration: _inputDecoration(hint: 'VD: Buổi chơi thứ 4 sân Kỳ Hòa'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên buổi chơi' : null,
                ),
                AppSpacing.gapH12,

                // Địa điểm sân
                _buildLabel('Địa điểm sân cầu lông *'),
                TextFormField(
                  controller: _courtLocationCtl,
                  decoration: _inputDecoration(
                    hint: 'VD: Sân Cầu Lông Kỳ Hòa, Quận 10',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa điểm' : null,
                ),
                AppSpacing.gapH12,

                // Giờ bắt đầu & Kết thúc
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Bắt đầu'),
                          InkWell(
                            onTap: () => _pickDateTime(isStart: true),
                            borderRadius: AppRadius.button,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.inputBorder),
                                borderRadius: AppRadius.button,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 18, color: colors.textMuted),
                                  AppSpacing.gapW8,
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
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kết thúc'),
                          InkWell(
                            onTap: () => _pickDateTime(isStart: false),
                            borderRadius: AppRadius.button,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.inputBorder),
                                borderRadius: AppRadius.button,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled_rounded, size: 18, color: colors.textMuted),
                                  AppSpacing.gapW8,
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
                AppSpacing.gapH12,

                // Hạn chốt giữ chỗ
                _buildLabel('Hạn chốt giữ chỗ (Tự động khóa đăng ký)'),
                InkWell(
                  onTap: _pickDeadline,
                  borderRadius: AppRadius.button,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.inputBorder),
                      borderRadius: AppRadius.button,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 18, color: colors.warning),
                        AppSpacing.gapW8,
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
                AppSpacing.gapH12,

                // Số lượng sân & Số người / sân
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Số lượng sân'),
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
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Số người / sân'),
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
                AppSpacing.gapH8,

                // Max Players Auto-Calculation Callout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: colors.primary),
                      AppSpacing.gapW8,
                      Text(
                        'Số người tối đa: $_maxPlayers người chính thức',
                        style: AppTypography.bodySmall.bold.colored(colors.textPrimary),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH12,

                // Court Rental Cost
                _buildLabel('Tổng chi phí thuê sân (VNĐ)'),
                TextFormField(
                  controller: _rentalCostCtl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hint: '300.000',
                    suffixText: 'VNĐ',
                    prefixIcon: Icons.payments_outlined,
                  ),
                ),
                AppSpacing.gapH24,

                // Submit Button
                ElevatedButton(
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
                      : const Text('Tạo buổi chơi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTypography.labelSmall.bold.colored(colors.textPrimary)),
    );
  }

  InputDecoration _inputDecoration({String? hint, String? suffixText, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySmall.colored(colors.textMuted),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: colors.textMuted) : null,
      suffixText: suffixText,
      suffixStyle: AppTypography.bodySmall.bold.colored(colors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: AppRadius.button, borderSide: BorderSide(color: colors.inputBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.button, borderSide: BorderSide(color: colors.inputBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: AppRadius.button, borderSide: BorderSide(color: colors.primary, width: 1.5)),
    );
  }
}
