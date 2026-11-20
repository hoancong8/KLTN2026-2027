import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/consts/permissions.dart';
import '../../../../app/provider.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/reconciliation/reconciliation_transaction.dart';
import '../../../../widget/app_status_badge.dart';
import 'reconciliation_list_state.dart';
import 'reconciliation_list_vm.dart';

class ClubReconciliationsScreen extends ConsumerStatefulWidget {
  final String clubId;

  const ClubReconciliationsScreen({super.key, required this.clubId});

  @override
  ConsumerState<ClubReconciliationsScreen> createState() =>
      _ClubReconciliationsScreenState();
}

class _ClubReconciliationsScreenState
    extends ConsumerState<ClubReconciliationsScreen> {
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _currencyFormat = NumberFormat('#,###');
  final DateFormat _dateFormat = DateFormat('HH:mm - dd/MM/yyyy');

  AppThemeColors get colors => context.colors;

  String _messageForKey(String? key) => switch (key) {
    'reconciliation_load_list_failed' =>
      context.l10n.reconciliation_load_list_failed,
    'reconciliation_load_more_failed' =>
      context.l10n.reconciliation_load_more_failed,
    'error_system_retry' => context.l10n.error_system_retry,
    _ => context.l10n.error_system_retry,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(reconciliationListViewModelProvider(widget.clubId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManageFee = ref.hasClubPermission(ClubPermissions.feeManage);
    final state = ref.watch(reconciliationListViewModelProvider(widget.clubId));

    ref.listen<ReconciliationListState>(
      reconciliationListViewModelProvider(widget.clubId),
      (prev, next) {
        if ((next.errorMessage != null || next.errorMessageKey != null) &&
            (next.errorMessage != prev?.errorMessage ||
                next.errorMessageKey != prev?.errorMessageKey)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next.errorMessage ?? _messageForKey(next.errorMessageKey),
              ),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    if (!canManageFee) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            context.l10n.reconciliation_title,
            style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
          ),
          backgroundColor: colors.surface,
          elevation: 0.5,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded, size: 54, color: colors.error),
                AppSpacing.gapH16,
                Text(
                  context.l10n.reconciliation_permission_title,
                  style: AppTypography.titleMedium.bold.colored(
                    colors.textPrimary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  context.l10n.reconciliation_permission_required,
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapH24,
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(context.l10n.com_back),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.reconciliation_payment_title,
          style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: context.l10n.com_refresh,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading
                ? null
                : () => ref
                      .read(
                        reconciliationListViewModelProvider(
                          widget.clubId,
                        ).notifier,
                      )
                      .refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(bottom: BorderSide(color: colors.cardBorder)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: context.l10n.reconciliation_filter_manual,
                    isSelected: state.selectedStatus == 'MANUAL_CHECK',
                    onSelected: () => ref
                        .read(
                          reconciliationListViewModelProvider(
                            widget.clubId,
                          ).notifier,
                        )
                        .changeFilter('MANUAL_CHECK'),
                  ),
                  AppSpacing.gapW8,
                  _buildFilterChip(
                    label: context.l10n.reconciliation_filter_matched,
                    isSelected: state.selectedStatus == 'MATCHED',
                    onSelected: () => ref
                        .read(
                          reconciliationListViewModelProvider(
                            widget.clubId,
                          ).notifier,
                        )
                        .changeFilter('MATCHED'),
                  ),
                  AppSpacing.gapW8,
                  _buildFilterChip(
                    label: context.l10n.reconciliation_filter_all,
                    isSelected: state.selectedStatus == null,
                    onSelected: () => ref
                        .read(
                          reconciliationListViewModelProvider(
                            widget.clubId,
                          ).notifier,
                        )
                        .changeFilter(null),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: state.isLoading && state.transactions.isEmpty
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              color: colors.primary,
              onRefresh: () => ref
                  .read(
                    reconciliationListViewModelProvider(widget.clubId).notifier,
                  )
                  .refresh(),
              child: state.transactions.isEmpty
                  ? _buildEmptyState()
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.base),
                          itemCount:
                              state.transactions.length +
                              (state.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => AppSpacing.gapH12,
                          itemBuilder: (context, index) {
                            if (index == state.transactions.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                ),
                              );
                            }
                            final tx = state.transactions[index];
                            return _buildTransactionCard(tx);
                          },
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: isSelected
          ? AppTypography.labelSmall.bold.colored(AppColors.white)
          : AppTypography.labelSmall.colored(colors.textSecondary),
      backgroundColor: colors.inputFill,
      selectedColor: colors.primary,
      checkmarkColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.cardBorder,
        ),
      ),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildTransactionCard(ReconciliationTransaction tx) {
    final isMatched = tx.isMatched;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: InkWell(
        onTap: () async {
          await context.push(
            '/club/${widget.clubId}/reconciliations/${tx.transactionId}',
          );
          // Refresh list on return to see updated status
          ref
              .read(reconciliationListViewModelProvider(widget.clubId).notifier)
              .refresh();
        },
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isMatched ? colors.success : colors.warning)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isMatched
                              ? Icons.check_circle_outline_rounded
                              : Icons.help_outline_rounded,
                          color: isMatched ? colors.success : colors.warning,
                          size: 20,
                        ),
                      ),
                      AppSpacing.gapW8,
                      Text(
                        context.l10n.reconciliation_incoming_amount(
                          _currencyFormat.format(tx.amountReceived),
                        ),
                        style: AppTypography.titleMedium.bold.colored(
                          isMatched ? colors.success : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (isMatched)
                    AppStatusBadge.success(
                      label: context.l10n.reconciliation_status_matched,
                    )
                  else
                    AppStatusBadge.warning(
                      label: context.l10n.reconciliation_status_manual_check,
                    ),
                ],
              ),
              AppSpacing.gapH12,
              Text(
                tx.transferContent,
                style: AppTypography.bodyMedium.colored(colors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.gapH8,
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (tx.reasonCode != null && tx.reasonCode!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _formatReasonCode(tx.reasonCode!),
                        style: AppTypography.labelSmall.bold.colored(
                          colors.error,
                        ),
                      ),
                    ),
                  if (tx.referenceCode != null && tx.referenceCode!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.inputFill,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${context.l10n.reconciliation_reference_prefix}: ${tx.referenceCode}',
                        style: AppTypography.labelSmall.colored(
                          colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              AppSpacing.gapH8,
              Divider(height: 1, color: colors.cardBorder),
              AppSpacing.gapH8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateFormat.format(tx.transactionTime),
                    style: AppTypography.bodySmall.colored(colors.textMuted),
                  ),
                  Row(
                    children: [
                      Text(
                        isMatched
                            ? context.l10n.reconciliation_action_view
                            : context.l10n.reconciliation_action_process,
                        style: AppTypography.labelSmall.bold.colored(
                          colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReasonCode(String code) {
    switch (code) {
      case 'MISSING_CODE':
        return context.l10n.reconciliation_reason_missing_payment_code;
      case 'MULTIPLE_CODES':
        return context.l10n.reconciliation_reason_multiple_payment_codes;
      case 'FEE_NOT_FOUND':
        return context.l10n.reconciliation_reason_fee_not_found;
      case 'AMOUNT_MISMATCH':
        return context.l10n.reconciliation_reason_amount_mismatch;
      case 'ALREADY_PAID':
        return context.l10n.reconciliation_reason_fee_already_paid;
      case 'REFERENCE_COLLISION':
        return context.l10n.reconciliation_reason_duplicate_reference;
      default:
        return context.l10n.reconciliation_reason_unknown;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colors.textMuted,
            ),
            AppSpacing.gapH16,
            Text(
              context.l10n.reconciliation_empty_title,
              style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
            ),
            AppSpacing.gapH8,
            Text(
              context.l10n.reconciliation_empty_message,
              style: AppTypography.bodySmall.colored(colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
