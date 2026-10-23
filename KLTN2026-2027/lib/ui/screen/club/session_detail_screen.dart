// lib/ui/screen/club/session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/provider.dart';
import '../../../domain/enums/club_role.dart';
import '../../../domain/entities/session/guest_recruitment.dart';
import '../../../domain/entities/session/session.dart';
import '../../../domain/entities/session/session_booking.dart';
import '../../../domain/enums/session_enums.dart';
import '../../../domain/usecases/session/session_usecases.dart';
import 'session_vm/session_detail_vm.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
              'Buổi chơi đã đủ slot chính thức. Bạn đang ở vị trí chờ số #${booking.queueOrder} trong hàng đợi.\nHệ thống sẽ tự động đôn bạn lên chính thức khi có thành viên báo vắng.',
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
              context.l10n.session_cancel_join,
              style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          context.l10n.session_cancel_confirm,
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
            child: Text(context.l10n.session_cancel_join),
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
            content: Text(context.l10n.com_success),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRecruitmentModal(BuildContext context, Session session) {
    final colors = context.colors;
    final slotsNeeded = (session.maxPlayers - session.confirmedCount).clamp(1, session.maxPlayers);
    final slotsCtl = TextEditingController(text: slotsNeeded.toString());
    final costCtl = TextEditingController(text: '50000');
    SkillLevel selectedLevel = SkillLevel.tb;
    double radiusKm = 5.0;

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
                      'Phát Tín Hiệu Tuyển Khách Giao Lưu (Radar)',
                      style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
                AppSpacing.gapH8,
                Text(
                  'Hệ thống sẽ quét các tay vợt quanh khu vực sân để gửi thông báo mời tham gia bù slot thiếu.',
                  style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                ),
                AppSpacing.gapH16,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số slot cần tuyển',
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
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trình độ yêu cầu',
                            style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                          ),
                          AppSpacing.gapH4,
                          DropdownButtonFormField<SkillLevel>(
                            initialValue: selectedLevel,
                            dropdownColor: colors.cardBackground,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colors.inputFill,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.input,
                                borderSide: BorderSide(color: colors.inputBorder),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: SkillLevel.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  '${s.code} - ${s.displayName}',
                                  style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedLevel = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                Text(
                  'Chi phí chia sẻ sân / khách (VNĐ)',
                  style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
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
                    prefixIcon: Icon(Icons.attach_money_rounded, size: 20, color: colors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                AppSpacing.gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bán kính quét radar:',
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
                AppSpacing.gapH16,
                ElevatedButton(
                  onPressed: () async {
                    final slots = int.tryParse(slotsCtl.text) ?? 1;
                    final cost = double.tryParse(costCtl.text.replaceAll(',', '')) ?? 0.0;
                    Navigator.of(ctx).pop();

                    final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
                    final ok = await vm.createRecruitment(
                      CreateRecruitmentParams(
                        sessionId: widget.sessionId,
                        slotsNeeded: slots,
                        minSkillLevel: selectedLevel.code,
                        sharedCost: cost,
                        scanRadiusKm: radiusKm,
                      ),
                    );

                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đã phát tín hiệu tìm khách giao lưu thành công!'),
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
                    'Xác Nhận Phát Tín Hiệu Radar',
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
    final canManageSession = isHost || (isSameClub && ref.hasClubPermission('OPERATIONS.SESSION.UPDATE'));
    final canDeleteSession = isHost || (isSameClub && ref.hasClubPermission('OPERATIONS.SESSION.DELETE'));
    final canRecruit = isHost || (isSameClub && (ref.hasClubPermission('OPERATIONS.RECRUIT.MANAGE') || ref.hasClubPermission('OPERATIONS.SESSION.UPDATE')));
    final hasAnySessionManagePerm = canManageSession || canDeleteSession || canRecruit;

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
          if (hasAnySessionManagePerm)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              color: colors.cardBackground,
              onSelected: (val) async {
                if (val == 'recruit') {
                  _showRecruitmentModal(context, session);
                } else if (val == 'lock') {
                  await vm.updateStatus('LOCKED');
                } else if (val == 'open') {
                  await vm.updateStatus('OPEN');
                } else if (val == 'play') {
                  await vm.updateStatus('PLAYING');
                } else if (val == 'complete') {
                  await vm.updateStatus('COMPLETED');
                } else if (val == 'delete') {
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
                        'Hành động này sẽ hủy buổi chơi vĩnh viễn và thông báo tới toàn bộ người đã biểu quyết.',
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
              },
              itemBuilder: (ctx) => [
                if (canRecruit)
                  PopupMenuItem(
                    value: 'recruit',
                    child: Row(
                      children: [
                        Icon(Icons.radar_rounded, color: colors.primary, size: 18),
                        AppSpacing.gapW8,
                        Text(
                          'Tuyển khách giao lưu (Radar)',
                          style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                if (canManageSession) ...[
                  if (session.status == SessionStatus.open)
                    PopupMenuItem(
                      value: 'lock',
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 18, color: colors.warning),
                          AppSpacing.gapW8,
                          Text('Khóa sổ biểu quyết (LOCKED)', style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary)),
                        ],
                      ),
                    )
                  else
                    PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          Icon(Icons.lock_open_rounded, size: 18, color: colors.primary),
                          AppSpacing.gapW8,
                          Text('Mở lại biểu quyết (OPEN)', style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 18, color: colors.success),
                        AppSpacing.gapW8,
                        Text('Bắt đầu thi đấu (PLAYING)', style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'complete',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18, color: colors.textMuted),
                        AppSpacing.gapW8,
                        Text('Kết thúc buổi chơi (COMPLETED)', style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary)),
                      ],
                    ),
                  ),
                ],
                if (canDeleteSession) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, color: colors.error, size: 18),
                        AppSpacing.gapW8,
                        Text('Xóa buổi chơi', style: AppTypography.bodyMedium.copyWith(color: colors.error)),
                      ],
                    ),
                  ),
                ],
              ],
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
                child: _buildSessionHeaderCard(session, detail.activeRecruitment, canManageSession, canRecruit),
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
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 18),
                            AppSpacing.gapW4,
                            Text('Chính thức ($confirmedCount/${session.maxPlayers})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.hourglass_empty_rounded, size: 18),
                            AppSpacing.gapW4,
                            Text('Hàng đợi ($waitingCount)'),
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

  Widget _buildSessionHeaderCard(
    Session session,
    GuestRecruitment? activeRecruitment,
    bool canManageSession,
    bool canRecruit,
  ) {
    final colors = context.colors;
    final now = DateTime.now();
    final isEnded = session.status == SessionStatus.completed ||
        session.status == SessionStatus.calculated ||
        session.endTime.isBefore(now);
    final isPlaying = !isEnded && (session.status == SessionStatus.playing ||
        (session.startTime.isBefore(now) && session.endTime.isAfter(now)));

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
          // Header Row: Club Tag + Status Badge
          Row(
            children: [
              Container(
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
                    Text(
                      session.clubName,
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildStatusBadge(session.status, isEnded, isPlaying),
            ],
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
              Clipboard.setData(ClipboardData(text: session.courtLocation));
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
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: colors.primary),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      session.courtLocation,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.copy_rounded, size: 14, color: colors.textMuted),
                ],
              ),
            ),
          ),
          AppSpacing.gapH8,

          // Scale & Pricing Specs Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quy mô sân', style: AppTypography.labelSmall.copyWith(color: colors.textMuted)),
                      AppSpacing.gapH4,
                      Text(
                        '${session.courtCount} sân (${session.targetPlayerPerCourt} ng/sân)',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
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
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dự kiến phí / người', style: AppTypography.labelSmall.copyWith(color: colors.textMuted)),
                      AppSpacing.gapH4,
                      Text(
                        feePerPlayer > 0 ? '~${NumberFormat('#,###').format(feePerPlayer)} đ' : 'Miễn phí',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              if (session.courtRentalCost > 0) ...[
                AppSpacing.gapW8,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng tiền sân', style: AppTypography.labelSmall.copyWith(color: colors.textMuted)),
                        AppSpacing.gapH4,
                        Text(
                          '${NumberFormat('#,###').format(session.courtRentalCost)} đ',
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
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

          // Host Quick Control Strip (Chỉ hiển thị cho Host/Quản trị viên)
          if (canManageSession && !isEnded) ...[
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings_outlined, size: 16, color: colors.primary),
                  AppSpacing.gapW8,
                  Text(
                    'Quản lý buổi chơi:',
                    style: AppTypography.labelSmall.bold.colored(colors.primary),
                  ),
                  const Spacer(),
                  if (session.status == SessionStatus.open)
                    InkWell(
                      onTap: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('LOCKED'),
                      borderRadius: AppRadius.tag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.15),
                          borderRadius: AppRadius.tag,
                        ),
                        child: Text(
                          'Khóa sổ',
                          style: AppTypography.labelSmall.bold.colored(colors.warning),
                        ),
                      ),
                    ),
                  if (session.status == SessionStatus.locked) ...[
                    InkWell(
                      onTap: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('OPEN'),
                      borderRadius: AppRadius.tag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.tag,
                        ),
                        child: Text(
                          'Mở lại',
                          style: AppTypography.labelSmall.bold.colored(colors.primary),
                        ),
                      ),
                    ),
                    AppSpacing.gapW8,
                    InkWell(
                      onTap: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('PLAYING'),
                      borderRadius: AppRadius.tag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.tag,
                        ),
                        child: Text(
                          'Vào thi đấu',
                          style: AppTypography.labelSmall.bold.colored(colors.success),
                        ),
                      ),
                    ),
                  ],
                  if (session.status == SessionStatus.playing)
                    InkWell(
                      onTap: () => ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).updateStatus('COMPLETED'),
                      borderRadius: AppRadius.tag,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.textMuted.withValues(alpha: 0.15),
                          borderRadius: AppRadius.tag,
                        ),
                        child: Text(
                          'Kết thúc buổi',
                          style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Active recruitment banner (Tin tuyển khách vãng lai)
          if (activeRecruitment != null) ...[
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.radar_rounded, size: 20, color: colors.primary),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đang tuyển ${activeRecruitment.slotsRemaining} khách giao lưu',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          'Mức phí: ${NumberFormat('#,###').format(activeRecruitment.sharedCost)} đ • Trình độ ${activeRecruitment.minSkillLevel}',
                          style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (canRecruit)
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () async {
                        final ok = await ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier).deleteRecruitment();
                        if (ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã hủy tin tuyển khách giao lưu')),
                          );
                        }
                      },
                      child: Text('Hủy tin', style: AppTypography.labelSmall.bold.colored(colors.error)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayersList(List<SessionBooking> players, {required bool isWaiting}) {
    final colors = context.colors;
    final currentUserId = ref.watch(currentUserProfileProvider)?.id ?? ref.watch(authTokenProvider)?.userId;

    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isWaiting ? Icons.hourglass_disabled_rounded : Icons.person_off_outlined,
                size: 46,
                color: colors.textMuted,
              ),
              AppSpacing.gapH12,
              Text(
                isWaiting ? 'Hàng đợi đang trống' : 'Chưa có người chơi chính thức',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              AppSpacing.gapH4,
              Text(
                isWaiting
                    ? 'Khi slot chính thức đã đủ, các biểu quyết tiếp theo sẽ tự động vào đây.'
                    : 'Hãy là người đầu tiên biểu quyết giữ chỗ cho buổi chơi này!',
                style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
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
                      'Đã điểm danh',
                      style: AppTypography.labelSmall.semiBold.colored(colors.success),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Container(
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
    final isConfirmed = session.currentUserBookingStatus == BookingStatus.confirmed || isUserInConfirmed;
    final waitingOrder = session.currentUserQueueOrder > 0
        ? session.currentUserQueueOrder
        : (detail?.waitingQueue.where((p) => p.userId.toLowerCase() == currentUserId?.toLowerCase()).firstOrNull?.queueOrder ?? 1);
    final isOpen = session.status == SessionStatus.open;

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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: AppSpacing.screen,
                child: Container(
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: AppSpacing.screen,
              child: isBooked
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isConfirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                    size: 16,
                                    color: isConfirmed ? colors.primary : colors.warning,
                                  ),
                                  AppSpacing.gapW8,
                                  Expanded(
                                    child: Text(
                                      isConfirmed ? 'Bạn đã có slot chính thức' : 'Đang ở hàng đợi số #$waitingOrder',
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isConfirmed ? colors.primary : colors.warning,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.gapH4,
                              Text(
                                'Báo vắng để tự động nhường slot cho hàng đợi',
                                style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapW12,
                        ElevatedButton.icon(
                          onPressed: isSubmitting ? null : _handleCancelBooking,
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(isConfirmed ? 'Báo Vắng' : 'Rút Hàng Đợi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: AppColors.white,
                            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (!isOpen || isSubmitting) ? null : _handleVote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: session.isFull ? colors.warning : colors.primary,
                          foregroundColor: AppColors.white,
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
                                    !isOpen
                                        ? Icons.lock_outline_rounded
                                        : (session.isFull ? Icons.queue_rounded : Icons.sports_tennis_rounded),
                                    size: 18,
                                    color: AppColors.white,
                                  ),
                                  AppSpacing.gapW8,
                                  Text(
                                    !isOpen
                                        ? 'Buổi chơi đã đóng biểu quyết'
                                        : (session.isFull
                                            ? 'Xếp Vào Hàng Đợi Chờ (Slot #${session.waitingCount + 1})'
                                            : 'Biểu Quyết Tham Gia (Vote YES)'),
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
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
