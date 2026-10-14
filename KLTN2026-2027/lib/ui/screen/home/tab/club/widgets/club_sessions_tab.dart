// lib/ui/screen/home/tab/club/widgets/club_sessions_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../../app/consts/app_color.dart';
import '../../../../../../app/consts/app_config.dart';
import '../../../../../../domain/entities/session/session.dart';
import '../../../../../../domain/enums/session_enums.dart';
import '../../../../club/session_vm/club_sessions_vm.dart';
import '../../../../club/widgets/create_session_dialog.dart';

class ClubSessionsTab extends ConsumerWidget {
  final String clubId;
  final String clubName;
  final bool isHost;

  const ClubSessionsTab({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubSessionsViewModelProvider(clubId));
    final vm = ref.read(clubSessionsViewModelProvider(clubId).notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColor.cMain));
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColor.cRed, size: 48),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColor.cRed, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: vm.loadSessions,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: isHost
          ? FloatingActionButton.extended(
              onPressed: () async {
                final sessionId = await CreateSessionDialog.show(
                  context,
                  clubId: clubId,
                  clubName: clubName,
                );
                if (sessionId != null && context.mounted) {
                  context.push(AppConfig.sessionDetailRoutePath(sessionId));
                }
              },
              backgroundColor: AppColor.cMain,
              foregroundColor: AppColor.white,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tạo buổi chơi (FR13)', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: vm.loadSessions,
        color: AppColor.cMain,
        child: state.sessions.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: state.sessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final session = state.sessions[index];
                  return _SessionCard(
                    session: session,
                    onTap: () {
                      context.push(AppConfig.sessionDetailRoutePath(session.id));
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_rounded, size: 54, color: AppColor.cMain),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa Có Buổi Sinh Hoạt Nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.cTitle),
            ),
            const SizedBox(height: 8),
            const Text(
              'Các buổi giao lưu sắp tới của câu lạc bộ sẽ hiển thị ở đây để bạn biểu quyết giữ chỗ.',
              style: TextStyle(fontSize: 13, color: AppColor.cMuted),
              textAlign: TextAlign.center,
            ),
            if (isHost) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => CreateSessionDialog.show(context, clubId: clubId, clubName: clubName),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo Buổi Chơi Đầu Tiên (FR13)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cMain,
                  foregroundColor: AppColor.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    final timeStr = '${DateFormat('HH:mm').format(session.startTime)} - ${dateFormat.format(session.endTime)}';
    final progress = session.maxPlayers > 0 ? (session.confirmedCount / session.maxPlayers).clamp(0.0, 1.0) : 0.0;
    final isFull = session.isFull;

    return Card(
      elevation: 0.8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: session.isBookedByCurrentUser ? AppColor.cMain.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: session.isBookedByCurrentUser ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Status badge & User booking tag
              Row(
                children: [
                  _buildStatusBadge(session.status),
                  const Spacer(),
                  if (session.isBookedByCurrentUser)
                    _buildUserTicketBadge(session.currentUserBookingStatus, session.currentUserQueueOrder),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                session.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.cTitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Court Location
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColor.cMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session.courtLocation,
                      style: const TextStyle(fontSize: 13, color: AppColor.cTitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Time
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColor.cMuted),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: const TextStyle(fontSize: 13, color: AppColor.cTitle, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Capacity Progress
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFull ? Colors.orange : AppColor.cMain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${session.confirmedCount}/${session.maxPlayers} slot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFull ? Colors.orange : AppColor.cMain,
                    ),
                  ),
                  if (session.waitingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${session.waitingCount} chờ',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber),
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case SessionStatus.locked:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case SessionStatus.playing:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4F46E5);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildUserTicketBadge(BookingStatus? status, int queueOrder) {
    if (status == BookingStatus.waiting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'Hàng đợi #$queueOrder',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.cMain.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: AppColor.cMain),
          SizedBox(width: 4),
          Text(
            'Đã giữ chỗ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColor.cMain),
          ),
        ],
      ),
    );
  }
}
