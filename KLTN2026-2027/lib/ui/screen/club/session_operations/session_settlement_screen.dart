// lib/ui/screen/club/session_operations/session_settlement_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../app/consts/vietqr_bank_directory.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../domain/entities/payment/personal_fee.dart';
import '../../../../domain/entities/session/session_settlement.dart';
import '../../../../domain/enums/club_role.dart';
import '../../../../domain/enums/session_enums.dart';
import '../../../../domain/utils/gender_helper.dart';
import '../../../../domain/utils/vietqr_helper.dart';
import '../../../../widget/app_shimmer.dart';
import '../../../../widget/app_status_badge.dart';
import '../club_vm/club_context_vm.dart';
import '../session_vm/session_detail_vm.dart';

final sessionSettlementNotifierProvider = StateNotifierProvider.autoDispose
    .family<SessionSettlementNotifier, AsyncValue<SessionSettlement>, String>((
      ref,
      sessionId,
    ) {
      final repo = ref.watch(sessionOperationsRepositoryProvider);
      return SessionSettlementNotifier(repo, sessionId);
    });

class SessionSettlementNotifier
    extends StateNotifier<AsyncValue<SessionSettlement>> {
  final dynamic _repo;
  final String sessionId;
  Timer? _pollTimer;

  SessionSettlementNotifier(this._repo, this.sessionId)
    : super(const AsyncValue.loading()) {
    loadSettlement();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollSettlement();
    });
  }

  Future<void> _pollSettlement() async {
    try {
      final data = await _repo.getSettlement(sessionId);
      if (mounted) {
        state = AsyncValue.data(data);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
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

  Future<void> calculate({
    required int shuttlecockUsed,
    required int extraFee,
    int? courtRentalCost,
    bool monthlyExemptCourtOnly = false,
  }) async {
    try {
      final updated = await _repo.calculateSettlement(
        sessionId: sessionId,
        shuttlecockUsed: shuttlecockUsed,
        extraFee: extraFee,
        courtRentalCost: courtRentalCost,
        monthlyExemptCourtOnly: monthlyExemptCourtOnly,
      );
      state = AsyncValue.data(updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markPaid(String userId) async {
    try {
      final updated = await _repo.markMemberPaid(
        sessionId: sessionId,
        userId: userId,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> requestCashPayment(String userId, {String? feeId}) async {
    try {
      final updated = await _repo.requestCashPayment(
        sessionId: sessionId,
        userId: userId,
        feeId: feeId,
      );
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

    final detail = ref.watch(sessionDetailViewModelProvider(sessionId)).detail;
    final activeContext = ref.watch(activeClubContextProvider);
    final clubId = (detail?.session.groupId.isNotEmpty == true)
        ? detail!.session.groupId
        : (activeContext?.clubId ?? '');
    final bankAsync = clubId.isNotEmpty ? ref.watch(clubPaymentBankProvider(clubId)) : null;
    final clubBank = bankAsync?.asData?.value;
    final isBankLoading = bankAsync?.isLoading == true;

    final isSameClub = activeContext?.clubId == clubId;
    final isHost = isSameClub && activeContext?.role == ClubRole.host;
    final isTreasurer = isSameClub && activeContext?.role == ClubRole.treasurer;
    final myClubs = ref.watch(clubContextViewModelProvider).myClubs;
    final isHostOrTreasurerInClub = myClubs.any(
      (c) => c.clubId == clubId && (c.role == ClubRole.host || c.role == ClubRole.treasurer),
    );
    final canOperateSettlement = isHost || isTreasurer || isHostOrTreasurerInClub || (isSameClub && ref.hasClubPermission('FINANCE.FEE.MANAGE'));
    final currentUserId = ref.watch(currentUserProfileProvider)?.id ?? ref.watch(authTokenProvider)?.userId;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.settlement_screen_title,
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
            ),
            Text(
              context.l10n.settlement_screen_subtitle,
              style: AppTypography.labelSmall.colored(colors.textMuted),
            ),
          ],
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: colors.textPrimary,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review_outlined, color: colors.primary),
            tooltip: context.l10n.settlement_reviews_tooltip,
            onPressed: () => context.push('/session/$sessionId/reviews'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: asyncState.when(
            loading: () => ListView(
              padding: AppSpacing.allBase,
              children: [
                AppShimmer.card(height: 160),
                AppSpacing.gapH16,
                AppShimmer.line(width: 200, height: 20),
                AppSpacing.gapH12,
                AppShimmer.card(height: 90),
                AppSpacing.gapH8,
                AppShimmer.card(height: 90),
              ],
            ),
            error: (err, _) => Padding(
              padding: AppSpacing.allXl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colors.error,
                  ),
                  AppSpacing.gapH12,
                  Text(
                    context.l10n.settlement_load_error,
                    style: AppTypography.titleMedium.bold.colored(
                      colors.textPrimary,
                    ),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    context.l10n.error_system_retry,
                    style: AppTypography.bodySmall.colored(colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapH16,
                  ElevatedButton.icon(
                    onPressed: vm.loadSettlement,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(context.l10n.com_retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(120, 44),
                    ),
                  ),
                ],
              ),
            ),
            data: (settlement) {
              final effectiveBank = settlement.bankAccount ?? clubBank;
              return RefreshIndicator(
                onRefresh: () async {
                  await vm.loadSettlement();
                  if (clubId.isNotEmpty) {
                    ref.invalidate(clubPaymentBankProvider(clubId));
                  }
                },
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
                              Text(
                                context.l10n.settlement_total_cost,
                                style: AppTypography.labelMedium.colored(
                                  colors.textMuted,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.success.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.tag,
                                ),
                                child: Text(
                                  context.l10n.settlement_collected_amount(
                                    currencyFormat.format(
                                      settlement.totalCollected,
                                    ),
                                  ),
                                  style: AppTypography.labelSmall.bold.colored(
                                    colors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapH8,
                          Text(
                            context.l10n.settlement_amount(
                              currencyFormat.format(settlement.totalCost),
                            ),
                            style: AppTypography.headlineMedium.bold.colored(
                              colors.textPrimary,
                            ),
                          ),
                          AppSpacing.gapH12,
                          Divider(height: 1, color: colors.cardBorder),
                          AppSpacing.gapH12,
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeeItem(
                                  context,
                                  context.l10n.settlement_court_fee,
                                  context.l10n.settlement_amount(
                                    currencyFormat.format(settlement.courtFee),
                                  ),
                                  Icons.stadium_rounded,
                                ),
                              ),
                              Expanded(
                                child: _buildFeeItem(
                                  context,
                                  context.l10n.settlement_shuttlecock_fee(
                                    settlement.shuttlecockUsed.toString(),
                                  ),
                                  context.l10n.settlement_amount(
                                    currencyFormat.format(
                                      settlement.shuttlecockUsed *
                                          settlement.shuttlecockPrice,
                                    ),
                                  ),
                                  Icons.sports_tennis_rounded,
                                ),
                              ),
                              Expanded(
                                child: _buildFeeItem(
                                  context,
                                  context.l10n.settlement_extra_fee,
                                  context.l10n.settlement_amount(
                                    currencyFormat.format(settlement.extraFee),
                                  ),
                                  Icons.local_drink_rounded,
                                ),
                              ),
                            ],
                          ),
                          if (canOperateSettlement) ...[
                            AppSpacing.gapH16,
                            if (!settlement.isSettled)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: AppColors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.button,
                                  ),
                                ),
                                icon: const Icon(Icons.calculate_rounded),
                                label: Text(
                                  context.l10n.settlement_publish_fees,
                                ),
                                onPressed: () => _showUpdateConsumablesDialog(
                                  context,
                                  settlement,
                                  vm,
                                  ref,
                                ),
                              )
                            else
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primary,
                                  side: BorderSide(
                                    color: colors.primary.withValues(alpha: 0.4),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.button,
                                  ),
                                ),
                                icon: const Icon(Icons.edit_note_rounded),
                                label: Text(context.l10n.settlement_update_costs),
                                onPressed: () => _showUpdateConsumablesDialog(
                                  context,
                                  settlement,
                                  vm,
                                  ref,
                                ),
                              ),
                            if (detail?.session.status != SessionStatus.completed) ...[
                              AppSpacing.gapH8,
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: AppColors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.button,
                                  ),
                                ),
                                icon: const Icon(Icons.check_circle_outline_rounded),
                                label: const Text('Kết thúc buổi chơi'),
                                onPressed: () => _confirmCompleteSessionFromSettlement(
                                  context,
                                  ref,
                                  sessionId,
                                  isSettled: settlement.isSettled,
                                ),
                              ),
                            ],
                          ] else ...[
                            AppSpacing.gapH12,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceSubtle,
                                borderRadius: AppRadius.borderSm,
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: colors.textMuted),
                                  AppSpacing.gapW8,
                                  Expanded(
                                    child: Text(
                                      settlement.isSettled
                                          ? 'Chi phí đã được Ban Điều Hành chốt và phân bổ.'
                                          : 'Chi phí đang được Ban Điều Hành tổng hợp.',
                                      style: AppTypography.labelSmall.colored(colors.textMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.gapH16,

                    // 2. Members Fees Breakdown
                    // Cách chia tiền buổi chơi giải thích cho người chơi
                    Consumer(
                      builder: (context, ref, _) {
                        final activeContext = ref.watch(
                          activeClubContextProvider,
                        );
                        final feeRuleAsync = activeContext != null
                            ? ref.watch(
                                clubFeeRuleProvider(activeContext.clubId),
                              )
                            : null;
                        final isDynamic =
                            feeRuleAsync?.asData?.value.isDynamic ?? true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: AppRadius.borderMd,
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: colors.primary,
                                size: 18,
                              ),
                              AppSpacing.gapW8,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDynamic
                                          ? context.l10n
                                                .settlement_calculation_dynamic_title
                                          : context.l10n
                                                .settlement_calculation_fixed_title,
                                      style: AppTypography.labelSmall.bold
                                          .colored(colors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isDynamic
                                          ? context.l10n
                                                .settlement_calculation_dynamic_description(
                                                  currencyFormat.format(
                                                    settlement.courtFee,
                                                  ),
                                                  settlement.shuttlecockUsed
                                                      .toString(),
                                                  currencyFormat.format(
                                                    settlement.extraFee,
                                                  ),
                                                )
                                          : context.l10n
                                                .settlement_calculation_fixed_description,
                                      style: AppTypography.bodySmall.colored(
                                        colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (effectiveBank != null && effectiveBank.accountNumber.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.08),
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: colors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded, color: colors.success, size: 20),
                            AppSpacing.gapW8,
                            Expanded(
                              child: Text(
                                context.l10n.settlement_club_bank_info(
                                  effectiveBank.bankName,
                                  effectiveBank.accountNumber,
                                  effectiveBank.accountHolder,
                                ),
                                style: AppTypography.bodySmall.colored(colors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (!isBankLoading && (effectiveBank == null || effectiveBank.accountNumber.isEmpty))
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_outlined, color: colors.warning, size: 20),
                            AppSpacing.gapW8,
                            Expanded(
                              child: Text(
                                context.l10n.settlement_club_bank_missing,
                                style: AppTypography.bodySmall.colored(colors.textPrimary),
                              ),
                            ),
                            if (clubId.isNotEmpty)
                              TextButton(
                                onPressed: () => context.push('/club/$clubId/settings'),
                                child: Text(
                                  context.l10n.settlement_club_bank_setup_button,
                                  style: AppTypography.labelSmall.bold.colored(colors.primary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Text(
                      context.l10n.settlement_member_fees_title(
                        settlement.memberFees.length.toString(),
                      ),
                      style: AppTypography.titleSmall.bold.colored(
                        colors.textPrimary,
                      ),
                    ),
                    AppSpacing.gapH8,

                    if (settlement.memberFees.isEmpty)
                      Container(
                        padding: AppSpacing.allXl,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: colors.textMuted,
                            ),
                            AppSpacing.gapH12,
                            Text(
                              context.l10n.settlement_no_members_to_charge,
                              style: AppTypography.bodyMedium.colored(
                                colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...() {
                      final myPersonalFee = ref.watch(mySessionFeeProvider(sessionId)).asData?.value;
                      final memberFees = List<MemberSettlementFee>.from(settlement.memberFees);
                      if (currentUserId != null && currentUserId.isNotEmpty) {
                        memberFees.sort((a, b) {
                          final aIsMe = a.userId.toLowerCase() == currentUserId.toLowerCase();
                          final bIsMe = b.userId.toLowerCase() == currentUserId.toLowerCase();
                          if (aIsMe && !bIsMe) return -1;
                          if (!aIsMe && bIsMe) return 1;
                          return 0;
                        });
                      }
                      return memberFees.map(
                        (fee) {
                          final isCurrentUser = currentUserId != null &&
                              fee.userId.toLowerCase() == currentUserId.toLowerCase();
                          var effectiveFee = fee;
                          if (isCurrentUser && myPersonalFee != null) {
                            final isExempt = myPersonalFee.isExempt ||
                                (myPersonalFee.amount != null && myPersonalFee.amount! <= 0);
                            final feeAmount = isExempt
                                ? 0
                                : (myPersonalFee.amount?.toInt() ?? effectiveFee.finalFee);
                            effectiveFee = effectiveFee.copyWith(
                              feeId: myPersonalFee.feeId.isNotEmpty
                                  ? myPersonalFee.feeId
                                  : effectiveFee.feeId,
                              finalFee: feeAmount,
                              paymentStatus: isExempt
                                  ? 'EXEMPT'
                                  : myPersonalFee.paymentStatus.toUpperCase(),
                              roleName: isExempt ? 'MEMBER_MONTHLY' : effectiveFee.roleName,
                              paymentCode: myPersonalFee.paymentCode.isNotEmpty
                                  ? myPersonalFee.paymentCode
                                  : effectiveFee.paymentCode,
                              paidAmount: myPersonalFee.isPaid
                                  ? feeAmount
                                  : effectiveFee.paidAmount,
                            );
                          }
                          return _buildMemberFeeCard(
                            context,
                            effectiveFee,
                            vm,
                            effectiveBank,
                            canOperateSettlement: canOperateSettlement,
                            isCurrentUser: isCurrentUser,
                            isSettled: settlement.isSettled,
                          );
                        },
                      );
                    }(),

                    AppSpacing.gapH48,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeeItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: colors.textMuted),
            AppSpacing.gapW4,
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelSmall.colored(colors.textMuted),
                maxLines: 1,
              ),
            ),
          ],
        ),
        AppSpacing.gapH4,
        Text(
          value,
          style: AppTypography.labelMedium.bold.colored(colors.textPrimary),
        ),
      ],
    );
  }

  String _formatRoleName(BuildContext context, String role) {
    final r = role.trim().toUpperCase();
    if (r.contains('MONTHLY') || r.contains('THÁNG')) {
      return context.l10n.settlement_role_monthly_member;
    }
    if (r.contains('DAILY') || r.contains('NGÀY')) {
      return context.l10n.settlement_role_daily_member;
    }
    if (r.contains('GUEST') || r.contains('VÃNG LAI') || r.contains('KHÁCH')) {
      return context.l10n.settlement_role_guest;
    }
    if (r.contains('MEMBER') || r.contains('HỘI VIÊN') || r.contains('THÀNH VIÊN')) {
      return context.l10n.settlement_role_daily_member;
    }
    if (r.contains('HOST') || r.contains('ADMIN') || r.contains('CHỦ SÂN') || r.contains('QUẢN TRỊ')) {
      return 'Ban điều hành';
    }
    return role.isNotEmpty ? role : context.l10n.settlement_role_unknown;
  }

  String _resolveVietQrUrl(MemberSettlementFee fee, PaymentBankAccount? bank) {
    if (fee.vietQrUrl.isNotEmpty) {
      return fee.vietQrUrl;
    }
    if (bank == null || bank.accountNumber.trim().isEmpty) return '';
    String bin = bank.bankBin?.trim() ?? '';
    if (bin.isEmpty) {
      for (final b in vietQrBankDirectory) {
        if (b.name.toLowerCase() == bank.bankName.toLowerCase()) {
          bin = b.bin;
          break;
        }
      }
    }
    if (bin.isEmpty) bin = '970436';
    final cleanAcc = bank.accountNumber.trim();
    final cleanCode = fee.paymentCode.isNotEmpty ? fee.paymentCode : 'PAY_${fee.userId}';
    final accountHolderEncoded = Uri.encodeComponent(bank.accountHolder.trim());
    final codeEncoded = Uri.encodeComponent(cleanCode);
    return 'https://img.vietqr.io/image/$bin-$cleanAcc-compact2.png?amount=${fee.finalFee}&addInfo=$codeEncoded&accountName=$accountHolderEncoded';
  }

  Widget _buildMemberFeeCard(
    BuildContext context,
    MemberSettlementFee fee,
    SessionSettlementNotifier vm,
    PaymentBankAccount? clubBank, {
    required bool canOperateSettlement,
    required bool isCurrentUser,
    required bool isSettled,
  }) {
    final colors = context.colors;
    final currencyFormat = NumberFormat('#,###');
    final isPaid = fee.isPaid;
    final isPartiallyPaid = fee.isPartiallyPaid;
    final remainingFee = fee.remainingFee > 0 ? fee.remainingFee : fee.finalFee;
    final qrUrl = _resolveVietQrUrl(fee.copyWith(finalFee: remainingFee), clubBank);
    final hasQr = qrUrl.isNotEmpty;
    final isFemale = GenderHelper.isFemale(genderString: fee.gender, fullName: fee.fullName);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isPaid
              ? colors.success.withValues(alpha: 0.3)
              : isPartiallyPaid
                  ? colors.warning.withValues(alpha: 0.4)
                  : colors.warning.withValues(alpha: 0.4),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            fee.fullName,
                            style: AppTypography.titleSmall.bold.colored(
                              colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          AppSpacing.gapW8,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.15),
                              borderRadius: AppRadius.tag,
                            ),
                            child: Text(
                              'Bạn',
                              style: AppTypography.labelSmall.bold.colored(colors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.settlement_role_gender(
                        _formatRoleName(context, fee.roleName),
                        isFemale
                            ? context.l10n.settlement_gender_female_discount
                            : context.l10n.settlement_gender_male,
                      ),
                      style: AppTypography.labelSmall.colored(colors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fee.isExempt
                        ? '0 đ'
                        : context.l10n.settlement_amount(
                            currencyFormat.format(fee.finalFee),
                          ),
                    style: AppTypography.titleSmall.bold.colored(
                      (isPaid || fee.isExempt) ? colors.success : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (fee.isExempt)
                    AppStatusBadge.success(
                      label: context.l10n.payment_exempt,
                    )
                  else if (isPaid)
                    AppStatusBadge.success(
                      label: context.l10n.settlement_paid_badge,
                    )
                  else if (!isSettled)
                    AppStatusBadge.neutral(
                      label: 'Tạm tính',
                    )
                  else if (fee.isPendingCashConfirmation)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.15),
                        borderRadius: AppRadius.tag,
                        border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        isCurrentUser
                            ? context.l10n.settlement_pending_cash_confirmation
                            : context.l10n.settlement_cash_requested_badge,
                        style: AppTypography.labelSmall.bold.colored(colors.warning),
                      ),
                    )
                  else if (isPartiallyPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.15),
                        borderRadius: AppRadius.tag,
                        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Còn thiếu: ${currencyFormat.format(fee.remainingFee)} đ',
                        style: AppTypography.labelSmall.bold.colored(colors.warning),
                      ),
                    )
                  else
                    AppStatusBadge.warning(
                      label: context.l10n.settlement_unpaid_badge,
                    ),
                ],
              ),
            ],
          ),
          if (isPartiallyPaid) ...[
            AppSpacing.gapH8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                'Đã đóng: ${currencyFormat.format(fee.paidAmount)} đ • Cần thu tiếp: ${currencyFormat.format(fee.remainingFee)} đ',
                style: AppTypography.labelSmall.colored(colors.textSecondary),
              ),
            ),
          ],
          if (!isPaid && !fee.isExempt) ...[
            AppSpacing.gapH12,
            Divider(height: 1, color: colors.cardBorder),
            const SizedBox(height: 10),
            if (canOperateSettlement) ...[
              if (!isSettled) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: colors.primary),
                      AppSpacing.gapW8,
                      Expanded(
                        child: Text(
                          'Chi phí đang ở mức tạm tính. Vui lòng bấm "Ghi nhận chi phí và tạo khoản thu" ở trên trước khi thực hiện thu tiền.',
                          style: AppTypography.labelSmall.copyWith(color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    if (hasQr)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primary,
                            side: BorderSide(
                              color: colors.primary.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            minimumSize: const Size(0, 42),
                          ),
                          icon: const Icon(Icons.qr_code_rounded, size: 16),
                          label: Text(
                            context.l10n.settlement_vietqr_label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.bold,
                          ),
                          onPressed: () => _showVietQrModal(context, fee.copyWith(finalFee: remainingFee), qrUrl, clubBank),
                        ),
                      ),
                    if (hasQr && (!isPaid && !fee.isExempt)) AppSpacing.gapW8,
                    if (!isPaid && !fee.isExempt)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fee.isPendingCashConfirmation
                                ? colors.warning
                                : colors.success,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            minimumSize: const Size(0, 42),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text(
                            fee.isPendingCashConfirmation
                                ? 'Xác nhận tiền mặt (Đã báo)'
                                : isPartiallyPaid
                                    ? 'Thu tiếp ${currencyFormat.format(fee.remainingFee)} đ'
                                    : context.l10n.settlement_confirm_cash,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.bold,
                          ),
                          onPressed: () => _confirmMarkPaid(context, fee, vm),
                        ),
                      ),
                  ],
                ),
              ],
            ] else if (isCurrentUser && isSettled && !fee.isExempt && !isPaid) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primary,
                        side: BorderSide(
                          color: colors.primary.withValues(alpha: 0.4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        minimumSize: const Size(0, 42),
                      ),
                      icon: const Icon(Icons.qr_code_rounded, size: 16),
                      label: Text(
                        context.l10n.settlement_vietqr_label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.bold,
                      ),
                      onPressed: () {
                        if (hasQr) {
                          _showVietQrModal(context, fee.copyWith(finalFee: remainingFee), qrUrl, clubBank);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.settlement_club_bank_missing),
                              backgroundColor: colors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  AppSpacing.gapW8,
                  if (!fee.isPendingCashConfirmation)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          minimumSize: const Size(0, 42),
                        ),
                        icon: const Icon(Icons.payments_outlined, size: 16),
                        label: Text(
                          context.l10n.settlement_request_cash,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.bold,
                        ),
                        onPressed: () => _confirmRequestCash(context, fee, vm),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          context.l10n.settlement_pending_cash_confirmation,
                          style: AppTypography.labelSmall.bold.colored(colors.warning),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _confirmMarkPaid(
    BuildContext context,
    MemberSettlementFee fee,
    SessionSettlementNotifier vm,
  ) {
    final currencyFormat = NumberFormat('#,###');
    final amountToPay = fee.remainingFee > 0 ? fee.remainingFee : fee.finalFee;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settlement_confirm_cash_title),
        content: Text(
          fee.isPartiallyPaid
              ? 'Xác nhận đã nhận đủ số tiền còn thiếu ${currencyFormat.format(amountToPay)} đ từ "${fee.fullName}"?'
              : context.l10n.settlement_confirm_cash_message(
                  currencyFormat.format(amountToPay),
                  fee.fullName,
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.com_cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.success,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              vm.markPaid(fee.userId);
              Navigator.of(ctx).pop();
            },
            child: Text(context.l10n.settlement_confirm_received_money),
          ),
        ],
      ),
    );
  }

  void _confirmRequestCash(
    BuildContext context,
    MemberSettlementFee fee,
    SessionSettlementNotifier vm,
  ) {
    final colors = context.colors;
    final currencyFormat = NumberFormat('#,###');
    final amountToPay = fee.remainingFee > 0 ? fee.remainingFee : fee.finalFee;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Text(
          context.l10n.settlement_request_cash_confirm_title,
          style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
        ),
        content: Text(
          context.l10n.settlement_request_cash_confirm_message(
            currencyFormat.format(amountToPay),
          ),
          style: AppTypography.bodyMedium.colored(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.com_cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop();
              await vm.requestCashPayment(fee.userId, feeId: fee.feeId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.settlement_request_cash_success),
                    backgroundColor: colors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(context.l10n.settlement_request_cash),
          ),
        ],
      ),
    );
  }

  void _showVietQrModal(
    BuildContext context,
    MemberSettlementFee fee,
    String qrUrl,
    PaymentBankAccount? bank,
  ) {
    final colors = context.colors;
    final currencyFormat = NumberFormat('#,###');

    String qrPayload = '';
    if (bank != null && bank.accountNumber.trim().isNotEmpty) {
      String bin = bank.bankBin?.trim() ?? '';
      if (bin.isEmpty) {
        for (final b in vietQrBankDirectory) {
          if (b.name.toLowerCase() == bank.bankName.toLowerCase()) {
            bin = b.bin;
            break;
          }
        }
      }
      if (bin.isEmpty) bin = '970436';
      final cleanCode = fee.paymentCode.isNotEmpty ? fee.paymentCode : 'PAY_';
      qrPayload = VietQrHelper.generatePayload(
        bankBin: bin,
        accountNumber: bank.accountNumber.trim(),
        amount: fee.finalFee,
        message: cleanCode,
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Center(
          child: Text(
            context.l10n.settlement_vietqr_title,
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.card,
                  border: Border.all(color: colors.cardBorder),
                  color: AppColors.white,
                ),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: qrPayload.isNotEmpty || (qrUrl.isNotEmpty && !qrUrl.startsWith('https://') && !qrUrl.startsWith('http://'))
                    ? QrImageView(
                        data: !qrUrl.startsWith('http') && qrUrl.isNotEmpty ? qrUrl : qrPayload,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: AppColors.white,
                      )
                    : Image.network(
                        qrUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              color: colors.primary,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_rounded, size: 36, color: colors.textMuted),
                              AppSpacing.gapH4,
                              Text(
                                'Không thể tải mã QR',
                                style: AppTypography.labelSmall.colored(colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              AppSpacing.gapH12,
              Text(
                fee.fullName,
                style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
              ),
              AppSpacing.gapH4,
              Text(
                context.l10n.settlement_transfer_amount(
                  currencyFormat.format(fee.finalFee),
                ),
                style: AppTypography.titleMedium.bold.colored(colors.primary),
              ),
              if (bank != null && bank.accountNumber.isNotEmpty) ...[
                AppSpacing.gapH8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: AppRadius.tag,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bank.bankName} • ${bank.accountNumber}',
                              style: AppTypography.labelSmall.bold.colored(colors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bank.accountHolder,
                              style: AppTypography.labelSmall.colored(colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        tooltip: context.l10n.settlement_copy_account_number,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: bank.accountNumber.trim()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.settlement_account_number_copied(bank.accountNumber.trim()),
                              ),
                              backgroundColor: colors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
              AppSpacing.gapH8,
              Text(
                context.l10n.settlement_transfer_description(fee.paymentCode),
                style: AppTypography.bodySmall.colored(colors.textMuted),
              ),
              AppSpacing.gapH12,
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(context.l10n.settlement_copy_transfer_description),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: fee.paymentCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.settlement_transfer_description_copied(
                          fee.paymentCode,
                        ),
                      ),
                      backgroundColor: colors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.com_close),
          ),
        ],
      ),
    );
  }

  void _showUpdateConsumablesDialog(
    BuildContext context,
    SessionSettlement settlement,
    SessionSettlementNotifier vm,
    WidgetRef ref,
  ) {
    final colors = context.colors;
    final courtCtrl = TextEditingController(
      text: settlement.courtFee > 0 ? '${settlement.courtFee}' : '',
    );
    final shuttleCtrl = TextEditingController(
      text: '${settlement.shuttlecockUsed}',
    );
    final extraCtrl = TextEditingController(text: '${settlement.extraFee}');
    bool monthlyExemptCourtOnly = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text(context.l10n.settlement_consumables_dialog_title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: courtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiền thuê sân (đ)',
                    hintText: 'Nhập tiền sân, VD: 300000',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: shuttleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.settlement_shuttlecock_quantity,
                    hintText: context.l10n.settlement_shuttlecock_quantity_hint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: extraCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.settlement_extra_expense_label,
                    hintText: context.l10n.settlement_extra_expense_hint,
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: monthlyExemptCourtOnly,
                  onChanged: (v) => setDialogState(() => monthlyExemptCourtOnly = v ?? false),
                  title: Text(
                    'Hội viên tháng chỉ miễn tiền sân',
                    style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                  ),
                  subtitle: Text(
                    'Tiền cầu & phụ phí vẫn chia đều cho mọi người',
                    style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.com_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final courtText = courtCtrl.text.replaceAll('.', '').replaceAll(',', '').trim();
                final court = int.tryParse(courtText) ?? (courtText.isEmpty ? settlement.courtFee : 0);
                final used = int.tryParse(shuttleCtrl.text.trim()) ?? 0;
                final extra = int.tryParse(extraCtrl.text.trim()) ?? 0;
                HapticFeedback.lightImpact();
                Navigator.of(ctx).pop();
                try {
                  await vm.calculate(
                    courtRentalCost: court,
                    shuttlecockUsed: used,
                    extraFee: extra,
                    monthlyExemptCourtOnly: monthlyExemptCourtOnly,
                  );
                ref.read(sessionDetailViewModelProvider(sessionId).notifier).loadDetail();
              } catch (e) {
                if (context.mounted) {
                  final msg = e is AppException ? (e.message ?? e.toString()) : e.toString();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: colors.error,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            child: Text(
              settlement.isSettled
                  ? context.l10n.settlement_update_summary
                  : context.l10n.settlement_publish_summary,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Future<void> _confirmCompleteSessionFromSettlement(
    BuildContext context,
    WidgetRef ref,
    String sessionId, {
    required bool isSettled,
  }) async {
    final colors = context.colors;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (!isSettled) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Vui lòng bấm "Ghi nhận chi phí và tạo khoản thu" để chốt chi phí trước khi kết thúc buổi chơi.'),
          backgroundColor: colors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: colors.primary),
            AppSpacing.gapW8,
            Text(
              'Kết Thúc Buổi Chơi',
              style: AppTypography.titleMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn kết thúc buổi chơi này ngay bây giờ? Buổi chơi sẽ chuyển sang trạng thái hoàn thành và lưu lịch sử hoạt động.',
          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.com_cancel, style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Xác nhận kết thúc'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final vm = ref.read(sessionDetailViewModelProvider(sessionId).notifier);
    final ok = await vm.updateStatus('COMPLETED', confirmRemainingNoShows: true);
    if (!context.mounted) return;

    if (ok) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Buổi chơi đã kết thúc thành công.'),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.invalidate(sessionDetailViewModelProvider(sessionId));
      ref.read(sessionSettlementNotifierProvider(sessionId).notifier).loadSettlement();
    } else {
      final err = ref.read(sessionDetailViewModelProvider(sessionId)).errorMessage;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            err ?? 'Không thể kết thúc buổi chơi. Vui lòng kiểm tra lại trận đấu hoặc quyết toán chi phí.',
          ),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
