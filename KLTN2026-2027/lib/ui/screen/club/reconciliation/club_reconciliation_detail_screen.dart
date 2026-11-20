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
import 'reconciliation_detail_state.dart';
import 'reconciliation_detail_vm.dart';

class ClubReconciliationDetailScreen extends ConsumerStatefulWidget {
  final String clubId;
  final String transactionId;

  const ClubReconciliationDetailScreen({
    super.key,
    required this.clubId,
    required this.transactionId,
  });

  @override
  ConsumerState<ClubReconciliationDetailScreen> createState() =>
      _ClubReconciliationDetailScreenState();
}

class _ClubReconciliationDetailScreenState
    extends ConsumerState<ClubReconciliationDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  final NumberFormat _currencyFormat = NumberFormat('#,###');
  final DateFormat _dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
  bool _defaultReasonInitialized = false;

  AppThemeColors get colors => context.colors;

  String _messageForKey(String? key) => switch (key) {
    'reconciliation_load_detail_failed' =>
      context.l10n.reconciliation_load_detail_failed,
    'reconciliation_fee_required' => context.l10n.reconciliation_fee_required,
    'reconciliation_manual_reason_required' =>
      context.l10n.reconciliation_manual_reason_required,
    'reconciliation_manual_reason_too_long' =>
      context.l10n.reconciliation_manual_reason_too_long,
    'reconciliation_manual_confirm_succeeded' =>
      context.l10n.reconciliation_manual_confirm_succeeded,
    'reconciliation_manual_confirm_failed' =>
      context.l10n.reconciliation_manual_confirm_failed,
    'error_system_retry' => context.l10n.error_system_retry,
    _ => context.l10n.error_system_retry,
  };

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultReasonInitialized) {
      _reasonController.text = context.l10n.reconciliation_default_reason;
      _defaultReasonInitialized = true;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  ReconciliationDetailParams get _params => ReconciliationDetailParams(
    clubId: widget.clubId,
    transactionId: widget.transactionId,
  );

  Future<void> _handleConfirmManual() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(
      reconciliationDetailViewModelProvider(_params).notifier,
    );
    await vm.confirmManual(reason: _reasonController.text);
  }

  @override
  Widget build(BuildContext context) {
    final canManageFee = ref.hasClubPermission(ClubPermissions.feeManage);
    final canViewFee = ref.hasClubPermission(ClubPermissions.feeView);
    final state = ref.watch(reconciliationDetailViewModelProvider(_params));

    ref.listen<ReconciliationDetailState>(
      reconciliationDetailViewModelProvider(_params),
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
        if (next.successMessageKey != null &&
            next.successMessageKey != prev?.successMessageKey) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_messageForKey(next.successMessageKey)),
              backgroundColor: colors.primary,
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
            context.l10n.reconciliation_detail_title,
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
                  context.l10n.reconciliation_detail_permission_title,
                  style: AppTypography.titleMedium.bold.colored(
                    colors.textPrimary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  context.l10n.reconciliation_detail_permission_required,
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

    final tx = state.transaction;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.reconciliation_detail_title,
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
                        reconciliationDetailViewModelProvider(_params).notifier,
                      )
                      .loadDetail(),
          ),
        ],
      ),
      body: state.isLoading && tx == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : tx == null
          ? Center(
              child: Text(
                context.l10n.reconciliation_transaction_not_found,
                style: AppTypography.bodyMedium.colored(colors.textMuted),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(tx),
                      AppSpacing.gapH16,
                      _buildEvidenceCard(tx),
                      AppSpacing.gapH16,
                      if (tx.isMatched) ...[
                        _buildMatchedAuditCard(tx),
                        AppSpacing.gapH16,
                      ] else if (tx.isManualCheck) ...[
                        _buildManualCheckActionCard(tx, state, canViewFee),
                        AppSpacing.gapH16,
                      ],
                      _buildSafetyNoteCard(),
                      AppSpacing.gapH24,
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(ReconciliationTransaction tx) {
    final isMatched = tx.isMatched;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.reconciliation_received_amount,
                style: AppTypography.labelSmall.bold.colored(
                  colors.textSecondary,
                ),
              ),
              AppSpacing.gapH4,
              Text(
                context.l10n.reconciliation_incoming_amount(
                  _currencyFormat.format(tx.amountReceived),
                ),
                style: AppTypography.titleLarge.bold.colored(
                  isMatched ? colors.success : colors.textPrimary,
                ),
              ),
            ],
          ),
          if (isMatched)
            AppStatusBadge.success(
              label: context.l10n.reconciliation_status_matched_full,
            )
          else
            AppStatusBadge.warning(
              label: context.l10n.reconciliation_status_manual_check_full,
            ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(ReconciliationTransaction tx) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined, color: colors.primary, size: 22),
              AppSpacing.gapW8,
              Text(
                context.l10n.reconciliation_bank_evidence,
                style: AppTypography.titleMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          _buildDetailRow(
            label: context.l10n.reconciliation_transfer_description,
            value: tx.transferContent,
            isImportant: true,
          ),
          AppSpacing.gapH12,
          _buildDetailRow(
            label: context.l10n.reconciliation_transaction_time,
            value: _dateFormat.format(tx.transactionTime),
          ),
          AppSpacing.gapH12,
          _buildDetailRow(
            label: context.l10n.reconciliation_bank_reference,
            value: tx.referenceCode != null && tx.referenceCode!.isNotEmpty
                ? tx.referenceCode!
                : context.l10n.reconciliation_not_available,
          ),
          AppSpacing.gapH12,
          _buildDetailRow(
            label: context.l10n.reconciliation_sepay_transaction_id,
            value: tx.providerTransactionId != null
                ? '#${tx.providerTransactionId}'
                : context.l10n.reconciliation_not_available,
          ),
          AppSpacing.gapH12,
          _buildDetailRow(
            label: context.l10n.reconciliation_transaction_id,
            value: tx.transactionId,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedAuditCard(ReconciliationTransaction tx) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: colors.success, size: 22),
              AppSpacing.gapW8,
              Text(
                context.l10n.reconciliation_confirmation_info,
                style: AppTypography.titleMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH16,
          _buildDetailRow(
            label: context.l10n.reconciliation_assigned_fee,
            value:
                tx.feeId ?? context.l10n.reconciliation_fee_payment_code_auto,
          ),
          AppSpacing.gapH12,
          _buildDetailRow(
            label: context.l10n.reconciliation_confirmed_by,
            value: tx.reconciledBy != null
                ? tx.reconciledBy!
                : context.l10n.reconciliation_system_auto,
          ),
          AppSpacing.gapH12,
          _buildDetailRow(
            label: context.l10n.reconciliation_confirmed_at,
            value: tx.reconciledAt != null
                ? _dateFormat.format(tx.reconciledAt!)
                : _dateFormat.format(tx.transactionTime),
          ),
          if (tx.note != null && tx.note!.isNotEmpty) ...[
            AppSpacing.gapH12,
            _buildDetailRow(
              label: context.l10n.reconciliation_note,
              value: tx.note!,
            ),
          ],
          AppSpacing.gapH16,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(context.l10n.reconciliation_view_club_ledger),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              onPressed: () => context.push('/club/${widget.clubId}/ledger'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualCheckActionCard(
    ReconciliationTransaction tx,
    ReconciliationDetailState state,
    bool canViewFee,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: colors.warning, size: 22),
                AppSpacing.gapW8,
                Text(
                  context.l10n.reconciliation_manual_title,
                  style: AppTypography.titleMedium.bold.colored(
                    colors.textPrimary,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH12,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _getReasonCodeExplanation(tx.reasonCode),
                style: AppTypography.bodySmall.colored(colors.textPrimary),
              ),
            ),
            AppSpacing.gapH16,
            if (!canViewFee) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  context.l10n.reconciliation_fee_view_permission_required,
                  style: AppTypography.bodySmall.colored(colors.error),
                ),
              ),
            ] else ...[
              Text(
                context.l10n.reconciliation_select_session,
                style: AppTypography.labelMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
              AppSpacing.gapH8,
              if (state.isLoadingSessions)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (state.clubSessions.isEmpty)
                Text(
                  context.l10n.reconciliation_sessions_empty,
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                )
              else
                DropdownButtonFormField<String>(
                  value: state.selectedSessionId,
                  dropdownColor: colors.cardBackground,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: BorderSide(color: colors.inputBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: state.clubSessions.map((session) {
                    final dateStr = DateFormat(
                      'dd/MM HH:mm',
                    ).format(session.startTime);
                    return DropdownMenuItem<String>(
                      value: session.id,
                      child: Text(
                        '${session.title} ($dateStr)',
                        style: AppTypography.bodySmall.colored(
                          colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(
                            reconciliationDetailViewModelProvider(
                              _params,
                            ).notifier,
                          )
                          .selectSession(val);
                    }
                  },
                ),
              AppSpacing.gapH16,
              Text(
                context.l10n.reconciliation_select_fee(
                  _currencyFormat.format(tx.amountReceived),
                ),
                style: AppTypography.labelMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
              AppSpacing.gapH4,
              Text(
                context.l10n.reconciliation_fee_candidates_help,
                style: AppTypography.bodySmall.colored(colors.textMuted),
              ),
              AppSpacing.gapH8,
              if (state.isLoadingCandidates)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (state.candidateFees.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Text(
                    context.l10n.reconciliation_fee_candidates_empty(
                      _currencyFormat.format(tx.amountReceived),
                    ),
                    style: AppTypography.bodySmall.colored(colors.textMuted),
                  ),
                )
              else
                ...state.candidateFees.map((fee) {
                  final isSelected = state.selectedFeeId == fee.feeId;

                  return InkWell(
                    onTap: () => ref
                        .read(
                          reconciliationDetailViewModelProvider(
                            _params,
                          ).notifier,
                        )
                        .selectCandidateFee(fee.feeId),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.08)
                            : colors.inputFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.cardBorder,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: fee.feeId,
                            groupValue: state.selectedFeeId,
                            activeColor: colors.primary,
                            onChanged: (v) {
                              if (v != null) {
                                ref
                                    .read(
                                      reconciliationDetailViewModelProvider(
                                        _params,
                                      ).notifier,
                                    )
                                    .selectCandidateFee(v);
                              }
                            },
                          ),
                          AppSpacing.gapW8,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      fee.fullName,
                                      style: AppTypography.labelMedium.bold
                                          .colored(colors.textPrimary),
                                    ),
                                    Text(
                                      context.l10n.reconciliation_fee_amount(
                                        _currencyFormat.format(fee.finalFee),
                                      ),
                                      style: AppTypography.labelMedium.bold
                                          .colored(colors.primary),
                                    ),
                                  ],
                                ),
                                AppSpacing.gapH4,
                                Text(
                                  context.l10n
                                      .reconciliation_payment_code_value(
                                        fee.paymentCode.isNotEmpty
                                            ? fee.paymentCode
                                            : fee.feeId,
                                      ),
                                  style: AppTypography.bodySmall.colored(
                                    colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              AppSpacing.gapH16,
              Text(
                context.l10n.reconciliation_manual_reason,
                style: AppTypography.labelMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
              AppSpacing.gapH4,
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: context.l10n.reconciliation_reason_hint,
                  filled: true,
                  fillColor: colors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide(color: colors.inputBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.l10n.reconciliation_reason_required;
                  }
                  if (v.trim().length > 2000) {
                    return context.l10n.reconciliation_reason_too_long;
                  }
                  return null;
                },
              ),
              AppSpacing.gapH16,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: state.isConfirming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                  label: Text(context.l10n.reconciliation_confirm_manual),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  onPressed: state.isConfirming || state.selectedFeeId == null
                      ? null
                      : _handleConfirmManual,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isImportant = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.bold.colored(colors.textSecondary),
        ),
        AppSpacing.gapH4,
        SelectableText(
          value,
          style: isImportant
              ? AppTypography.bodyMedium.bold.colored(colors.textPrimary)
              : AppTypography.bodySmall.colored(colors.textPrimary),
        ),
      ],
    );
  }

  String _getReasonCodeExplanation(String? code) {
    final explanation = switch (code) {
      'MISSING_CODE' =>
        context.l10n.reconciliation_explanation_missing_payment_code,
      'MULTIPLE_CODES' =>
        context.l10n.reconciliation_explanation_multiple_payment_codes,
      'FEE_NOT_FOUND' => context.l10n.reconciliation_explanation_fee_not_found,
      'AMOUNT_MISMATCH' =>
        context.l10n.reconciliation_explanation_amount_mismatch,
      'ALREADY_PAID' =>
        context.l10n.reconciliation_explanation_fee_already_paid,
      'REFERENCE_COLLISION' =>
        context.l10n.reconciliation_explanation_duplicate_reference,
      _ => context.l10n.reconciliation_explanation_generic,
    };
    return '${context.l10n.reconciliation_reason_prefix}$explanation';
  }

  Widget _buildSafetyNoteCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
              AppSpacing.gapW8,
              Text(
                context.l10n.reconciliation_financial_safety_title,
                style: AppTypography.labelMedium.bold.colored(
                  colors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            context.l10n.reconciliation_financial_safety_notes,
            style: AppTypography.bodySmall.colored(colors.textMuted),
          ),
        ],
      ),
    );
  }
}
