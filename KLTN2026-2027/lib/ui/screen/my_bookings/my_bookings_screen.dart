// lib/ui/screen/my_bookings/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kltn2026_2027/app/theme/theme.dart';
import '../../../app/consts/app_config.dart';
import '../../../app/provider/localization_provider.dart';
import '../../../app/utils/exception_ext.dart';
import '../../../domain/entities/session/my_booking_item.dart';
import '../../../domain/enums/session_enums.dart';
import 'my_bookings_vm/my_bookings_state.dart';
import 'my_bookings_vm/my_bookings_vm.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myBookingsViewModelProvider);
    final vm = ref.read(myBookingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Lịch tập của tôi',
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.cMain),
            tooltip: 'Làm mới',
            onPressed: vm.loadMyBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: AppColor.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MyBookingsFilter.values.map((f) {
                  final isSelected = state.filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      selectedColor: AppColor.cMain.withValues(alpha: 0.15),
                      backgroundColor: AppColors.surfaceSubtle,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColor.cMain : AppColor.cDark,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColor.cMain : Colors.transparent,
                        ),
                      ),
                      onSelected: (_) => vm.setFilter(f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Body Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColor.cMain))
                : state.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 56, color: AppColor.cError),
                              const SizedBox(height: 12),
                              Text(
                                state.error!.getDisplayMessage(context.l10n),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: AppColor.cDark),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.cMain,
                                  foregroundColor: AppColor.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: vm.loadMyBookings,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : state.filteredBookings.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            color: AppColor.cMain,
                            onRefresh: vm.loadMyBookings,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              itemCount: state.filteredBookings.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (ctx, index) {
                                final booking = state.filteredBookings[index];
                                return _buildBookingCard(context, booking);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_busy_rounded, size: 40, color: AppColor.cMain),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch chơi nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.cDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn chưa đăng ký giữ chỗ buổi tập nào. Hãy tham gia câu lạc bộ hoặc tìm kiếm các buổi chơi giao lưu lân cận!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColor.cMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cMain,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => context.push(AppConfig.exploreRecruitmentsScreenPath),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Tìm kèo giao lưu ngay'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, MyBookingItem b) {
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (b.bookingStatus) {
      case BookingStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'Chính thức';
        statusIcon = Icons.check_circle_rounded;
        break;
      case BookingStatus.waiting:
        statusColor = AppColors.warning;
        statusText = 'Hàng đợi #${b.queueOrder}';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case BookingStatus.checkedIn:
        statusColor = AppColors.roleSky;
        statusText = 'Đã điểm danh';
        statusIcon = Icons.verified_rounded;
        break;
      case BookingStatus.absent:
        statusColor = AppColors.error;
        statusText = 'Đã báo vắng';
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return InkWell(
      onTap: () => context.push(AppConfig.sessionDetailRoutePath(b.sessionId)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Header: Club Name & Status Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColor.cMain.withValues(alpha: 0.12),
                  child: const Icon(Icons.groups_rounded, size: 16, color: AppColor.cMain),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b.clubName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColor.cDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),

            // Session Title
            Text(
              b.sessionTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColor.cTitle,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 15, color: AppColor.cMain),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${dateFormat.format(b.startTime)} • ${timeFormat.format(b.startTime)} - ${timeFormat.format(b.endTime)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColor.cMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    b.courtLocation.isNotEmpty ? b.courtLocation : 'Địa điểm chưa cập nhật',
                    style: const TextStyle(fontSize: 12, color: AppColor.cMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer: Fee & Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Phí tham gia: ', style: TextStyle(fontSize: 12, color: AppColor.cMuted)),
                    Text(
                      b.feePerMember > 0 ? currencyFormat.format(b.feePerMember) : 'Miễn phí',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColor.cMain,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Chi tiết',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColor.cMain,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColor.cMain),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
