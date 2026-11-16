import 'package:go_router/go_router.dart';
// lib/ui/screen/club/session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/provider.dart';
import '../../../domain/enums/club_role.dart';
import '../../../domain/entities/session/guest_recruitment.dart';
import '../../../domain/entities/club/club_fee_rule.dart';
import '../../../domain/entities/session/session.dart';
import '../../../domain/entities/session/session_booking.dart';
import '../../common/player_gender_helper.dart';
import '../../../domain/utils/session_fee_calculator.dart';
import '../../../domain/enums/session_enums.dart';
import '../../../domain/usecases/session/session_usecases.dart';
import 'club_vm/club_context_vm.dart';
import 'session_vm/session_detail_vm.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCourtPassActive = false;
  int _courtPassPrice = 0;
  String _courtPassPhone = '';
  String _courtPassNote = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getWeekdayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  Future<void> _handleVote() async {
    final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
    final booking = await vm.voteBooking();

    if (!mounted) return;
    final colors = context.colors;

    if (booking != null) {
      if (booking.isConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.session_join_success),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: colors.cardBackground,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
            title: Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: colors.warning),
                AppSpacing.gapW8,
                Text(
                  context.l10n.booking_status_pending,
                  style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                ),
              ],
            ),
            content: Text(
              'Yêu cầu của bạn đang ở vị trí chờ số #${booking.queueOrder} trong hàng đợi.\nNgười quản trị sẽ xét duyệt bạn vào danh sách tham gia chính thức.',
              style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.com_confirm),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleCancelBooking() async {
    final colors = context.colors;
    final detail = ref.read(sessionDetailViewModelProvider(widget.sessionId)).detail;
    final session = detail?.session;
    final now = DateTime.now();
    final isEnded = session?.status == SessionStatus.completed ||
        session?.status == SessionStatus.calculated ||
        (session != null && session.endTime.isBefore(now));
    final isPlaying = !isEnded && (session?.status == SessionStatus.playing ||
        (session != null && session.startTime.isBefore(now) && session.endTime.isAfter(now)));
    final isExpired = session?.isExpired == true ||
        (session != null && session.deadlineBooking.isBefore(now));
    final isOpen = session?.status == SessionStatus.open;
    final canCancel = isOpen && !isEnded && !isPlaying && !isExpired;

    if (!canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPlaying
                ? 'Buổi chơi đang diễn ra, không thể hủy giữ chỗ.'
                : 'Đã hết hạn thay đổi đăng ký. Vui lòng liên hệ Host.',
          ),
          backgroundColor: colors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dialogTitle = 'Hủy giữ chỗ tham gia';
    final dialogContent = 'Bạn có chắc chắn muốn hủy xác nhận tham gia buổi chơi này? Suất của bạn sẽ tự động được nhường cho người tiếp theo trong hàng đợi.';
    final confirmBtnLabel = 'Hủy giữ chỗ';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error),
            AppSpacing.gapW8,
            Text(
              dialogTitle,
              style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          dialogContent,
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmBtnLabel),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
      final ok = await vm.cancelBooking();
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOpen ? 'Đã hủy xác nhận tham gia thành công' : context.l10n.com_success),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleConfirmBooking(SessionBooking player) async {
    final colors = context.colors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            Icon(Icons.how_to_reg_rounded, color: colors.success),
            AppSpacing.gapW8,
            Expanded(
              child: Text(
                'Duyệt người chơi vào sân',
                style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          'Xác nhận duyệt người chơi "${player.fullName}" từ hàng đợi vào danh sách tham gia chính thức?',
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.success,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Duyệt ngay'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
      final ok = await vm.confirmBooking(player.bookingId);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã duyệt "${player.fullName}" vào danh sách chính thức!'),
              backgroundColor: colors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final error = ref.read(sessionDetailViewModelProvider(widget.sessionId)).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Không thể duyệt người chơi'),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showRecruitmentModal(BuildContext context, Session session, {GuestRecruitment? activeRecruitment}) {
    final colors = context.colors;
    final feeRule = ref.read(clubFeeRuleProvider(session.groupId)).asData?.value;
    final isDynamic = feeRule?.feeMode.toUpperCase() == 'DYNAMIC';
    final slotsNeeded = activeRecruitment?.slotsNeeded ??
        (session.maxPlayers - session.confirmedCount).clamp(1, session.maxPlayers);
    final slotsCtl = TextEditingController(text: slotsNeeded.toString());
    final dynamicSuggested = session.maxPlayers > 0 && session.courtRentalCost > 0
        ? ((session.courtRentalCost / session.maxPlayers) / 1000).ceil() * 1000
        : 30000;
    final suggestedCost = activeRecruitment != null
        ? activeRecruitment.maleCost.toInt()
        : (isDynamic
            ? dynamicSuggested
            : (feeRule?.guestFee.toInt() ?? (session.maxPlayers > 0 && session.courtRentalCost > 0
                ? ((session.courtRentalCost / session.maxPlayers) / 1000).ceil() * 1000
                : 50000)));
    final costCtl = TextEditingController(text: suggestedCost.toString());
    final femDiscount = feeRule?.femaleDiscountDaily.toInt() ?? 5000;
    final suggestedFemaleCost = activeRecruitment != null
        ? activeRecruitment.femaleCost.toInt()
        : (suggestedCost - femDiscount).clamp(0, suggestedCost);
    final femaleCostCtl = TextEditingController(text: suggestedFemaleCost.toString());
    SkillLevel selectedLevel = activeRecruitment?.minSkillLevel ?? SkillLevel.tb;
    double radiusKm = activeRecruitment?.scanRadiusKm.toDouble() ?? 5.0;
    bool hidePlayerList = activeRecruitment?.hidePlayerList ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.base,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.base,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.gapH16,
                Row(
                  children: [
                    Icon(Icons.radar_rounded, color: colors.primary, size: 24),
                    AppSpacing.gapW8,
                    Text(
                      activeRecruitment != null ? 'Cập Nhật Tin Tuyển Khách' : 'Tuyển Người Chơi Vãng Lai',
                      style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
                AppSpacing.gapH8,
                Text(
                  'Đăng tin tìm thêm người chơi cùng cho buổi cầu lông.',
                  style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                ),
                AppSpacing.gapH16,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số người cần tuyển',
                      style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                    ),
                    AppSpacing.gapH4,
                    TextFormField(
                      controller: slotsCtl,
                      keyboardType: TextInputType.number,
                      style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.inputFill,
                        prefixIcon: Icon(Icons.group_add_rounded, size: 20, color: colors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: BorderSide(color: colors.inputBorder),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH12,
                if (isDynamic)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pie_chart_rounded, size: 20, color: colors.primary),
                        AppSpacing.gapW8,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buổi chơi áp dụng chia đều chi phí thực tế',
                                style: AppTypography.labelSmall.bold.colored(colors.primary),
                              ),
                              AppSpacing.gapH4,
                              Text(
                                'Chi phí ước tính ~${NumberFormat('#,###').format(dynamicSuggested)} đ/người (chia theo đầu người thực tế sau buổi chơi, Nữ ưu đãi: -${NumberFormat('#,###').format(femDiscount)} đ).',
                                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.male_rounded, size: 16, color: colors.primary),
                                AppSpacing.gapW4,
                                Text(
                                  'Phí Nam (VNĐ)',
                                  style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                                ),
                              ],
                            ),
                            AppSpacing.gapH4,
                            TextFormField(
                              controller: costCtl,
                              keyboardType: TextInputType.number,
                              style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: '50,000',
                                hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textPlaceholder),
                                filled: true,
                                fillColor: colors.inputFill,
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.input,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (val) {
                                final maleCost = int.tryParse(val.replaceAll(',', '').trim()) ?? 0;
                                final femCost = (maleCost - femDiscount).clamp(0, maleCost);
                                femaleCostCtl.text = femCost.toString();
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
                            Row(
                              children: [
                                Icon(Icons.female_rounded, size: 16, color: colors.secondary),
                                AppSpacing.gapW4,
                                Text(
                                  'Phí Nữ (VNĐ)',
                                  style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                                ),
                              ],
                            ),
                            AppSpacing.gapH4,
                            TextFormField(
                              controller: femaleCostCtl,
                              keyboardType: TextInputType.number,
                              style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                              decoration: InputDecoration(
                                hintText: '40,000',
                                hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textPlaceholder),
                                filled: true,
                                fillColor: colors.inputFill,
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.input,
                                  borderSide: BorderSide(color: colors.inputBorder),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                AppSpacing.gapH16,
                Text(
                  'Trình độ tối thiểu yêu cầu',
                  style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                ),
                AppSpacing.gapH8,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SkillLevel.values.map((s) {
                    final isSelected = selectedLevel == s;
                    return ChoiceChip(
                      label: Text('${s.code} • ${s.displayName}'),
                      selected: isSelected,
                      selectedColor: colors.primary,
                      backgroundColor: colors.surfaceSubtle,
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.white : colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.cardBorder,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedLevel = s);
                        }
                      },
                    );
                  }).toList(),
                ),
                AppSpacing.gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Khu vực tìm quanh sân:',
                      style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                    ),
                    Text(
                      '${radiusKm.toStringAsFixed(1)} km',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: radiusKm,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  activeColor: colors.primary,
                  onChanged: (val) => setModalState(() => radiusKm = val),
                ),
                AppSpacing.gapH8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Ẩn danh sách người chơi',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Khách chỉ thấy số chỗ còn trống, không xem danh sách thành viên.',
                      style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                    ),
                    value: hidePlayerList,
                    activeTrackColor: colors.primary,
                    onChanged: (val) => setModalState(() => hidePlayerList = val),
                  ),
                ),
                AppSpacing.gapH16,
                ElevatedButton(
                  onPressed: () async {
                    final slots = int.tryParse(slotsCtl.text) ?? 1;
                    final cost = double.tryParse(costCtl.text.replaceAll(',', '')) ?? 0.0;
                    final femCost = double.tryParse(femaleCostCtl.text.replaceAll(',', '')) ?? (cost - 10000).clamp(0.0, cost);
                    final femDiscount = (cost - femCost).clamp(0.0, cost);
                    Navigator.of(ctx).pop();

                    final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
                    final ok = await vm.createRecruitment(
                      CreateRecruitmentParams(
                        sessionId: widget.sessionId,
                        slotsNeeded: slots,
                        minSkillLevel: selectedLevel.code,
                        sharedCost: cost,
                        femaleSharedCost: femCost,
                        femaleDiscount: femDiscount,
                        scanRadiusKm: radiusKm,
                        hidePlayerList: hidePlayerList,
                      ),
                    );

                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(activeRecruitment != null
                              ? 'Đã cập nhật tin tuyển người chơi thành công!'
                              : 'Đã đăng tin tuyển người chơi thành công!'),
                          backgroundColor: colors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  child: Text(
                    activeRecruitment != null ? 'Cập Nhật Tin Tuyển Vãng Lai' : 'Đăng Tin Tuyển Vãng Lai',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildQuickPassChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary.withValues(alpha: 0.15) : colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.primary : colors.cardBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? colors.primary : colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _showPassCourtModal(BuildContext context, Session session) {
    final colors = context.colors;
    final courtRentalCost = session.courtRentalCost > 0 ? session.courtRentalCost.toInt() : 300000;
    final passPriceCtl = TextEditingController(
      text: _courtPassPrice > 0 ? _courtPassPrice.toString() : courtRentalCost.toString(),
    );
    final contactPhoneCtl = TextEditingController(text: _courtPassPhone);
    final noteCtl = TextEditingController(
      text: _courtPassNote.isNotEmpty
          ? _courtPassNote
          : 'Sân thảm tiêu chuẩn, ánh sáng tốt. CLB bận việc đột xuất cần pass lại giờ sân.',
    );
    final userProfile = ref.read(currentUserProfileProvider);
    if (contactPhoneCtl.text.isEmpty && userProfile?.phoneNumber != null && userProfile!.phoneNumber!.isNotEmpty) {
      contactPhoneCtl.text = userProfile.phoneNumber!;
    }

    int discountPercent = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.base,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.base,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  AppSpacing.gapH16,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.swap_horiz_rounded, color: colors.accent, size: 22),
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCourtPassActive ? 'Điều Chỉnh Tin Pass Sân' : 'Chuyển Nhượng / Pass Sân Cố Định',
                              style: AppTypography.titleMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Sang nhượng lại giờ sân cho nhóm khác khi CLB không đủ người chơi',
                              style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapH16,
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: colors.primary),
                            AppSpacing.gapW8,
                            Expanded(
                              child: Text(
                                session.courtLocation,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapH8,
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 16, color: colors.textSecondary),
                            AppSpacing.gapW8,
                            Text(
                              '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm, dd/MM/yyyy').format(session.endTime)} (${session.courtCount} sân)',
                              style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                        AppSpacing.gapH8,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Giá gốc CLB thuê:',
                              style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(courtRentalCost)} đ',
                              style: AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapH16,
                  Text(
                    'Giá Pass Lại Cho Nhóm Khác (VNĐ)',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.gapH8,
                  TextFormField(
                    controller: passPriceCtl,
                    keyboardType: TextInputType.number,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.payments_outlined, color: colors.primary),
                      suffixText: 'đ',
                      suffixStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: colors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.input,
                        borderSide: BorderSide(color: colors.inputBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  AppSpacing.gapH8,
                  Row(
                    children: [
                      _buildQuickPassChip(
                        label: '100% Giá gốc',
                        isSelected: discountPercent == 0,
                        onTap: () {
                          setModalState(() {
                            discountPercent = 0;
                            passPriceCtl.text = courtRentalCost.toString();
                          });
                        },
                      ),
                      AppSpacing.gapW8,
                      _buildQuickPassChip(
                        label: 'Giảm 15% (Pass nhanh)',
                        isSelected: discountPercent == 15,
                        onTap: () {
                          setModalState(() {
                            discountPercent = 15;
                            final discounted = (courtRentalCost * 0.85).round();
                            passPriceCtl.text = discounted.toString();
                          });
                        },
                      ),
                      AppSpacing.gapW8,
                      _buildQuickPassChip(
                        label: 'Giảm 30% (Cứu vốn)',
                        isSelected: discountPercent == 30,
                        onTap: () {
                          setModalState(() {
                            discountPercent = 30;
                            final discounted = (courtRentalCost * 0.70).round();
                            passPriceCtl.text = discounted.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  AppSpacing.gapH16,
                  Text(
                    'Số điện thoại / Zalo nhận liên hệ',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.gapH8,
                  TextFormField(
                    controller: contactPhoneCtl,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại trưởng sân...',
                      prefixIcon: Icon(Icons.phone_outlined, color: colors.textSecondary),
                      filled: true,
                      fillColor: colors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.input,
                        borderSide: BorderSide(color: colors.inputBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  AppSpacing.gapH16,
                  Text(
                    'Ghi chú cho bên nhận pass',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.gapH8,
                  TextFormField(
                    controller: noteCtl,
                    maxLines: 2,
                    style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tình trạng sân, loại thảm, ánh sáng...',
                      filled: true,
                      fillColor: colors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.input,
                        borderSide: BorderSide(color: colors.inputBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  AppSpacing.gapH16,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.info.withValues(alpha: 0.1),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: colors.info.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: colors.info),
                        AppSpacing.gapW8,
                        Expanded(
                          child: Text(
                            'Khi nhóm khác nhận sân và thanh toán, số tiền pass sân sẽ được tự động cộng vào Quỹ CLB (Club Ledger) để cấn trừ chi phí thuê sân của ca này.',
                            style: AppTypography.labelSmall.copyWith(color: colors.info, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapH16,
                  ElevatedButton(
                    onPressed: () {
                      final price = int.tryParse(passPriceCtl.text.replaceAll(',', '')) ?? courtRentalCost;
                      final phone = contactPhoneCtl.text.trim();
                      final note = noteCtl.text.trim();
                      Navigator.of(ctx).pop();

                      setState(() {
                        _isCourtPassActive = true;
                        _courtPassPrice = price;
                        _courtPassPhone = phone;
                        _courtPassNote = note;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã đăng tin Pass Sân (${NumberFormat('#,###').format(price)} đ) lên Radar thành công!',
                          ),
                          backgroundColor: colors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      textStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      elevation: 0,
                    ),
                    child: Text(_isCourtPassActive ? 'Cập Nhật Tin Pass Sân' : 'Đăng Tin Pass Sân Lên Radar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionDetailViewModelProvider(widget.sessionId));
    final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
    final colors = context.colors;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (state.detail == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(context.l10n.session_detail),
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: colors.error, size: 48),
              AppSpacing.gapH12,
              Text(
                state.errorMessage ?? context.l10n.error_not_found,
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              AppSpacing.gapH16,
              ElevatedButton(
                onPressed: vm.loadDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                child: Text(context.l10n.com_retry),
              ),
            ],
          ),
        ),
      );
    }

    final detail = state.detail!;
    final session = detail.session;
    final confirmedCount = detail.confirmedPlayers.length;
    final waitingCount = detail.waitingQueue.length;

    final activeContext = ref.watch(activeClubContextProvider);
    final isSameClub = activeContext?.clubId == session.groupId;
    final isHost = isSameClub && activeContext?.role == ClubRole.host;
    final isTreasurer = isSameClub && activeContext?.role == ClubRole.treasurer;
    final isDeputy = isSameClub && activeContext?.role == ClubRole.deputy;
    final canManageSession = isHost || (isSameClub && ref.hasClubPermission('OPERATIONS.SESSION.UPDATE'));
    final canDeleteSession = isHost || (isSameClub && ref.hasClubPermission('OPERATIONS.SESSION.DELETE'));
    final canRecruit = isHost || (isSameClub && (ref.hasClubPermission('OPERATIONS.RECRUIT.MANAGE') || ref.hasClubPermission('OPERATIONS.SESSION.UPDATE')));
    final canOperateAttendance = isHost || isDeputy || isTreasurer || (isSameClub && ref.hasClubPermission('OPERATIONS.BOOKING.MANAGE'));
    final canOperateRotation = isHost || isDeputy || (isSameClub && ref.hasClubPermission('OPERATIONS.MATCH.MANAGE'));
    final canOperateSettlement = isHost || isTreasurer || (isSameClub && ref.hasClubPermission('FINANCE.FEE.MANAGE'));
    final canOperateSession = canOperateAttendance || canOperateRotation || canOperateSettlement || canManageSession;
    final hasAnySessionManagePerm = canManageSession || canDeleteSession || canRecruit;

    final myClubs = ref.watch(clubContextViewModelProvider).myClubs;
    final isMember = isSameClub || myClubs.any((c) => c.clubId == session.groupId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              session.clubName,
              style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.loadDetail,
            tooltip: context.l10n.com_refresh,
          ),
          if (hasAnySessionManagePerm && session.status != SessionStatus.completed)
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Tác vụ quản lý',
              onPressed: () => _showHostActionSheet(
                context,
                session,
                canManageSession: canManageSession,
                canRecruit: canRecruit,
                canDeleteSession: canDeleteSession,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context, session, state.isSubmitting),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final feeRuleAsync = ref.watch(clubFeeRuleProvider(session.groupId));
                    final feeRule = feeRuleAsync.asData?.value;
                    final isFeeDynamic = feeRule?.isDynamic ?? true;
                    return _buildSessionHeaderCard(
                      session,
                      detail.activeRecruitment,
                      canManageSession,
                      canRecruit,
                      canDeleteSession,
                      isHost,
                      canOperateSession: canOperateSession,
                      canOperateAttendance: canOperateAttendance,
                      canOperateRotation: canOperateRotation,
                      canOperateSettlement: canOperateSettlement,
                      isMember: isMember,
                      isFeeDynamic: isFeeDynamic,
                      feeRule: feeRule,
                    );
                  },
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SessionTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: colors.primary,
                    unselectedLabelColor: colors.textMuted,
                    indicatorColor: colors.primary,
                    indicatorWeight: 3,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_tennis_rounded, size: 16),
                            AppSpacing.gapW4,
                            Flexible(
                              child: Text(
                                'Chính thức ($confirmedCount/${session.maxPlayers})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hourglass_top_rounded, size: 16),
                            AppSpacing.gapW4,
                            Flexible(
                              child: Text(
                                'Hàng đợi ($waitingCount)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: colors.cardBackground,
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPlayersList(detail.confirmedPlayers, isWaiting: false),
                _buildPlayersList(detail.waitingQueue, isWaiting: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVietQRModal(BuildContext context, Session session, [int? userFee, String? paymentCode]) {
    final colors = context.colors;
    final fee = userFee ?? (session.courtRentalCost ~/ (session.confirmedCount > 0 ? session.confirmedCount : 1));
    final code = paymentCode ?? 'KLTN ${session.id.substring(0, session.id.length >= 8 ? 8 : session.id.length).toUpperCase()}';
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: colors.borderStrong, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              AppSpacing.gapH16,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: colors.primary, size: 24),
                  AppSpacing.gapW8,
                  Text('Thanh Toán Buổi Chơi VietQR', style: AppTypography.titleMedium.copyWith(color: colors.textPrimary)),
                ],
              ),
              AppSpacing.gapH8,
              Text(
                'Quét mã qua app ngân hàng bất kỳ để hệ thống tự động xác nhận đã đóng tiền.',
                style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapH16,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: QrImageView(
                        data: code,
                        version: QrVersions.auto,
                        size: 160.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.neutral900,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    AppSpacing.gapH8,
                    Text(
                      fee > 0 ? '${NumberFormat('#,###').format(fee)} đ' : '0 đ (Miễn phí)',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Cú pháp: $code',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH16,
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã sao chép cú pháp chuyển khoản: $code'),
                      backgroundColor: colors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Sao Chép Cú Pháp Chuyển Khoản'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSession(BuildContext context, SessionDetailViewModel vm) async {
    final colors = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text(
          'Hủy Buổi Chơi',
          style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          'Hành động này sẽ hủy buổi chơi vĩnh viễn và thông báo tới toàn bộ người đã đăng ký.',
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.com_delete),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await vm.deleteSession();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _showSettlementRequiredDialog(BuildContext context, Session session) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text(
          'Yêu Cầu Chốt Sổ Chi Phí',
          style: AppTypography.titleMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Theo quy định, buổi chơi cần được hạch toán chi phí (số cầu bóc mới, phụ phí) và phát hành quyết toán thu tiền (VietQR) trước khi kết thúc buổi chơi.',
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            icon: const Icon(Icons.calculate_outlined, size: 18),
            label: const Text('Đến trang tổng kết chi phí'),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/session/${session.id}/settlement');
            },
          ),
        ],
      ),
    );
  }

  void _showHostActionSheet(
    BuildContext context,
    Session session, {
    GuestRecruitment? activeRecruitment,
    required bool canManageSession,
    required bool canRecruit,
    required bool canDeleteSession,
  }) {
    final colors = context.colors;
    final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
    final now = DateTime.now();
    final isEnded = session.status == SessionStatus.completed ||
        session.status == SessionStatus.calculated ||
        session.endTime.isBefore(now);
    final isPlaying = !isEnded && (session.status == SessionStatus.playing ||
        (session.startTime.isBefore(now) && session.endTime.isAfter(now)));
    final isExpired = session.isExpired || session.deadlineBooking.isBefore(now);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.gapH12,
              Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: colors.primary, size: 22),
                  AppSpacing.gapW8,
                  Text(
                    'Tác Vụ Điều Hành Buổi Chơi',
                    style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              if (canRecruit && session.status == SessionStatus.open && !isEnded && !isPlaying && !isExpired) ...[
                _buildActionTile(
                  icon: Icons.radar_rounded,
                  color: colors.primary,
                  label: activeRecruitment != null
                      ? (activeRecruitment.slotsRemaining > 0
                          ? 'Đang mở tuyển giao lưu'
                          : 'Đã đủ tay vợt giao lưu')
                      : 'Mở Tuyển Giao Lưu (Radar)',
                  subtitle: activeRecruitment != null
                      ? (activeRecruitment.slotsRemaining > 0
                          ? 'Bài tuyển đang hoạt động. Bấm để điều chỉnh'
                          : 'Đã đủ số người cần tuyển. Bấm để xem hoặc đóng tin')
                      : 'Tìm kiếm tay vợt giao lưu lân cận bù slot thiếu',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showRecruitmentModal(context, session, activeRecruitment: activeRecruitment);
                  },
                ),
                _buildActionTile(
                  icon: Icons.swap_horiz_rounded,
                  color: colors.accent,
                  label: _isCourtPassActive ? 'Đang Đăng Pass Sân' : 'Chuyển Nhượng / Pass Sân (Radar)',
                  subtitle: _isCourtPassActive
                      ? 'Đang đăng sang nhượng giờ sân trên Radar. Bấm để điều chỉnh hoặc hủy'
                      : 'Sang nhượng toàn bộ giờ sân cho nhóm khác khi CLB không đủ người chơi',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showPassCourtModal(context, session);
                  },
                ),
              ],
              if (canManageSession) ...[
                if (session.status == SessionStatus.open)
                  _buildActionTile(
                    icon: Icons.lock_outline_rounded,
                    color: colors.warning,
                    label: 'Chốt Danh Sách Thi Đấu',
                    subtitle: 'Khóa đăng ký để chuẩn bị ra sân thi đấu',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      vm.updateStatus('LOCKED');
                    },
                  )
                else if (session.status == SessionStatus.locked)
                  _buildActionTile(
                    icon: Icons.lock_open_rounded,
                    color: colors.primary,
                    label: 'Mở lại đăng ký',
                    subtitle: 'Cho phép thành viên tiếp tục đăng ký',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      vm.updateStatus('OPEN');
                    },
                  ),
                if (session.status != SessionStatus.playing && session.status != SessionStatus.completed)
                  _buildActionTile(
                    icon: Icons.play_circle_outline_rounded,
                    color: colors.success,
                    label: 'Bắt Đầu Buổi Thi Đấu',
                    subtitle: 'Chuyển sang trạng thái đang đánh trên sân',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      vm.updateStatus('PLAYING');
                    },
                  ),
                if (session.status != SessionStatus.completed)
                  _buildActionTile(
                    icon: Icons.check_circle_outline_rounded,
                    color: colors.textMuted,
                    label: 'Kết thúc buổi chơi',
                    subtitle: 'Hoàn tất và lưu lịch sử buổi chơi',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      if (session.status != SessionStatus.calculated && session.status != SessionStatus.completed) {
                        _showSettlementRequiredDialog(context, session);
                      } else {
                        vm.updateStatus('COMPLETED');
                      }
                    },
                  ),
                if (isEnded ||
                    session.status == SessionStatus.playing ||
                    session.status == SessionStatus.locked ||
                    session.status == SessionStatus.calculated ||
                    session.status == SessionStatus.completed)
                  _buildActionTile(
                    icon: Icons.receipt_long_rounded,
                    color: colors.primary,
                    label: 'Tổng Kết & Phân Bổ Chi Phí',
                    subtitle: 'Tính tiền thực tế sân, cầu bóc mới, ưu đãi Nữ',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/session/${session.id}/settlement');
                    },
                  ),
              ],
              if (canDeleteSession) ...[
                const Divider(),
                _buildActionTile(
                  icon: Icons.delete_outline_rounded,
                  color: colors.error,
                  label: 'Hủy buổi chơi này',
                  subtitle: 'Hủy vĩnh viễn và thông báo cho người tham gia',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDeleteSession(context, vm);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeaderCard(
    Session session,
    GuestRecruitment? activeRecruitment,
    bool canManageSession,
    bool canRecruit,
    bool canDeleteSession,
    bool isHost, {
    required bool canOperateSession,
    required bool canOperateAttendance,
    required bool canOperateRotation,
    required bool canOperateSettlement,
    required bool isMember,
    bool isFeeDynamic = true,
    ClubFeeRule? feeRule,
  }) {
    final colors = context.colors;
    final now = DateTime.now();
    final isEnded = session.status == SessionStatus.completed ||
        session.status == SessionStatus.calculated ||
        session.endTime.isBefore(now);
    final isPlaying = !isEnded && (session.status == SessionStatus.playing ||
        (session.startTime.isBefore(now) && session.endTime.isAfter(now)));
    final isExpired = session.endTime.isBefore(now) || (session.status != SessionStatus.open && session.status != SessionStatus.locked);

    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    final timeStr = '${DateFormat('HH:mm').format(session.startTime)} - ${dateFormat.format(session.endTime)}';
    final weekdayStr = _getWeekdayName(session.startTime);
    final dateStr = '$weekdayStr, ${DateFormat('dd/MM/yyyy').format(session.startTime)}';
    final progress = session.maxPlayers > 0 ? (session.confirmedCount / session.maxPlayers).clamp(0.0, 1.0) : 0.0;
    final isFull = session.isFull;

    final feePerPlayer = session.maxPlayers > 0
        ? (session.courtRentalCost / session.maxPlayers).round()
        : 0;

    return Container(
      width: double.infinity,
      color: colors.cardBackground,
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Club Tag + Status Badge (Responsive Wrap to prevent overflow)
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.tag,
                    border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: colors.primary),
                      AppSpacing.gapW4,
                      Flexible(
                        child: Text(
                          session.clubName,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (activeRecruitment != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.tag,
                          border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.radar_rounded, size: 12, color: colors.primary),
                            AppSpacing.gapW4,
                            Text(
                              'Tuyển khách giao lưu',
                              style: AppTypography.labelSmall.bold.colored(colors.primary),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: AppRadius.tag,
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 12, color: colors.textMuted),
                            AppSpacing.gapW4,
                            Text(
                              'Nội bộ CLB',
                              style: AppTypography.labelSmall.bold.colored(colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    _buildStatusBadge(session.status, isEnded, isPlaying),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapH12,

          // Date & Time Banner
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
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(Icons.calendar_month_rounded, color: colors.primary, size: 20),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      AppSpacing.gapH4,
                      Text(
                        timeStr,
                        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH8,

          // Court location with Copy action
          InkWell(
            onTap: () {
              final copyTarget = (session.address != null &&
                      session.address!.isNotEmpty &&
                      session.address != session.courtLocation)
                  ? ' - '
                  : session.courtLocation;
              Clipboard.setData(ClipboardData(text: copyTarget));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã sao chép địa chỉ sân đấu vào bộ nhớ tạm'),
                  backgroundColor: colors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.location_on_rounded, size: 16, color: colors.primary),
                  ),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.courtLocation,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (session.address != null &&
                            session.address!.isNotEmpty &&
                            session.address != session.courtLocation) ...[
                          AppSpacing.gapH4,
                          Text(
                            session.address!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.textMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.copy_rounded, size: 14, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapH8,

          // Quy mô sân, Tiền sân gốc & Chi phí phát sinh
          Builder(
            builder: (context) {
              final settlementAsync = isFeeDynamic ? ref.watch(sessionSettlementProvider(session.id)) : null;
              final settlement = settlementAsync?.asData?.value;
              final shuttleCost = (settlement != null && settlement.shuttlecockUsed > 0)
                  ? settlement.shuttlecockUsed * settlement.shuttlecockPrice
                  : 0;
              final extraFee = settlement?.extraFee ?? 0;
              final hasExtraCosts = shuttleCost > 0 || extraFee > 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quy mô sân đấu', style: AppTypography.labelSmall.copyWith(color: colors.textMuted)),
                              AppSpacing.gapH4,
                              Text(
                                '${session.courtCount} sân (${session.targetPlayerPerCourt} ng/sân)',
                                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isFeeDynamic) ...[
                        AppSpacing.gapW8,
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: colors.surfaceSubtle,
                              borderRadius: AppRadius.borderSm,
                              border: Border.all(color: colors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tiền thuê sân', style: AppTypography.labelSmall.copyWith(color: colors.textMuted)),
                                AppSpacing.gapH4,
                                Text(
                                  session.courtRentalCost > 0 ? '${NumberFormat('#,###').format(session.courtRentalCost)} đ' : '0 đ (Chờ chốt)',
                                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isFeeDynamic && hasExtraCosts) ...[
                    AppSpacing.gapH8,
                    Row(
                      children: [
                        if (shuttleCost > 0)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.sports_tennis_rounded, size: 12, color: AppColors.info),
                                      AppSpacing.gapW4,
                                      Expanded(
                                        child: Text(
                                          'Tiền cầu (${settlement!.shuttlecockUsed} quả)',
                                          style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '${NumberFormat('#,###').format(shuttleCost)} đ',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (shuttleCost > 0 && extraFee > 0) AppSpacing.gapW8,
                        if (extraFee > 0)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_drink_rounded, size: 12, color: colors.warning),
                                      AppSpacing.gapW4,
                                      Expanded(
                                        child: Text(
                                          'Phụ phí phát sinh',
                                          style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '${NumberFormat('#,###').format(extraFee)} đ',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          AppSpacing.gapH12,

          // Bảng phím tắt nghiệp vụ tại sân (Ban Điều Hành) - Hiển thị đúng Role & Trạng thái chơi
          if (canOperateSession) ...[
            Container(
              padding: AppSpacing.allBase,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_tennis_rounded, color: colors.primary, size: 20),
                          AppSpacing.gapW8,
                          Text(
                            'Trung Tâm Điều Phối Trận Đấu',
                            style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: AppRadius.tag,
                        ),
                        child: Text('Bàn Điều Phối', style: AppTypography.labelSmall.bold.colored(colors.primary)),
                      ),
                    ],
                  ),
                  AppSpacing.gapH12,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Check-in ra sân
                      if (canOperateAttendance &&
                          session.status != SessionStatus.completed &&
                          (session.status == SessionStatus.playing || session.status == SessionStatus.locked || (now.isAfter(session.startTime) && now.isBefore(session.endTime))))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: AppColors.white,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                          ),
                          icon: const Icon(Icons.how_to_reg_rounded, size: 16),
                          label: const Text('Check-in Ra Sân'),
                          onPressed: () => context.push('/session/${session.id}/attendance'),
                        ),
                      // Xoay tua sân: chỉ khi đang trong giờ chơi (playing hoặc locked)
                      if (canOperateRotation &&
                          (session.status == SessionStatus.playing || session.status == SessionStatus.locked))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.success,
                            foregroundColor: AppColors.white,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                          ),
                          icon: const Icon(Icons.sports_tennis_rounded, size: 16),
                          label: const Text('Xoay Tua Sân Đấu'),
                          onPressed: () => context.push('/session/${session.id}/rotation'),
                        ),
                      // Tổng kết chi phí & Thu phí: khi đang chơi, khóa sổ hoặc kết thúc
                      if (canOperateSettlement &&
                          (isEnded ||
                              session.status == SessionStatus.playing ||
                              session.status == SessionStatus.locked ||
                              session.status == SessionStatus.calculated ||
                              session.status == SessionStatus.completed))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: AppColors.white,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                          ),
                          icon: const Icon(Icons.receipt_long_rounded, size: 16),
                          label: const Text('Tổng Kết Chi Phí'),
                          onPressed: () => context.push('/session/${session.id}/settlement'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.gapH12,
          ],

          // Đánh giá buổi chơi: Chỉ hiển thị khi buổi kết thúc VÀ người chơi là khách vãng lai (!isMember)
          if (session.status == SessionStatus.completed && !isMember) ...[
            Container(
              padding: AppSpacing.allBase,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, size: 24, color: colors.warning),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đánh giá buổi chơi',
                          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          'Chia sẻ cảm nhận về sân bãi và văn hóa chơi để hoàn tất buổi giao lưu.',
                          style: AppTypography.bodySmall.colored(colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapW8,
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.warning,
                      side: BorderSide(color: colors.warning),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                    label: const Text('Đánh giá'),
                    onPressed: () => context.push('/session/${session.id}/reviews'),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH12,
          ],
          // Cơ chế phân bổ chi phí
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 16, color: colors.primary),
                    AppSpacing.gapW8,
                    Text(
                      !isMember ? 'Chi phí tham gia giao lưu' : 'Phân bổ chi phí',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.tag,
                      ),
                      child: Text(
                        !isMember
                            ? 'Khách giao lưu'
                            : (isFeeDynamic ? 'Chia thực tế' : 'Định mức cố định'),
                        style: AppTypography.labelSmall.bold.colored(colors.primary),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH8,
                Text(
                  !isMember
                      ? (isFeeDynamic
                          ? 'Chi phí dự kiến cho khách vãng lai giao lưu buổi này (chia sẻ sân cầu và ưu đãi Nữ).'
                          : 'Biểu phí giao lưu cố định dành cho khách vãng lai tham gia buổi sinh hoạt.')
                      : (isFeeDynamic
                          ? 'Chia đều toàn bộ chi phí thực tế (sân, cầu bóc mới, phụ phí) cho các tay vợt. Ưu đãi giảm trừ thẳng cho Nữ.'
                          : 'Áp dụng biểu giá cố định: Hội viên tháng (trọn gói), Hội viên ngày và Khách vãng lai tính theo mức cố định của CLB.'),
                  style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                ),
                AppSpacing.gapH8,
                if (!isMember)
                  // Khách vãng lai: chỉ xem duy nhất biểu giá áp dụng cho khách giao lưu (Nam & Nữ)
                  Builder(
                    builder: (context) {
                      final guestMaleFee = activeRecruitment != null
                          ? activeRecruitment.maleCost.toInt()
                          : (isFeeDynamic ? (feePerPlayer > 0 ? (feePerPlayer * 1.25).round() : 50000) : (feeRule?.guestFee.toInt() ?? 60000));
                      final femaleDiscount = isFeeDynamic
                          ? (feeRule?.femaleDiscountDaily.toInt() ?? 10000)
                          : (feeRule?.femaleDiscountGuest.toInt() ?? 10000);
                      final guestFemaleFee = activeRecruitment != null
                          ? activeRecruitment.femaleCost.toInt()
                          : (guestMaleFee - femaleDiscount).clamp(0, guestMaleFee);

                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.male_rounded, size: 14, color: AppColors.info),
                                      AppSpacing.gapW4,
                                      Text(
                                        'Khách Nam',
                                        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '${NumberFormat('#,###').format(guestMaleFee)} đ/buổi',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.info),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.gapW8,
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.female_rounded, size: 14, color: AppColors.pink),
                                      AppSpacing.gapW4,
                                      Text(
                                        'Khách Nữ (Ưu đãi)',
                                        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.pink),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '${NumberFormat('#,###').format(guestFemaleFee)} đ/buổi',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.pink),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else if (isFeeDynamic)
                  Builder(
                    builder: (context) {
                      final detail = ref.watch(sessionDetailViewModelProvider(widget.sessionId)).detail;
                      final confirmedPlayers = detail?.confirmedPlayers ?? [];
                      final confirmedCount = confirmedPlayers.isNotEmpty
                          ? confirmedPlayers.length
                          : (session.confirmedCount > 0 ? session.confirmedCount : (session.maxPlayers > 0 ? session.maxPlayers : 1));
                      final femaleCount = confirmedPlayers.where((p) => PlayerGenderHelper.isFemale(explicitGender: p.gender)).length;
                      final disc = feeRule?.femaleDiscountDaily.toInt() ?? 10000;

                      final settlementAsync = ref.watch(sessionSettlementProvider(session.id));
                      final settlement = settlementAsync.asData?.value;
                      final totalCost = settlement?.totalCost ?? session.courtRentalCost.round();

                      final feeResult = SessionFeeCalculator.calculate(
                        totalCost: totalCost,
                        totalPlayers: confirmedCount,
                        femaleCount: femaleCount,
                        femaleDiscount: disc,
                        roundRule: 1000,
                      );

                      final actualFinalFee = feeResult.maleFee;
                      final displayFee = isEnded && actualFinalFee > 0 ? actualFinalFee : (feePerPlayer > 0 ? feePerPlayer : 40000);
                      final feeTitle = isEnded ? 'Chia thực tế (Chốt)' : 'Chia đều tay vợt';
                      final feePrefix = isEnded ? '' : '~';

                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.groups_rounded, size: 12, color: colors.primary),
                                      AppSpacing.gapW4,
                                      Expanded(
                                        child: Text(
                                          feeTitle,
                                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '$feePrefix${NumberFormat('#,###').format(displayFee)} đ/người',
                                    style: AppTypography.labelSmall.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.gapW8,
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.female_rounded, size: 12, color: AppColors.pink),
                                      AppSpacing.gapW4,
                                      Expanded(
                                        child: Text(
                                          'Ưu đãi Nữ',
                                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.pink),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    isEnded && feeResult.femaleFee > 0
                                        ? '${NumberFormat('#,###').format(feeResult.femaleFee)} đ/người'
                                        : '-${NumberFormat('#,###').format(disc)} đ/người',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.pink, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: AppRadius.borderSm,
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.verified_user_outlined, size: 12, color: colors.success),
                                  AppSpacing.gapW4,
                                  Expanded(
                                    child: Text(
                                      'HV Tháng',
                                      style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.gapH4,
                              Text(
                                '0 đ (Trọn gói)',
                                style: AppTypography.labelSmall.copyWith(color: colors.success, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.gapW8,
                      Builder(
                        builder: (context) {
                          final dailyFee = feeRule?.dailyMemberFee.toInt() ?? 40000;
                          final dailyDisc = feeRule?.femaleDiscountDaily.toInt() ?? 10000;
                          final dailyFemale = (dailyFee - dailyDisc).clamp(0, dailyFee);

                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.sports_tennis_rounded, size: 12, color: colors.primary),
                                      AppSpacing.gapW4,
                                      Expanded(
                                        child: Text(
                                          'HV Ngày',
                                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '${NumberFormat('#,###').format(dailyFee)} đ',
                                    style: AppTypography.labelSmall.copyWith(color: colors.primary, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (dailyDisc > 0) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      'Nữ: ${NumberFormat('#,###').format(dailyFemale)} đ',
                                      style: AppTypography.labelSmall.copyWith(color: AppColors.pink, fontWeight: FontWeight.bold, fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      AppSpacing.gapW8,
                      Builder(
                        builder: (context) {
                          final guestFee = activeRecruitment != null
                              ? activeRecruitment.maleCost.toInt()
                              : (feeRule?.guestFee.toInt() ?? 60000);
                          final guestFemaleFee = activeRecruitment != null
                              ? activeRecruitment.femaleCost.toInt()
                              : ((feeRule?.guestFee ?? 60000) - (feeRule?.femaleDiscountGuest ?? 10000)).clamp(0, 999999).toInt();

                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.people_outline_rounded, size: 12, color: colors.warning),
                                      AppSpacing.gapW4,
                                      Expanded(
                                        child: Text(
                                          'Khách Giao Lưu',
                                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.gapH4,
                                  Text(
                                    '${NumberFormat('#,###').format(guestFee)} đ',
                                    style: AppTypography.labelSmall.copyWith(color: colors.warning, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Nữ: ${NumberFormat('#,###').format(guestFemaleFee)} đ',
                                    style: AppTypography.labelSmall.copyWith(color: AppColors.pink, fontWeight: FontWeight.bold, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          AppSpacing.gapH12,

          // Booking Deadline Warning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: session.isExpired ? colors.error.withValues(alpha: 0.08) : colors.surfaceSubtle,
              borderRadius: AppRadius.borderSm,
              border: Border.all(
                color: session.isExpired ? colors.error.withValues(alpha: 0.25) : colors.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  session.isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
                  size: 15,
                  color: session.isExpired ? colors.error : colors.textMuted,
                ),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    session.isExpired
                        ? 'Đã hết hạn giữ chỗ: ${DateFormat('HH:mm, dd/MM').format(session.deadlineBooking)}'
                        : 'Hạn chốt giữ chỗ: ${DateFormat('HH:mm, dd/MM').format(session.deadlineBooking)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: session.isExpired ? colors.error : colors.textMuted,
                      fontWeight: session.isExpired ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapH12,

          // Sĩ số Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.borderXs,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colors.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isEnded
                          ? colors.textMuted.withValues(alpha: 0.3)
                          : (isFull ? colors.warning : colors.primary),
                    ),
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Text(
                '${session.confirmedCount}/${session.maxPlayers} slot',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEnded ? colors.textMuted : (isFull ? colors.warning : colors.primary),
                ),
              ),
              if (!isEnded && session.waitingCount > 0) ...[
                AppSpacing.gapW8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: Text(
                    '${session.waitingCount} chờ',
                    style: AppTypography.labelSmall.semiBold.colored(colors.warning),
                  ),
                ),
              ],
            ],
          ),

          // Host Quick Action Strip (Bảng thao tác nhanh cho Host/Quản trị viên)
          if ((canManageSession || canRecruit) && !isEnded && session.status != SessionStatus.completed) ...[
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, size: 16, color: colors.primary),
                      AppSpacing.gapW8,
                      Text(
                        'Thao tác quản trị:',
                        style: AppTypography.labelSmall.bold.colored(colors.primary),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _showHostActionSheet(
                          context,
                          session,
                          activeRecruitment: activeRecruitment,
                          canManageSession: canManageSession,
                          canRecruit: canRecruit,
                          canDeleteSession: canDeleteSession,
                        ),
                        borderRadius: AppRadius.tag,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tất cả tác vụ',
                                style: AppTypography.labelSmall.semiBold.colored(colors.primary),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapH8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (canRecruit && session.status == SessionStatus.open && !isEnded && !isPlaying && !isExpired)
                        ActionChip(
                          avatar: Icon(Icons.radar_rounded, size: 16, color: colors.primary),
                          label: Text(
                            activeRecruitment != null
                                ? (activeRecruitment.slotsRemaining > 0 ? 'Đang tuyển khách' : 'Đã đủ khách')
                                : 'Tuyển khách',
                            style: AppTypography.labelSmall.semiBold.colored(colors.primary),
                          ),
                          backgroundColor: colors.primary.withValues(alpha: 0.1),
                          side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                          onPressed: () => _showRecruitmentModal(context, session, activeRecruitment: activeRecruitment),
                        ),
                      if (canManageSession) ...[
                        if (session.status == SessionStatus.open)
                          ActionChip(
                            avatar: Icon(Icons.lock_outline_rounded, size: 16, color: colors.warning),
                            label: Text(
                              'Chốt danh sách',
                              style: AppTypography.labelSmall.semiBold.colored(colors.warning),
                            ),
                            backgroundColor: colors.warning.withValues(alpha: 0.1),
                            side: BorderSide(color: colors.warning.withValues(alpha: 0.3)),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                            onPressed: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('LOCKED'),
                          ),
                        if (session.status == SessionStatus.locked) ...[
                          ActionChip(
                            avatar: Icon(Icons.lock_open_rounded, size: 16, color: colors.primary),
                            label: Text(
                              'Mở lại',
                              style: AppTypography.labelSmall.semiBold.colored(colors.primary),
                            ),
                            backgroundColor: colors.primary.withValues(alpha: 0.1),
                            side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                            onPressed: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('OPEN'),
                          ),
                          ActionChip(
                            avatar: Icon(Icons.play_circle_outline_rounded, size: 16, color: colors.success),
                            label: Text(
                              'Vào thi đấu',
                              style: AppTypography.labelSmall.semiBold.colored(colors.success),
                            ),
                            backgroundColor: colors.success.withValues(alpha: 0.1),
                            side: BorderSide(color: colors.success.withValues(alpha: 0.3)),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                            onPressed: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('PLAYING'),
                          ),
                        ],
                        if (session.status == SessionStatus.playing)
                          ActionChip(
                            avatar: Icon(Icons.check_circle_outline_rounded, size: 16, color: colors.textPrimary),
                            label: Text(
                              'Kết thúc buổi',
                              style: AppTypography.labelSmall.semiBold.colored(colors.textPrimary),
                            ),
                            backgroundColor: colors.surfaceSubtle,
                            side: BorderSide(color: colors.cardBorder),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                            onPressed: () {
                              if (session.status != SessionStatus.calculated && session.status != SessionStatus.completed) {
                                _showSettlementRequiredDialog(context, session);
                              } else {
                                ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('COMPLETED');
                              }
                            },
                          ),
                        if (isEnded ||
                            session.status == SessionStatus.playing ||
                            session.status == SessionStatus.locked ||
                            session.status == SessionStatus.calculated ||
                            session.status == SessionStatus.completed)
                          ActionChip(
                            avatar: Icon(Icons.calculate_rounded, size: 16, color: colors.primary),
                            label: Text(
                              'Quyết toán',
                              style: AppTypography.labelSmall.semiBold.colored(colors.primary),
                            ),
                            backgroundColor: colors.primary.withValues(alpha: 0.1),
                            side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.tag),
                            onPressed: () => context.push('/session/${session.id}/settlement'),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Recruitment status card (Phân định rõ: Đang tuyển vãng lai vs Không tuyển / Nội bộ vs Pass Sân)
          if (_isCourtPassActive) ...[
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.accent.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ĐANG ĐĂNG PASS SÂN',
                              style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          AppSpacing.gapW8,
                          Text(
                            '${NumberFormat('#,###').format(_courtPassPrice)} đ',
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: colors.accent),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.error,
                          side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() => _isCourtPassActive = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã hủy đăng tin pass sân')),
                          );
                        },
                        child: const Text('Hủy pass', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                  AppSpacing.gapH8,
                  Text(
                    'Tin chuyển nhượng giờ sân đang được phát sóng trên Radar. Khi có nhóm nhận sân, tiền sẽ tự động chuyển vào Quỹ CLB.',
                    style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  if (_courtPassPhone.isNotEmpty) ...[
                    AppSpacing.gapH4,
                    Row(
                      children: [
                        Icon(Icons.phone_rounded, size: 13, color: colors.textMuted),
                        AppSpacing.gapW4,
                        Text('Liên hệ: $_courtPassPhone', style: AppTypography.labelSmall.copyWith(color: colors.textMuted)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (session.status == SessionStatus.open && session.confirmedCount < 4 && !isEnded && !isPlaying && !isExpired && canRecruit && !_isCourtPassActive && activeRecruitment == null) ...[
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: colors.warning),
                      AppSpacing.gapW8,
                      Text(
                        'Ca Đấu Thiếu Người (${session.confirmedCount}/${session.maxPlayers} slot)',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold, color: colors.warning),
                      ),
                    ],
                  ),
                  AppSpacing.gapH4,
                  Text(
                    'Chưa đủ 4 tay vợt ra sân. Hãy Mở Tuyển Vãng Lai để ghép cặp, hoặc Pass Sân lại cho nhóm khác để tránh lãng phí tiền sân cố định.',
                    style: AppTypography.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11.5),
                  ),
                  AppSpacing.gapH8,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRecruitmentModal(context, session, activeRecruitment: activeRecruitment),
                          icon: const Icon(Icons.group_add_rounded, size: 14),
                          label: const Text('Tuyển vãng lai', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      AppSpacing.gapW8,
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPassCourtModal(context, session),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                          label: const Text('Pass sân lại', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            visualDensity: VisualDensity.compact,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.gapH12,
          if (activeRecruitment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.roleViolet.withValues(alpha: 0.08),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.roleViolet.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.roleViolet.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.radar_rounded, size: 20, color: AppColors.roleViolet),
                  ),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              activeRecruitment.slotsRemaining > 0
                                  ? 'ĐANG TUYỂN VÃNG LAI'
                                  : 'ĐÃ ĐỦ SLOT VÃNG LAI',
                              style: AppTypography.labelSmall.bold.colored(AppColors.roleViolet),
                            ),
                            AppSpacing.gapW8,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: activeRecruitment.slotsRemaining > 0
                                    ? AppColors.roleViolet
                                    : colors.textMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                activeRecruitment.slotsRemaining > 0
                                    ? 'Còn ${activeRecruitment.slotsRemaining} chỗ'
                                    : 'Đã nhận đủ',
                                style: AppTypography.labelSmall.bold.colored(AppColors.white),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapH4,
                        if (isFeeDynamic) ...[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 2,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.pie_chart_rounded, size: 14, color: colors.primary),
                                  AppSpacing.gapW4,
                                  Text(
                                    'Chia đều thực tế (~${NumberFormat('#,###').format(feePerPlayer > 0 ? feePerPlayer : 40000)} đ/người)',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              Builder(
                                builder: (context) {
                                  final femDisc = feeRule?.femaleDiscountDaily.toInt() ?? 10000;
                                  if (femDisc <= 0) return const SizedBox.shrink();
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.female_rounded, size: 14, color: AppColors.pink),
                                      AppSpacing.gapW4,
                                      Text(
                                        'Nữ: -${NumberFormat('#,###').format(femDisc)} đ',
                                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.pink),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Text(
                                '• Yêu cầu: ${activeRecruitment.minSkillLevel.displayName}',
                                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ] else ...[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 2,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.male_rounded, size: 14, color: colors.primary),
                                  Text(
                                    'Nam: ${NumberFormat('#,###').format(activeRecruitment.maleCost)} đ',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.female_rounded, size: 14, color: colors.secondary),
                                  Text(
                                    'Nữ: ${NumberFormat('#,###').format(activeRecruitment.femaleCost)} đ',
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              Text(
                                '• Yêu cầu: ${activeRecruitment.minSkillLevel.displayName}',
                                style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (canRecruit)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      onPressed: () async {
                        final ok = await ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).deleteRecruitment();
                        if (ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã đóng tin tuyển vãng lai')),
                          );
                        }
                      },
                      child: const Text('Đóng tuyển'),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: colors.textMuted),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NỘI BỘ • KHÔNG TUYỂN VÃNG LAI',
                          style: AppTypography.labelSmall.bold.colored(colors.textMuted),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          (canRecruit && session.status == SessionStatus.open && !isEnded && !isPlaying && !isExpired)
                              ? 'Chưa mở tuyển vãng lai. Bấm "Tuyển vãng lai" nếu cần thêm người chơi.'
                              : 'Buổi chơi dành riêng cho thành viên trong nhóm.',
                          style: AppTypography.labelSmall.colored(colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (canRecruit && session.status == SessionStatus.open && !isEnded && !isPlaying && !isExpired) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.accent,
                        side: BorderSide(color: colors.accent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                      label: const Text('Pass sân', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      onPressed: () => _showPassCourtModal(context, session),
                    ),
                    AppSpacing.gapW8,
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.group_add_rounded, size: 14),
                      label: const Text('Tuyển vãng lai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showRecruitmentModal(context, session, activeRecruitment: activeRecruitment),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayersList(List<SessionBooking> players, {required bool isWaiting}) {
    final colors = context.colors;
    final currentUserId = ref.watch(currentUserProfileProvider)?.id ?? ref.watch(authTokenProvider)?.userId;
    final detail = ref.watch(sessionDetailViewModelProvider(widget.sessionId)).detail;
    final session = detail?.session;
    final activeContext = ref.watch(activeClubContextProvider);
    final isSameClub = session != null && activeContext?.clubId == session.groupId;
    final isHost = isSameClub && activeContext?.role == ClubRole.host;
    final isTreasurer = isSameClub && activeContext?.role == ClubRole.treasurer;
    final isDeputy = isSameClub && activeContext?.role == ClubRole.deputy;
    final canOperateAttendance = isHost ||
        isDeputy ||
        isTreasurer ||
        (isSameClub &&
            (ref.hasClubPermission('OPERATIONS.BOOKING.MANAGE') ||
                ref.hasClubPermission('OPERATIONS.SESSION.UPDATE')));
    final shouldHidePlayers = (detail?.activeRecruitment?.hidePlayerList ?? false) && !isSameClub && !canOperateAttendance;

    if (shouldHidePlayers) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.visibility_off_rounded, size: 36, color: colors.textMuted),
                    ),
                    AppSpacing.gapH12,
                    Text(
                      'Danh sách người chơi được ẩn',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapH4,
                    Text(
                      'Chủ câu lạc bộ đã bật chế độ bảo mật danh tính thành viên cho buổi chơi này.',
                      style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final isOpen = session?.status == SessionStatus.open;
    final now = DateTime.now();
    final isEnded = session?.status == SessionStatus.completed ||
        session?.status == SessionStatus.calculated ||
        (session != null && session.endTime.isBefore(now));
    final isPlaying = !isEnded && (session?.status == SessionStatus.playing ||
        (session != null && session.startTime.isBefore(now) && session.endTime.isAfter(now)));
    final isExpired = session?.isExpired == true ||
        (session != null && session.deadlineBooking.isBefore(now));
    final canCancel = isOpen && !isEnded && !isPlaying && !isExpired;
    final isSubmitting = ref.watch(sessionDetailViewModelProvider(widget.sessionId)).isSubmitting;

    if (players.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isWaiting ? Icons.hourglass_disabled_rounded : Icons.person_off_outlined,
                      size: 38,
                      color: colors.textMuted,
                    ),
                    AppSpacing.gapH8,
                    Text(
                      isWaiting ? 'Hàng đợi đang trống' : 'Chưa có người chơi chính thức',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapH4,
                    Text(
                      isWaiting
                          ? 'Khi slot chính thức đã đủ, các đăng ký tiếp theo sẽ tự động vào đây.'
                          : 'Hãy là người đầu tiên xác nhận tham gia buổi chơi này!',
                      style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: AppSpacing.screen,
      itemCount: players.length,
      separatorBuilder: (_, _) => AppSpacing.gapH8,
      itemBuilder: (ctx, index) {
        final player = players[index];
        final isMe = currentUserId != null && player.userId.toLowerCase() == currentUserId.toLowerCase();

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: isMe ? colors.primary.withValues(alpha: 0.05) : colors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: BorderSide(
              color: isMe ? colors.primary.withValues(alpha: 0.5) : colors.cardBorder,
              width: isMe ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: isWaiting
                ? Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#${player.queueOrder}',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.warning,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: (player.avatarUrl != null && player.avatarUrl!.isNotEmpty)
                        ? NetworkImage(player.avatarUrl!)
                        : null,
                    child: (player.avatarUrl == null || player.avatarUrl!.isEmpty)
                        ? Text(
                            player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          )
                        : null,
                  ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    player.fullName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.gapW8,
                PlayerGenderHelper.buildGenderBadge(
                  isFemale: PlayerGenderHelper.isFemale(
                    explicitGender: player.gender,
                  ),
                ),
                if (player.recruitmentId != null) ...[
                  AppSpacing.gapW8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text(
                      'Khách',
                      style: AppTypography.labelSmall.semiBold.colored(colors.primary),
                    ),
                  ),
                ],
                if (isMe) ...[
                  AppSpacing.gapW8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text(
                      'Bạn',
                      style: AppTypography.labelSmall.bold.colored(AppColors.white),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Row(
              children: [
                Text(
                  'Đặt: ${DateFormat('HH:mm, dd/MM').format(player.bookedAt)}',
                  style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                ),
                if (player.checkinAt != null) ...[
                  AppSpacing.gapW8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderXs,
                    ),
                    child: Text(
                      'Đã Ra Sân',
                      style: AppTypography.labelSmall.semiBold.colored(colors.success),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWaiting && canOperateAttendance && isOpen && !isEnded) ...[
                  FilledButton.icon(
                    onPressed: isSubmitting ? null : () => _handleConfirmBooking(player),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                    label: const Text('Duyệt'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                  ),
                  AppSpacing.gapW8,
                ],
                if (isMe && canCancel) ...[
                  OutlinedButton.icon(
                    onPressed: isSubmitting ? null : _handleCancelBooking,
                    icon: Icon(Icons.cancel_outlined, size: 14, color: colors.error),
                    label: Text(
                      isWaiting ? 'Hủy chờ' : 'Hủy giữ chỗ',
                      style: AppTypography.labelSmall.bold.colored(colors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                  ),
                  AppSpacing.gapW8,
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.tag,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Text(
                    player.skillLevel,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Session session, bool isSubmitting) {
    final colors = context.colors;
    final now = DateTime.now();
    final isEnded = session.status == SessionStatus.completed ||
        session.status == SessionStatus.calculated ||
        session.endTime.isBefore(now);

    final detail = ref.watch(sessionDetailViewModelProvider(widget.sessionId)).detail;
    final currentUserId = ref.watch(currentUserProfileProvider)?.id ?? ref.watch(authTokenProvider)?.userId;

    final isUserInConfirmed = currentUserId != null && detail != null &&
        detail.confirmedPlayers.any((p) => p.userId.toLowerCase() == currentUserId.toLowerCase());
    final isUserInWaiting = currentUserId != null && detail != null &&
        detail.waitingQueue.any((p) => p.userId.toLowerCase() == currentUserId.toLowerCase());

    final isBooked = session.isBookedByCurrentUser || isUserInConfirmed || isUserInWaiting;
    final isPlaying = !isEnded && (session.status == SessionStatus.playing ||
        (session.startTime.isBefore(now) && session.endTime.isAfter(now)));
    final isExpired = session.isExpired || session.deadlineBooking.isBefore(now);

    final isConfirmed = session.currentUserBookingStatus == BookingStatus.confirmed ||
        session.currentUserBookingStatus == BookingStatus.checkedIn ||
        isUserInConfirmed;
    final waitingOrder = session.currentUserQueueOrder > 0
        ? session.currentUserQueueOrder
        : (detail?.waitingQueue.where((p) => p.userId.toLowerCase() == currentUserId?.toLowerCase()).firstOrNull?.queueOrder ?? 1);
    final isOpen = session.status == SessionStatus.open;
    final canCancel = isOpen && !isEnded && !isPlaying && !isExpired;
    final canJoin = isOpen && !isEnded && !isPlaying && !isExpired;

    // 1. Buổi chơi đã kết thúc
    if (isEnded) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: SafeArea(
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: AppSpacing.screen,
                child: isBooked
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.history_rounded, size: 18),
                              label: const Text('Đã kết thúc'),
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.textMuted,
                                side: BorderSide(color: colors.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                              ),
                            ),
                          ),
                          AppSpacing.gapW12,
                          Expanded(
                            flex: 2,
                            child: Builder(
                              builder: (context) {
                                final settlementAsync = ref.watch(sessionSettlementProvider(session.id));
                                final settlement = settlementAsync.asData?.value;
                                final myFeeItem = settlement?.memberFees.where((m) => m.userId.toLowerCase() == currentUserId?.toLowerCase()).firstOrNull;
                                
                                int computedFee = 0;
                                String? paymentCode;
                                if (myFeeItem != null) {
                                  computedFee = myFeeItem.finalFee;
                                  paymentCode = myFeeItem.paymentCode;
                                } else {
                                  final myConfirmedBooking = detail?.confirmedPlayers.where((p) => p.userId.toLowerCase() == currentUserId?.toLowerCase()).firstOrNull;
                                  final isFem = PlayerGenderHelper.isFemale(
                                    explicitGender: myConfirmedBooking?.gender,
                                  );
                                  final feeRule = ref.watch(clubFeeRuleProvider(session.groupId)).asData?.value;
                                  final confirmedPlayers = detail?.confirmedPlayers ?? [];
                                  final totalP = confirmedPlayers.isNotEmpty
                                      ? confirmedPlayers.length
                                      : (session.confirmedCount > 0 ? session.confirmedCount : (session.maxPlayers > 0 ? session.maxPlayers : 1));
                                  final femaleCount = confirmedPlayers.where((p) => PlayerGenderHelper.isFemale(explicitGender: p.gender)).length;
                                  final disc = feeRule?.femaleDiscountDaily.toInt() ?? 10000;
                                  final totalCost = settlement?.totalCost ?? session.courtRentalCost.round();

                                  final feeResult = SessionFeeCalculator.calculate(
                                    totalCost: totalCost,
                                    totalPlayers: totalP,
                                    femaleCount: femaleCount,
                                    femaleDiscount: disc,
                                    roundRule: 1000,
                                  );

                                  computedFee = isFem ? feeResult.femaleFee : feeResult.maleFee;
                                }

                                final feeLabel = computedFee > 0 ? '${NumberFormat('#,###').format(computedFee)} đ' : '0 đ (Miễn phí)';

                                return ElevatedButton.icon(
                                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                  label: Text('Thanh Toán: $feeLabel'),
                                  onPressed: () => _showVietQRModal(context, session, computedFee, paymentCode),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: AppRadius.button,
                          border: Border.all(color: colors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 18, color: colors.textMuted),
                            AppSpacing.gapW8,
                            Text(
                              'Buổi chơi này đã kết thúc',
                              style: AppTypography.bodyMedium.bold.colored(colors.textMuted),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(top: BorderSide(color: colors.divider)),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.bottomBar,
      ),
      child: SafeArea(
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: AppSpacing.screen,
              child: isBooked
                  ? (canCancel
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _handleCancelBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.error,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.cancel_outlined, size: 18, color: AppColors.white),
                                      AppSpacing.gapW8,
                                      Text(
                                        isConfirmed ? 'Hủy Giữ Chỗ' : 'Hủy Hàng Đợi (#$waitingOrder)',
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: AppRadius.button,
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPlaying ? Icons.sports_tennis_rounded : Icons.lock_clock_rounded,
                                size: 18,
                                color: isPlaying ? colors.primary : colors.textMuted,
                              ),
                              AppSpacing.gapW8,
                              Text(
                                isPlaying
                                    ? 'Buổi chơi đang diễn ra • Không thể hủy slot'
                                    : 'Đã hết hạn đổi vé • Vui lòng liên hệ Host',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ))
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (!canJoin || isSubmitting) ? null : _handleVote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (!canJoin)
                              ? colors.surfaceSubtle
                              : (session.isFull ? colors.warning : colors.primary),
                          foregroundColor: (!canJoin) ? colors.textMuted : AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    !canJoin
                                        ? Icons.lock_outline_rounded
                                        : (session.isFull ? Icons.queue_rounded : Icons.sports_tennis_rounded),
                                    size: 18,
                                    color: (!canJoin) ? colors.textMuted : AppColors.white,
                                  ),
                                  AppSpacing.gapW8,
                                  Text(
                                    !isOpen
                                        ? 'Buổi chơi đã đóng đăng ký'
                                        : (isPlaying
                                            ? 'Buổi chơi đang diễn ra'
                                            : (isExpired
                                                ? 'Đã hết hạn đăng ký'
                                                : (session.isFull
                                                    ? 'Vào Hàng Đợi Chờ (Slot #${session.waitingCount + 1})'
                                                    : 'Đăng Ký Tham Gia'))),
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: (!canJoin) ? colors.textMuted : AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status, bool isEnded, bool isPlaying) {
    final colors = context.colors;

    if (isEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surfaceSubtle,
          borderRadius: AppRadius.tag,
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 12, color: colors.textMuted),
            AppSpacing.gapW4,
            Text(
              'ĐÃ KẾT THÚC',
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.textMuted),
            ),
          ],
        ),
      );
    }

    if (isPlaying) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.success.withValues(alpha: 0.15),
          borderRadius: AppRadius.tag,
          border: Border.all(color: colors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.success,
              ),
            ),
            AppSpacing.gapW4,
            Text(
              'ĐANG THI ĐẤU',
              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: colors.success),
            ),
          ],
        ),
      );
    }

    Color bg;
    Color fg;
    switch (status) {
      case SessionStatus.open:
        bg = colors.primary.withValues(alpha: 0.15);
        fg = colors.primary;
        break;
      case SessionStatus.locked:
        bg = colors.warning.withValues(alpha: 0.15);
        fg = colors.warning;
        break;
      default:
        bg = colors.surfaceSubtle;
        fg = colors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.tag),
      child: Text(
        status.displayName,
        style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class _SessionTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  const _SessionTabBarDelegate(this.tabBar, {required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SessionTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}
