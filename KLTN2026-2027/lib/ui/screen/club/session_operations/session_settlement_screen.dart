// lib/ui/screen/club/session_operations/session_settlement_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_settlement.dart';

final sessionSettlementNotifierProvider =
    StateNotifierProvider.autoDispose.family<SessionSettlementNotifier, AsyncValue<SessionSettlement>, String>(
        (ref, sessionId) {
  final repo = ref.watch(sessionOperationsRepositoryProvider);
  return SessionSettlementNotifier(repo, sessionId);
});

class SessionSettlementNotifier extends StateNotifier<AsyncValue<SessionSettlement>> {
  final dynamic _repo;
  final String sessionId;

  SessionSettlementNotifier(this._repo, this.sessionId) : super(const AsyncValue.loading()) {
    loadSettlement();
  }

  Future<void> loadSettlement() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repo.getSettlement(sessionId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> calculate({required int shuttlecockUsed, required int extraFee}) async {
    try {
      final updated = await _repo.calculateSettlement(
        sessionId: sessionId,
        shuttlecockUsed: shuttlecockUsed,
        extraFee: extraFee,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markPaid(String userId) async {
    try {
      final updated = await _repo.markMemberPaid(sessionId: sessionId, userId: userId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class SessionSettlementScreen extends ConsumerWidget {
  final String sessionId;

  const SessionSettlementScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncState = ref.watch(sessionSettlementNotifierProvider(sessionId));
    final vm = ref.read(sessionSettlementNotifierProvider(sessionId).notifier);
    final currencyFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tính Tiền Cầu & Sân', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
            Text('Công thức đa hệ số & VietQR tự động gạch nợ',
                style: AppTypography.labelSmall.colored(colors.textMuted)),
          ],
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review_outlined, color: colors.primary),
            tooltip: 'Đánh giá tín nhiệm buổi chơi',
            onPressed: () => context.push('/session/$sessionId/reviews'),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (settlement) {
          return RefreshIndicator(
            onRefresh: vm.loadSettlement,
            color: colors.primary,
            child: ListView(
              padding: AppSpacing.allBase,
              children: [
                // 1. Total Cost Overview Card
                Container(
                  padding: AppSpacing.allBase,
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: colors.cardBorder),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng Chi Phí Buổi Chơi', style: AppTypography.labelMedium.colored(colors.textMuted)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.15),
                              borderRadius: AppRadius.tag,
                            ),
                            child: Text(
                              'Đã thu: ${currencyFormat.format(settlement.totalCollected)} đ',
                              style: AppTypography.labelSmall.bold.colored(colors.success),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH8,
                      Text(
                        '${currencyFormat.format(settlement.totalCost)} đ',
                        style: AppTypography.headlineMedium.bold.colored(colors.textPrimary),
                      ),
                      AppSpacing.gapH12,
                      Divider(height: 1, color: colors.cardBorder),
                      AppSpacing.gapH12,
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeeItem(
                              context,
                              'Tiền sân',
                              '${currencyFormat.format(settlement.courtFee)} đ',
                              Icons.stadium_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildFeeItem(
                              context,
                              'Cầu lông (${settlement.shuttlecockUsed} quả)',
                              '${currencyFormat.format(settlement.shuttlecockUsed * settlement.shuttlecockPrice)} đ',
                              Icons.sports_tennis_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildFeeItem(
                              context,
                              'Phụ phí',
                              '${currencyFormat.format(settlement.extraFee)} đ',
                              Icons.local_drink_rounded,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH16,
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                          minimumSize: const Size(double.infinity, 42),
                          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Cập nhật số quả cầu bóc mới & phụ phí'),
                        onPressed: () => _showUpdateConsumablesDialog(context, settlement, vm),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH16,

                // 2. Members Fees Breakdown
                Text('Bảng chia tiền đa hệ số & VietQR cá nhân (${settlement.memberFees.length})',
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                AppSpacing.gapH8,

                ...settlement.memberFees.map((fee) => _buildMemberFeeCard(context, fee, vm)),

                AppSpacing.gapH48,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeeItem(BuildContext context, String label, String value, IconData icon) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: colors.textMuted),
            AppSpacing.gapW4,
            Expanded(
              child: Text(label, style: AppTypography.labelSmall.colored(colors.textMuted), maxLines: 1),
            ),
          ],
        ),
        AppSpacing.gapH4,
        Text(value, style: AppTypography.labelMedium.bold.colored(colors.textPrimary)),
      ],
    );
  }

  Widget _buildMemberFeeCard(BuildContext context, MemberSettlementFee fee, SessionSettlementNotifier vm) {
    final colors = context.colors;
    final currencyFormat = NumberFormat('#,###');
    final isPaid = fee.isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isPaid ? colors.success.withValues(alpha: 0.3) : colors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withValues(alpha: 0.15),
                child: Text(
                  fee.fullName.isNotEmpty ? fee.fullName[0].toUpperCase() : '?',
                  style: AppTypography.labelMedium.bold.colored(colors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fee.fullName, style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${fee.roleName} • ${fee.gender == "FEMALE" ? "Nữ (Giảm giá)" : "Nam"}',
                      style: AppTypography.labelSmall.colored(colors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${currencyFormat.format(fee.finalFee)} đ',
                    style: AppTypography.titleSmall.bold.colored(isPaid ? colors.success : colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPaid ? colors.success : colors.warning).withValues(alpha: 0.15),
                      borderRadius: AppRadius.tag,
                    ),
                    child: Text(
                      isPaid ? 'ĐÃ GẠCH NỢ' : 'CHƯA TRẢ',
                      style: AppTypography.labelSmall.bold.colored(isPaid ? colors.success : colors.warning),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isPaid && fee.vietQrUrl.isNotEmpty) ...[
            AppSpacing.gapH12,
            Divider(height: 1, color: colors.cardBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                  ),
                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                  label: const Text('Mã VietQR'),
                  onPressed: () => _showVietQrModal(context, fee),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    foregroundColor: AppColors.white,
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Xác nhận tiền mặt'),
                  onPressed: () => vm.markPaid(fee.userId),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showVietQrModal(BuildContext context, MemberSettlementFee fee) {
    final colors = context.colors;
    final currencyFormat = NumberFormat('#,###');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Center(
          child: Text('VietQR Tự Động Gạch Nợ', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.cardBorder),
                image: DecorationImage(
                  image: NetworkImage(fee.vietQrUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppSpacing.gapH12,
            Text(fee.fullName, style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
            AppSpacing.gapH4,
            Text(
              'Số tiền: ${currencyFormat.format(fee.finalFee)} đ',
              style: AppTypography.titleMedium.bold.colored(colors.primary),
            ),
            AppSpacing.gapH4,
            Text('Nội dung: ${fee.paymentCode}', style: AppTypography.bodySmall.colored(colors.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showUpdateConsumablesDialog(BuildContext context, SessionSettlement settlement, SessionSettlementNotifier vm) {
    final shuttleCtrl = TextEditingController(text: '${settlement.shuttlecockUsed}');
    final extraCtrl = TextEditingController(text: '${settlement.extraFee}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ghi Nhận Tiền Cầu & Nước Uống'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: shuttleCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số lượng quả cầu bóc mới *',
                hintText: 'Ví dụ: 4',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: extraCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Phụ phí nước uống, phát sinh (VNĐ)',
                hintText: 'Ví dụ: 40000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final used = int.tryParse(shuttleCtrl.text.trim()) ?? 0;
              final extra = int.tryParse(extraCtrl.text.trim()) ?? 0;
              vm.calculate(shuttlecockUsed: used, extraFee: extra);
              Navigator.of(ctx).pop();
            },
            child: const Text('Tính lại đa hệ số'),
          ),
        ],
      ),
    );
  }
}
