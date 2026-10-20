// lib/ui/screen/club/session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    if (booking != null && mounted) {
      if (booking.isConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chúc mừng! Bạn đã giữ chỗ chính thức thành công!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Đã Vào Hàng Đợi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
            content: Text(
              'Hiện buổi chơi đã đủ số lượng chính thức. Bạn đang ở vị trí chờ số #${booking.queueOrder} trong hàng đợi.\nHệ thống sẽ tự động đôn bạn lên chính thức khi có thành viên báo vắng!',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _handleCancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Xác Nhận Báo Vắng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: const Text(
          'Nếu bạn đang giữ chỗ chính thức, slot này sẽ tự động được nhường cho người tiếp theo trong hàng đợi (FR10).\nBạn có chắc chắn muốn hủy?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận báo vắng'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final vm = ref.read(sessionDetailViewModelProvider(widget.sessionId).notifier);
      final ok = await vm.cancelBooking();
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã báo vắng thành công. Vị trí đã được nhường cho hàng đợi!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRecruitmentModal(BuildContext context, Session session) {
    final slotsNeeded = (session.maxPlayers - session.confirmedCount).clamp(1, session.maxPlayers);
    final slotsCtl = TextEditingController(text: slotsNeeded.toString());
    final costCtl = TextEditingController(text: '50000');
    SkillLevel selectedLevel = SkillLevel.tb;
    double radiusKm = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
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
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.radar_rounded, color: AppColors.roleViolet, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Phát Tín Hiệu Tuyển Khách (FR11)',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Số slot cần tuyển *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: slotsCtl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          const Text('Trình độ tối thiểu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<SkillLevel>(
                            initialValue: selectedLevel,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: SkillLevel.values.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s.displayName));
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
                const SizedBox(height: 14),
                const Text('Tiền sân chia sẻ / người (VNĐ)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: costCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '50,000',
                    prefixIcon: const Icon(Icons.attach_money_rounded, size: 20, color: AppColors.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bán kính phát tín hiệu:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('${radiusKm.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.roleViolet)),
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
                const SizedBox(height: 16),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Phát Tin Tuyển Khách', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.neutral50,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (state.detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi Tiết Buổi Chơi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(state.errorMessage ?? 'Không tìm thấy thông tin buổi chơi'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: vm.loadDetail, child: const Text('Thử lại')),
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
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.loadDetail,
            tooltip: 'Làm mới',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
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
                    title: const Text('Hủy Buổi Chơi'),
                    content: const Text('Hành động này sẽ hủy buổi chơi vĩnh viễn và gửi thông báo tới người đã vote.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Bỏ qua')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Hủy ngay'),
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
              const PopupMenuItem(
                value: 'recruit',
                child: Row(
                  children: [
                    Icon(Icons.radar_rounded, color: AppColors.roleViolet, size: 18),
                    SizedBox(width: 8),
                    Text('Tuyển khách giao lưu (FR11)'),
                  ],
                ),
              ),
              if (session.status == SessionStatus.open)
                const PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Khóa sổ biểu quyết'),
                    ],
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.lock_open, size: 18),
                      SizedBox(width: 8),
                      Text('Mở lại biểu quyết'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'play',
                child: Row(
                  children: [
                    Icon(Icons.sports_tennis, size: 18),
                    SizedBox(width: 8),
                    Text('Bắt đầu thi đấu'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    SizedBox(width: 8),
                    Text('Hủy buổi chơi', style: TextStyle(color: AppColors.error)),
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
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 6),
                      Text('Chính thức ($confirmedCount/${session.maxPlayers})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_empty_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text('Hàng đợi ($waitingCount)'),
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
                // Confirmed Tab
                _buildPlayersList(detail.confirmedPlayers, isWaiting: false),

                // Waiting Queue Tab
                _buildPlayersList(detail.waitingQueue, isWaiting: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHeaderCard(Session session, GuestRecruitment? activeRecruitment) {
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    final timeStr = '${DateFormat('HH:mm').format(session.startTime)} - ${dateFormat.format(session.endTime)}';
    final progress = session.maxPlayers > 0 ? (session.confirmedCount / session.maxPlayers).clamp(0.0, 1.0) : 0.0;
    final isFull = session.isFull;

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.clubName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(session.status),
            ],
          ),
          const SizedBox(height: 10),

          // Court address & Time
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session.courtLocation,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '${session.courtCount} sân • ${session.targetPlayerPerCourt} người/sân',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sĩ số Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFull ? AppColors.warning : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${session.confirmedCount}/${session.maxPlayers} slot',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isFull ? AppColors.warning : AppColors.primary,
                ),
              ),
            ],
          ),

          // Active recruitment banner
          if (activeRecruitment != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.violetLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.violetBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar_rounded, size: 18, color: AppColors.roleViolet),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đang phát tin tìm ${activeRecruitment.slotsRemaining} khách giao lưu (${NumberFormat('#,###').format(activeRecruitment.sharedCost)} đ)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.roleHost),
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
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                isWaiting ? 'Hàng đợi đang trống' : 'Chưa có người chơi chính thức',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                isWaiting
                    ? 'Khi slot chính thức đầy, các biểu quyết tiếp theo sẽ vào đây.'
                    : 'Hãy là người đầu tiên biểu quyết giữ chỗ cho buổi chơi này!',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        final player = players[index];
        return Card(
          elevation: 0.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: isWaiting
                ? Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#${player.queueOrder}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning, fontSize: 13),
                    ),
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
            title: Text(
              player.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              'Biểu quyết lúc: ${DateFormat('HH:mm, dd/MM').format(player.bookedAt)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                player.skillLevel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context, Session session, bool isSubmitting) {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isConfirmed ? AppColors.primary : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('Báo vắng để tự động nhường slot', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _handleCancelBooking,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(isConfirmed ? 'Báo Vắng' : 'Rút Hàng Đợi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: (!isOpen || isSubmitting) ? null : _handleVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: session.isFull ? AppColors.warning : AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        !isOpen
                            ? 'Buổi chơi đã đóng biểu quyết'
                            : (session.isFull ? 'Xếp Vào Hàng Đợi Chờ (Slot #${session.waitingCount + 1})' : 'Biểu Quyết Tham Gia (Vote YES)'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
        bg = AppColors.surfaceSubtle;
        fg = AppColors.neutral500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
