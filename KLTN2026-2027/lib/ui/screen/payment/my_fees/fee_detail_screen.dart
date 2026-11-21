import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../app/utils/exception_ext.dart';
import '../../../../domain/entities/payment/personal_fee.dart';
import '../../../../domain/exceptions/app_exception.dart';
import '../../../../widget/responsive_layout.dart';
import 'fee_detail_state.dart';
import 'fee_detail_vm.dart';

class FeeDetailScreen extends ConsumerWidget {
  final String feeId;
  const FeeDetailScreen({super.key, required this.feeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feeDetailViewModelProvider(feeId));
    final vm = ref.read(feeDetailViewModelProvider(feeId).notifier);
    final l10n = context.l10n;
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.payment_detail),
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        actions: [
          IconButton(
            tooltip: l10n.payment_details_refresh,
            onPressed: state.isLoading ? null : vm.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildBody(context, state, vm, 760),
        tablet: _buildBody(context, state, vm, 900),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeeDetailState state,
    FeeDetailViewModel vm,
    double maxWidth,
  ) {
    final l10n = context.l10n;
    final colors = context.colors;
    if (state.isLoading && state.fee == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.fee == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 42, color: colors.error),
              AppSpacing.gapH12,
              Text(
                state.error!.getDisplayMessage(l10n),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapH12,
              FilledButton(
                onPressed: vm.refresh,
                child: Text(l10n.payment_retry),
              ),
              if (state.error is NotFoundException) ...[
                AppSpacing.gapH8,
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.payment_back_to_fees),
                ),
              ],
            ],
          ),
        ),
      );
    }
    final PersonalFee? fee = state.fee;
    if (fee == null) return const SizedBox.shrink();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.groupName.isEmpty
                          ? l10n.payment_group
                          : fee.groupName,
                      style: AppTypography.titleLarge.bold.colored(
                        colors.textPrimary,
                      ),
                    ),
                    AppSpacing.gapH8,
                    _InfoLine(
                      label: l10n.payment_publication_state,
                      value: _publicationLabel(fee.publicationState, l10n),
                    ),
                    AppSpacing.gapH8,
                    if (fee.sessionStart != null)
                      _InfoLine(
                        label: l10n.payment_session,
                        value: DateFormat.yMMMd(
                          Localizations.localeOf(context).languageCode,
                        ).add_Hm().format(fee.sessionStart!.toLocal()),
                      ),
                    if (fee.paymentCode.isNotEmpty)
                      _InfoLine(
                        label: l10n.payment_code,
                        value: fee.paymentCode,
                      ),
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
                          style: AppTypography.titleLarge.bold.colored(
                            colors.primary,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapH12,
                    Row(
                      children: [
                        Text(
                          '${l10n.payment_status}: ',
                          style: AppTypography.labelMedium.colored(
                            colors.textSecondary,
                          ),
                        ),
                        _FeeStatusChip(status: fee.paymentStatus),
                      ],
                    ),
                    if (fee.paymentProgress?.toUpperCase() == 'QR_READY') ...[
                      AppSpacing.gapH8,
                      Text(
                        l10n.payment_qr_ready,
                        style: AppTypography.bodySmall.colored(colors.warning),
                      ),
                    ] else if (fee.paymentProgress != null &&
                        !const {
                          'AWAITING_RECONCILIATION',
                          'CASH_CONFIRMATION_REQUESTED',
                        }.contains(fee.paymentProgress!.toUpperCase())) ...[
                      AppSpacing.gapH8,
                      Text(
                        l10n.payment_unknown_status,
                        style: AppTypography.bodySmall.colored(
                          colors.textMuted,
                        ),
                      ),
                    ],
                    if (fee.paymentProgress?.toUpperCase() ==
                        'AWAITING_RECONCILIATION') ...[
                      AppSpacing.gapH12,
                      _Notice(
                        text: l10n.payment_waiting_reconciliation,
                        color: colors.warning,
                      ),
                    ] else if (fee.paymentProgress?.toUpperCase() ==
                        'CASH_CONFIRMATION_REQUESTED') ...[
                      AppSpacing.gapH12,
                      _Notice(
                        text: l10n.payment_waiting_cash,
                        color: colors.warning,
                      ),
                    ],
                    if (state.isLoading) ...[
                      AppSpacing.gapH12,
                      const LinearProgressIndicator(),
                    ],
                    if (state.error != null) ...[
                      AppSpacing.gapH12,
                      _Notice(
                        text: state.error!.getDisplayMessage(l10n),
                        color: colors.error,
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.gapH12,
              _buildBreakdown(context, fee),
              if (fee.isPaid && fee.receipt != null) ...[
                AppSpacing.gapH12,
                _buildReceipt(context, fee.receipt!),
              ],
              if (!fee.isPaid &&
                  !fee.isExempt &&
                  fee.paymentInstructions != null) ...[
                AppSpacing.gapH12,
                _buildTransferInstructions(context, state, vm, fee),
              ],
              if (state.successMessage != null) ...[
                AppSpacing.gapH12,
                _Notice(text: state.successMessage!, color: colors.success),
              ],
              if (!fee.isPaid && !fee.isExempt) ...[
                AppSpacing.gapH12,
                _buildActions(context, state, vm, fee),
              ],
              AppSpacing.gapH24,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdown(BuildContext context, PersonalFee fee) {
    final l10n = context.l10n;
    final colors = context.colors;
    final breakdown = fee.breakdown;
    return _Panel(
      title: l10n.payment_breakdown,
      child: breakdown == null
          ? Text(
              l10n.payment_no_breakdown,
              style: AppTypography.bodySmall.colored(colors.textSecondary),
            )
          : Column(
              children: [
                _optionalLine(
                  context,
                  context.l10n.payment_court_share,
                  breakdown.courtShare,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_shuttle_share,
                  breakdown.shuttleShare,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_extra_share,
                  breakdown.extraShare,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_monthly_fund,
                  breakdown.monthlyFundCovered,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_base_amount,
                  breakdown.baseAmount,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_calculated_amount,
                  breakdown.calculatedAmount,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_rounding_delta,
                  breakdown.roundingDelta,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_adjustment_delta,
                  breakdown.adjustmentDelta,
                  fee.currency,
                ),
                _optionalLine(
                  context,
                  context.l10n.payment_discount_applied,
                  breakdown.discountApplied,
                  fee.currency,
                ),
                if (breakdown.adjustmentReason?.isNotEmpty == true)
                  _InfoLine(
                    label: context.l10n.payment_adjustment_reason,
                    value: breakdown.adjustmentReason!,
                  ),
              ].whereType<Widget>().toList(),
            ),
    );
  }

  Widget? _optionalLine(
    BuildContext context,
    String label,
    num? amount,
    String currency,
  ) => amount == null
      ? null
      : _InfoLine(label: label, value: _money(amount, currency));

  Widget _buildTransferInstructions(
    BuildContext context,
    FeeDetailState state,
    FeeDetailViewModel vm,
    PersonalFee fee,
  ) {
    final l10n = context.l10n;
    final colors = context.colors;
    final instructions = fee.paymentInstructions!;
    final bank = instructions.bank;
    return _Panel(
      title: l10n.payment_qr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(label: l10n.payment_bank, value: bank.bankName),
          _InfoLine(
            label: l10n.payment_account_number,
            value: bank.accountNumber,
          ),
          _InfoLine(
            label: l10n.payment_account_holder,
            value: bank.accountHolder,
          ),
          _InfoLine(
            label: l10n.payment_transfer_content,
            value: fee.paymentCode,
          ),
          AppSpacing.gapH12,
          if (state.qrBytes != null) ...[
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 340,
                  maxHeight: 340,
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                color: Colors.white,
                child: Image.memory(
                  state.qrBytes!,
                  fit: BoxFit.contain,
                  gaplessPlayback: false,
                  errorBuilder: (_, _, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.payment_qr_error),
                      TextButton(
                        onPressed: state.isQrLoading ? null : vm.loadQr,
                        child: Text(l10n.payment_qr_reload),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppSpacing.gapH12,
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _copyQrImage(context, state.qrBytes!),
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.payment_qr_copy_image),
              ),
            ),
          ] else if (state.isQrLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (state.qrError != null)
              _Notice(text: l10n.payment_qr_error, color: colors.error),
            AppSpacing.gapH8,
            OutlinedButton.icon(
              onPressed: state.isQrLoading ? null : vm.loadQr,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.payment_qr_reload),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copyQrImage(BuildContext context, Uint8List imageBytes) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.payment_qr_image_copy_failed)),
      );
      return;
    }

    try {
      final item = DataWriterItem();
      item.add(Formats.png(imageBytes));
      await clipboard.write([item]);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.payment_qr_image_copied)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.payment_qr_image_copy_failed)),
      );
    }
  }

  Widget _buildReceipt(BuildContext context, PaymentReceipt receipt) {
    final l10n = context.l10n;
    return _Panel(
      title: l10n.payment_receipt,
      child: Column(
        children: [
          if (receipt.amount != null)
            _InfoLine(
              label: l10n.payment_amount,
              value: _money(receipt.amount, 'VND'),
            ),
          if (receipt.paymentCode.isNotEmpty)
            _InfoLine(label: l10n.payment_code, value: receipt.paymentCode),
          if (receipt.paidAt != null)
            _InfoLine(
              label: l10n.payment_paid_at,
              value: DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).add_Hms().format(receipt.paidAt!.toLocal()),
            ),
          if (receipt.method?.isNotEmpty == true)
            _InfoLine(
              label: l10n.payment_method,
              value: _methodLabel(receipt.method!, l10n),
            ),
          if (receipt.metadataIncomplete) ...[
            AppSpacing.gapH8,
            _Notice(
              text: l10n.payment_legacy_metadata,
              color: context.colors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    FeeDetailState state,
    FeeDetailViewModel vm,
    PersonalFee fee,
  ) {
    final l10n = context.l10n;
    final colors = context.colors;
    final hasBankAction =
        fee.canRequestBankTransfer && fee.paymentInstructions == null;
    final buttons = <Widget>[];
    if (hasBankAction) {
      buttons.add(
        FilledButton.icon(
          onPressed: state.isOperating || !fee.hasValidQrAmount
              ? null
              : () => _confirm(
                  context,
                  l10n.payment_confirm_transfer,
                  vm.prepareBankTransfer,
                ),
          icon: const Icon(Icons.account_balance_rounded),
          label: Text(l10n.payment_transfer),
        ),
      );
    }
    if (fee.canRequestCash) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: state.isOperating
              ? null
              : () => _confirm(
                  context,
                  l10n.payment_confirm_cash,
                  vm.requestCash,
                ),
          icon: const Icon(Icons.payments_outlined),
          label: Text(l10n.payment_cash),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasBankAction && !fee.hasValidQrAmount)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _Notice(
              text: l10n.payment_amount_invalid,
              color: colors.error,
            ),
          ),
        if (state.isOperating) ...[
          const LinearProgressIndicator(),
          AppSpacing.gapH8,
        ],
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _Notice(
              text: state.error!.getDisplayMessage(l10n),
              color: colors.error,
            ),
          ),
        ...buttons.map(
          (button) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(width: double.infinity, child: button),
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context,
    String message,
    Future<void> Function() action,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
    if (accepted == true) await action();
  }
}

class _Panel extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Panel({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
            ),
            AppSpacing.gapH12,
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.colored(
                context.colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.bold.colored(
                context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final Color color;
  const _Notice({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: AppRadius.borderSm,
    ),
    child: Text(text, style: AppTypography.bodySmall.colored(color)),
  );
}

class _FeeStatusChip extends StatelessWidget {
  final String status;
  const _FeeStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final colors = context.colors;
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

String _money(num? amount, String currency) => amount == null
    ? '—'
    : '${NumberFormat('#,##0.##', 'vi_VN').format(amount)} ${currency.isEmpty ? 'VND' : currency}';

String _methodLabel(String method, dynamic l10n) =>
    switch (method.toUpperCase()) {
      'BANK_TRANSFER' => l10n.payment_bank_transfer_method,
      'CASH' => l10n.payment_cash_method,
      _ => l10n.payment_unknown_status,
    };

String _publicationLabel(String publicationState, dynamic l10n) =>
    switch (publicationState.toUpperCase()) {
      'PUBLISHED' => l10n.payment_published,
      'LEGACY' => l10n.payment_legacy,
      _ => l10n.payment_unknown_status,
    };
