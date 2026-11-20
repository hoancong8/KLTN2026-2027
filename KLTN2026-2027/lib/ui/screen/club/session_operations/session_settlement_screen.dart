// lib/ui/screen/club/session_operations/session_settlement_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_settlement.dart';
import '../../../../widget/app_shimmer.dart';
import '../../../../widget/app_status_badge.dart';

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

  SessionSettlementNotifier(this._repo, this.sessionId)
    : super(const AsyncValue.loading()) {
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

  Future<void> calculate({
    required int shuttlecockUsed,
    required int extraFee,
  }) async {
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
      final updated = await _repo.markMemberPaid(
        sessionId: sessionId,
        userId: userId,
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
                              ),
                            ),
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
                    else
                      ...settlement.memberFees.map(
                        (fee) => _buildMemberFeeCard(context, fee, vm),
                      ),

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
    switch (role.trim().toUpperCase()) {
      case 'MONTHLY_MEMBER':
      case 'MEMBER_MONTHLY':
        return context.l10n.settlement_role_monthly_member;
      case 'DAILY_MEMBER':
      case 'MEMBER_DAILY':
        return context.l10n.settlement_role_daily_member;
      case 'GUEST':
        return context.l10n.settlement_role_guest;
      default:
        return context.l10n.settlement_role_unknown;
    }
  }

  Widget _buildMemberFeeCard(
    BuildContext context,
    MemberSettlementFee fee,
    SessionSettlementNotifier vm,
  ) {
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
          color: isPaid
              ? colors.success.withValues(alpha: 0.3)
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
                    Text(
                      fee.fullName,
                      style: AppTypography.titleSmall.bold.colored(
                        colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.settlement_role_gender(
                        _formatRoleName(context, fee.roleName),
                        fee.gender == 'FEMALE'
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
                    context.l10n.settlement_amount(
                      currencyFormat.format(fee.finalFee),
                    ),
                    style: AppTypography.titleSmall.bold.colored(
                      isPaid ? colors.success : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  isPaid
                      ? AppStatusBadge.success(
                          label: context.l10n.settlement_paid_badge,
                        )
                      : AppStatusBadge.warning(
                          label: context.l10n.settlement_unpaid_badge,
                        ),
                ],
              ),
            ],
          ),
          if (!isPaid &&
              !fee.isExempt &&
              (fee.vietQrUrl.isNotEmpty || fee.isCashEligible)) ...[
            AppSpacing.gapH12,
            Divider(height: 1, color: colors.cardBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (fee.vietQrUrl.isNotEmpty)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.4),
                      ),
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: Text(context.l10n.settlement_vietqr_label),
                    onPressed: () => _showVietQrModal(context, fee),
                  )
                else
                  const SizedBox.shrink(),
                if (fee.isCashEligible)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(context.l10n.settlement_confirm_cash),
                    onPressed: () => _confirmMarkPaid(context, fee, vm),
                  ),
              ],
            ),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settlement_confirm_cash_title),
        content: Text(
          context.l10n.settlement_confirm_cash_message(
            currencyFormat.format(fee.finalFee),
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

  void _showVietQrModal(BuildContext context, MemberSettlementFee fee) {
    final colors = context.colors;
    final currencyFormat = NumberFormat('#,###');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        title: Center(
          child: Text(
            context.l10n.settlement_vietqr_title,
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
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
            AppSpacing.gapH4,
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
  ) {
    final shuttleCtrl = TextEditingController(
      text: '${settlement.shuttlecockUsed}',
    );
    final extraCtrl = TextEditingController(text: '${settlement.extraFee}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settlement_consumables_dialog_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.com_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final used = int.tryParse(shuttleCtrl.text.trim()) ?? 0;
              final extra = int.tryParse(extraCtrl.text.trim()) ?? 0;
              HapticFeedback.lightImpact();
              vm.calculate(shuttlecockUsed: used, extraFee: extra);
              Navigator.of(ctx).pop();
            },
            child: Text(
              settlement.isSettled
                  ? context.l10n.settlement_update_summary
                  : context.l10n.settlement_publish_summary,
            ),
          ),
        ],
      ),
    );
  }
}
