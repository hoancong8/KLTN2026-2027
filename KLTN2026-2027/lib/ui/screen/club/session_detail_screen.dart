// lib/ui/screen/club/session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/provider.dart';
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
                    const Icon(Icons.radar_rounded, color: AppColors.roleViolet, size: 24),
                    AppSpacing.gapW8,
                    Text(
                      context.l10n.explore_tab_recruitments,
                      style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
                AppSpacing.gapH16,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.session_max_players,
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
                            context.l10n.club_level,
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
                                  s.displayName,
                                  style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
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
                  context.l10n.session_fee_per_player,
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
                      'Bán kính phát tín hiệu:',
                      style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                    ),
                    Text(
                      '${radiusKm.toStringAsFixed(1)} km',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.roleViolet,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: radiusKm,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  activeColor: AppColors.roleViolet,
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
                        const SnackBar(
                          content: Text('Đã phát tín hiệu tìm khách giao lưu thành công!'),
                          backgroundColor: AppColors.roleViolet,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roleViolet,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  child: Text(
                    context.l10n.explore_tab_recruitments,
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          session.title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
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
              } else if (val == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: colors.cardBackground,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
                    title: Text(
                      context.l10n.session_status_cancelled,
                      style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                    ),
                    content: Text(
                      'Hành động này sẽ hủy buổi chơi vĩnh viễn và gửi thông báo tới người đã vote.',
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
              PopupMenuItem(
                value: 'recruit',
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: AppColors.roleViolet, size: 18),
                    AppSpacing.gapW8,
                    Text(
                      context.l10n.explore_tab_recruitments,
                      style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
              if (session.status == SessionStatus.open)
                PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 18),
                      AppSpacing.gapW8,
                      Text(
                        'Khóa sổ biểu quyết',
                        style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                      ),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      const Icon(Icons.lock_open, size: 18),
                      AppSpacing.gapW8,
                      Text(
                        'Mở lại biểu quyết',
                        style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'play',
                child: Row(
                  children: [
                    const Icon(Icons.sports_tennis, size: 18),
                    AppSpacing.gapW8,
                    Text(
                      'Bắt đầu thi đấu',
                      style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: colors.error, size: 18),
                    AppSpacing.gapW8,
                    Text(
                      context.l10n.com_delete,
                      style: AppTypography.bodyMedium.copyWith(color: colors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context, session, state.isSubmitting),
      body: Column(
        children: [
          // 1. Session Information Header Card
          _buildSessionHeaderCard(session, detail.activeRecruitment),

          // 2. Tab Bar: Confirmed vs Waiting Queue
          Container(
            color: colors.cardBackground,
            child: TabBar(
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
                      const Icon(Icons.check_circle_outline, size: 18),
                      AppSpacing.gapW4,
                      Text('${context.l10n.booking_status_confirmed} ($confirmedCount/${session.maxPlayers})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_empty_rounded, size: 18),
                      AppSpacing.gapW4,
                      Text('${context.l10n.booking_status_pending} ($waitingCount)'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlayersList(detail.confirmedPlayers, isWaiting: false),
                _buildPlayersList(detail.waitingQueue, isWaiting: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHeaderCard(Session session, GuestRecruitment? activeRecruitment) {
    final colors = context.colors;
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    final timeStr = '${DateFormat('HH:mm').format(session.startTime)} - ${dateFormat.format(session.endTime)}';
    final progress = session.maxPlayers > 0 ? (session.confirmedCount / session.maxPlayers).clamp(0.0, 1.0) : 0.0;
    final isFull = session.isFull;

    return Container(
      width: double.infinity,
      color: colors.cardBackground,
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: AppRadius.tag,
                ),
                child: Text(
                  session.clubName,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(session.status),
            ],
          ),
          AppSpacing.gapH8,

          // Court address & Time
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16, color: colors.textMuted),
              AppSpacing.gapW4,
              Expanded(
                child: Text(
                  session.courtLocation,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH4,
          Row(
            children: [
              Icon(Icons.access_time_filled_rounded, size: 16, color: colors.textMuted),
              AppSpacing.gapW4,
              Text(
                timeStr,
                style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
              ),
              const Spacer(),
              Text(
                '${session.courtCount} sân • ${session.targetPlayerPerCourt} người/sân',
                style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
              ),
            ],
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
                      isFull ? colors.warning : colors.primary,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Text(
                '${session.confirmedCount}/${session.maxPlayers} slot',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFull ? colors.warning : colors.primary,
                ),
              ),
            ],
          ),

          // Active recruitment banner
          if (activeRecruitment != null) ...[
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.roleViolet.withValues(alpha: 0.2) : AppColors.violetLight,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: AppColors.violetBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, size: 18, color: AppColors.roleViolet),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      'Đang phát tin tìm ${activeRecruitment.slotsRemaining} khách giao lưu (${NumberFormat('#,###').format(activeRecruitment.sharedCost)} đ)',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.isDark ? AppColors.white : AppColors.roleHost,
                      ),
                    ),
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
                    ? 'Khi slot chính thức đầy, các biểu quyết tiếp theo sẽ vào đây.'
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
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: colors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: BorderSide(color: colors.cardBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                    child: Text(
                      player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
            title: Text(
              player.fullName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Biểu quyết lúc: ${DateFormat('HH:mm, dd/MM').format(player.bookedAt)}',
              style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: AppRadius.tag,
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

    return Container(
      padding: AppSpacing.screen,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(top: BorderSide(color: colors.divider)),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.bottomBar,
      ),
      child: SafeArea(
        child: isBooked
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConfirmed ? 'Bạn đã có slot chính thức' : 'Đang ở hàng đợi số #$waitingOrder',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isConfirmed ? colors.primary : colors.warning,
                          ),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          'Báo vắng để tự động nhường slot',
                          style: AppTypography.bodySmall.copyWith(color: colors.textMuted),
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
            : ElevatedButton(
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
                    : Text(
                        !isOpen
                            ? 'Buổi chơi đã đóng biểu quyết'
                            : (session.isFull ? 'Xếp Vào Hàng Đợi Chờ (Slot #${session.waitingCount + 1})' : 'Biểu Quyết Tham Gia (Vote YES)'),
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case SessionStatus.open:
        bg = AppColors.successLight;
        fg = AppColors.roleMember;
        break;
      case SessionStatus.locked:
        bg = AppColors.warningLight;
        fg = AppColors.roleTreasurer;
        break;
      case SessionStatus.playing:
        bg = AppColors.infoLight;
        fg = AppColors.indigo;
        break;
      default:
        bg = context.colors.surfaceSubtle;
        fg = context.colors.textMuted;
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
