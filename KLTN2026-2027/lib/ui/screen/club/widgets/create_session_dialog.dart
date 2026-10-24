// lib/ui/screen/club/widgets/create_session_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _rentalCostCtl = TextEditingController(text: '300000');

  DateTime _startTime = DateTime.now().add(const Duration(days: 1, hours: 2)).copyWith(minute: 0, second: 0);
  DateTime _endTime = DateTime.now().add(const Duration(days: 1, hours: 4)).copyWith(minute: 0, second: 0);
  int _courtCount = 2;
  int _targetPlayerPerCourt = 6;
  bool _isSubmitting = false;

  int get _maxPlayers => _courtCount * _targetPlayerPerCourt;

  @override
  void initState() {
    super.initState();
    _titleCtl.text = 'Buổi sinh hoạt ${widget.clubName}';
    _courtLocationCtl.text = 'Sân Cầu Lông Kỳ Hòa, Quận 10';
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
      } else {
        _endTime = newDt;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endTime.isBefore(_startTime) || _endTime.isAtSameMomentAs(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giờ kết thúc phải sau giờ bắt đầu!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final vm = ref.read(clubSessionsViewModelProvider(widget.clubId).notifier);
    final cost = double.tryParse(_rentalCostCtl.text.replaceAll(',', '')) ?? 0.0;

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
        deadlineBooking: _startTime.subtract(const Duration(hours: 2)),
        courtRentalCost: cost,
      ),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (sessionId != null) {
        Navigator.of(context).pop(sessionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo buổi chơi thành công'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Khởi Tạo Buổi Chơi',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Title
                _buildLabel('Tiêu đề buổi sinh hoạt *'),
                TextFormField(
                  controller: _titleCtl,
                  decoration: _inputDecoration(hint: 'VD: Kèo thứ 4 sân Kỳ Hòa'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
                ),
                const SizedBox(height: 14),

                // Court Location
                _buildLabel('Địa điểm sân cầu lông *'),
                TextFormField(
                  controller: _courtLocationCtl,
                  decoration: _inputDecoration(
                    hint: 'VD: Sân Cầu Lông Kỳ Hòa, Quận 10',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa điểm' : null,
                ),
                const SizedBox(height: 14),

                // Start and End Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Bắt đầu'),
                          InkWell(
                            onTap: () => _pickDateTime(isStart: true),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.inputBorder),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 18, color: colors.textMuted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')} - ${_startTime.day}/${_startTime.month}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Kết thúc'),
                          InkWell(
                            onTap: () => _pickDateTime(isStart: false),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.inputBorder),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled_rounded, size: 18, color: colors.textMuted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')} - ${_endTime.day}/${_endTime.month}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                const SizedBox(height: 14),

                // Court Count & Capacity Calculator
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 10),

                // Max Players Auto-Calculation Callout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Số lượng người tối đa: $_maxPlayers slot chính thức',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Court Rental Cost
                _buildLabel('Tổng chi phí thuê sân (VNĐ)'),
                TextFormField(
                  controller: _rentalCostCtl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hint: '300,000',
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                ),
                const SizedBox(height: 22),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Tạo Buổi Chơi Ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: colors.textMuted) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.inputBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}
