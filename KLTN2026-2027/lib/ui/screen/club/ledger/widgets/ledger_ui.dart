import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/provider/localization_provider.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../domain/entities/ledger/ledger.dart';
import '../../../../../domain/exceptions/app_exception.dart';
import '../../../../../domain/exceptions/ledger_exception.dart';
import '../club_ledger_vm.dart';

String ledgerAmount(BuildContext context, LedgerMoney value) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final symbols = NumberFormat.decimalPattern(locale).symbols;
  final parts = value.decimal.split('.');
  final grouped = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => symbols.GROUP_SEP,
  );
  final fraction = parts.last == '00'
      ? ''
      : '${symbols.DECIMAL_SEP}${parts.last}';
  return '$grouped$fraction ₫';
}

String ledgerDate(BuildContext context, DateTime value, {bool time = false}) {
  final local = Localizations.localeOf(context).toLanguageTag();
  final format = DateFormat.yMMMd(local);
  return (time ? format.add_jm() : format).format(value.toLocal());
}

String ledgerMonth(BuildContext context, String month) {
  final date = DateTime.tryParse(month);
  if (date == null) return month;
  return DateFormat.yMMMM(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

String ledgerCategoryLabel(BuildContext context, LedgerCategory category) =>
    switch (category) {
      LedgerCategory.sessionFee => context.l10n.ledger_session_fee,
      LedgerCategory.courtRent => context.l10n.ledger_court_rent,
      LedgerCategory.shuttleExpense => context.l10n.ledger_shuttles,
      LedgerCategory.monthlyFund => context.l10n.ledger_monthly_fee,
      LedgerCategory.other ||
      LedgerCategory.sessionAdvance => context.l10n.advance_title,
      LedgerCategory.sessionAdvanceRefund => context.l10n.advance_refunded,
      LedgerCategory.unknown => context.l10n.ledger_other,
    };

String ledgerError(BuildContext context, AppException error) {
  final l10n = context.l10n;
  if (error is LedgerException) {
    return switch (error.code) {
      'Ledger.Disabled' => l10n.ledger_disabled,
      'Ledger.WritesDisabled' => l10n.ledger_writes_disabled,
      'Ledger.InsufficientBalance' => l10n.ledger_insufficient,
      'Ledger.GroupContextMismatch' => l10n.ledger_switch_context,
      'Ledger.ContributionAmountMismatch' ||
      'Ledger.MonthAlreadyCollected' ||
      'Ledger.IdempotencyConflict' => l10n.ledger_write_conflict,
      'Ledger.RequiresReconciliation' => l10n.ledger_reconciliation_required,
      'Ledger.Busy' || 'Ledger.LockUnavailable' => l10n.ledger_busy,
      _ => switch (error.status) {
        400 => error.message ?? l10n.ledger_invalid,
        401 || 403 => l10n.auth_forbidden,
        404 => l10n.ledger_missing,
        413 => l10n.ledger_invoice_limit,
        415 => l10n.ledger_invoice_type,
        _ => l10n.ledger_load_failed,
      },
    };
  }
  return l10n.ledger_load_failed;
}

void showLedgerFeedback(BuildContext context, String message) =>
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

class LedgerNotice extends StatelessWidget {
  final String message;
  final VoidCallback? action;
  final String? actionLabel;
  final bool busy;

  const LedgerNotice({
    super.key,
    required this.message,
    this.action,
    this.actionLabel,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: AppSpacing.allXl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) const LinearProgressIndicator(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.colored(
              context.colors.textSecondary,
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: busy ? null : action,
              child: Text(actionLabel ?? context.l10n.com_retry),
            ),
        ],
      ),
    ),
  );
}

class LedgerRows<T> extends StatelessWidget {
  final LedgerListState<T> data;
  final Widget Function(T item) row;
  final Future<void> Function({bool append}) reload;

  const LedgerRows({
    super.key,
    required this.data,
    required this.row,
    required this.reload,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final item in data.items) row(item),
      if (data.loading) const LinearProgressIndicator(),
      if (!data.loading && data.error != null)
        LedgerNotice(
          message: ledgerError(context, data.error!),
          action: () => reload(append: data.page > 0),
        )
      else if (!data.loading && data.items.isEmpty)
        LedgerNotice(message: context.l10n.ledger_empty)
      else if (!data.loading && data.hasMore)
        OutlinedButton(
          onPressed: () => reload(append: true),
          child: Text(context.l10n.ledger_load_more),
        ),
    ],
  );
}
