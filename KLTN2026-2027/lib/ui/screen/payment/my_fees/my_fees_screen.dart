import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/consts/app_config.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../app/utils/exception_ext.dart';
import '../../../../domain/entities/payment/personal_fee.dart';
import '../../../../widget/responsive_layout.dart';
import 'my_fees_state.dart';
import 'my_fees_vm.dart';

class MyFeesScreen extends ConsumerWidget {
  const MyFeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myFeesViewModelProvider);
    final vm = ref.read(myFeesViewModelProvider.notifier);
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.payment_my_fees),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
      ),
      body: ResponsiveLayout(
        mobile: _buildBody(context, state, vm, maxWidth: double.infinity),
        tablet: _buildBody(context, state, vm, maxWidth: 900),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MyFeesState state,
    MyFeesViewModel vm, {
    required double maxWidth,
  }) {
    final l10n = context.l10n;
    final colors = context.colors;
    final filters = <String?, String>{
      'UNPAID': l10n.payment_unpaid,
      'PAID': l10n.payment_paid,
      'EXEMPT': l10n.payment_exempt,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                ),
                scrollDirection: Axis.horizontal,
                children: filters.entries.map((entry) {
                  final selected = state.statusFilter == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: selected,
                      onSelected: (_) => vm.load(filter: entry.key),
                      selectedColor: colors.primaryContainer,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: selected ? colors.primary : colors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => vm.load(refresh: true),
                child: state.isLoading && state.fees.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 220),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : state.error != null && state.fees.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 100),
                          _MessageState(
                            icon: Icons.cloud_off_outlined,
                            title: l10n.payment_load_error,
                            detail: state.error!.getDisplayMessage(l10n),
                            actionLabel: l10n.payment_retry,
                            onAction: () => vm.load(refresh: true),
                          ),
                        ],
                      )
                    : state.fees.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 110),
                          _MessageState(
                            icon: Icons.receipt_long_outlined,
                            title: l10n.payment_empty,
                            detail: l10n.payment_empty_hint,
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.base),
                        itemCount:
                            state.fees.length +
                            (state.error == null ? 0 : 1) +
                            (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (state.error != null &&
                              index == state.fees.length) {
                            return _MessageState(
                              icon: Icons.cloud_off_outlined,
                              title: l10n.payment_load_error,
                              detail: state.error!.getDisplayMessage(l10n),
                              actionLabel: l10n.payment_retry,
                              onAction: () => vm.load(refresh: true),
                            );
                          }
                          final loadMoreIndex =
                              state.fees.length + (state.error == null ? 0 : 1);
                          if (state.hasMore && index == loadMoreIndex) {
                            return Center(
                              child: TextButton(
                                onPressed: state.isLoadingMore
                                    ? null
                                    : vm.loadMore,
                                child: state.isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : Text(l10n.payment_load_more),
                              ),
                            );
                          }
                          final fee = state.fees[index];
                          return _FeeCard(fee: fee);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final PersonalFee fee;
  const _FeeCard({required this.fee});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final date = fee.sessionStart == null
        ? null
        : DateFormat.yMMMd(
            Localizations.localeOf(context).languageCode,
          ).add_Hm().format(fee.sessionStart!.toLocal());
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: colors.cardBorder),
      ),
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppConfig.myFeeDetailPath(fee.feeId)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fee.groupName.isEmpty
                          ? l10n.payment_group
                          : fee.groupName,
                      style: AppTypography.titleSmall.bold.colored(
                        colors.textPrimary,
                      ),
                    ),
                  ),
                  _StatusChip(status: fee.paymentStatus),
                ],
              ),
              if (date != null) ...[
                AppSpacing.gapH8,
                Text(
                  '${l10n.payment_session}: $date',
                  style: AppTypography.bodySmall.colored(colors.textSecondary),
                ),
              ],
              AppSpacing.gapH12,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.payment_amount,
                      style: AppTypography.labelMedium.colored(
                        colors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    _money(fee.amount, fee.currency),
                    style: AppTypography.titleSmall.bold.colored(
                      colors.primary,
                    ),
                  ),
                  AppSpacing.gapW8,
                  Icon(Icons.chevron_right_rounded, color: colors.textMuted),
                ],
              ),
              if (fee.paymentProgress?.toUpperCase() ==
                  'AWAITING_RECONCILIATION') ...[
                AppSpacing.gapH8,
                Text(
                  l10n.payment_waiting_reconciliation,
                  style: AppTypography.bodySmall.colored(colors.warning),
                ),
              ] else if (fee.paymentProgress?.toUpperCase() ==
                  'CASH_CONFIRMATION_REQUESTED') ...[
                AppSpacing.gapH8,
                Text(
                  l10n.payment_waiting_cash,
                  style: AppTypography.bodySmall.colored(colors.warning),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final normalized = status.toUpperCase();
    final l10n = context.l10n;
    final label = switch (normalized) {
      'UNPAID' => l10n.payment_unpaid,
      'PAID' => l10n.payment_paid,
      'EXEMPT' => l10n.payment_exempt,
      _ => l10n.payment_unknown_status,
    };
    final color = switch (normalized) {
      'PAID' => colors.success,
      'EXEMPT' => colors.info,
      'UNPAID' => colors.warning,
      _ => colors.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.tag,
      ),
      child: Text(label, style: AppTypography.labelSmall.bold.colored(color)),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _MessageState({
    required this.icon,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 46, color: colors.textMuted),
          AppSpacing.gapH12,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
          ),
          AppSpacing.gapH8,
          Text(
            detail,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.colored(colors.textSecondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            AppSpacing.gapH12,
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _money(num? amount, String currency) {
  if (amount == null) return '—';
  return '${NumberFormat('#,##0.##', 'vi_VN').format(amount)} ${currency.isEmpty ? 'VND' : currency}';
}
