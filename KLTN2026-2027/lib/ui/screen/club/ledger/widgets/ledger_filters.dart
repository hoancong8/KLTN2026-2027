import 'package:flutter/material.dart';
import '../../../../../app/provider/localization_provider.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../domain/entities/ledger/ledger.dart';
import 'ledger_ui.dart';

Future<LedgerFilter?> showLedgerFilters(
  BuildContext context,
  LedgerFilter initial, {
  required bool debts,
}) => showDialog<LedgerFilter>(
  context: context,
  builder: (context) => _LedgerFilters(initial: initial, debts: debts),
);

class _LedgerFilters extends StatefulWidget {
  final LedgerFilter initial;
  final bool debts;
  const _LedgerFilters({required this.initial, required this.debts});

  @override
  State<_LedgerFilters> createState() => _LedgerFiltersState();
}

class _LedgerFiltersState extends State<_LedgerFilters> {
  late LedgerDates _dates = widget.initial.dates;
  late LedgerDirection? _direction = widget.initial.direction;
  late LedgerDebtType? _debtType = widget.initial.debtType;
  late LedgerCategory? _category = widget.initial.category;
  late String? _month = widget.initial.month;
  bool _rangeInvalid = false;

  DateTime _calendarDay(DateTime value) {
    final vietnam = value.toUtc().add(const Duration(hours: 7));
    return DateTime(vietnam.year, vietnam.month, vietnam.day);
  }

  DateTime _boundary(DateTime day, {bool nextDay = false}) =>
      DateTime.utc(day.year, day.month, day.day + (nextDay ? 1 : 0), -7);

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final start = _dates.from;
    final end = _dates.to;
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: start != null && end != null
          ? DateTimeRange(
              start: _calendarDay(start),
              end: _calendarDay(end.subtract(const Duration(days: 1))),
            )
          : null,
    );
    if (selected == null || !mounted) return;
    setState(() {
      final from = _boundary(selected.start);
      final to = _boundary(selected.end, nextDay: true);
      _rangeInvalid = to.difference(from).inDays > 366;
      if (!_rangeInvalid) _dates = (from: from, to: to);
    });
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      helpText: context.l10n.ledger_month_picker_hint,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDate: DateTime.tryParse(_month ?? ledgerVietnameseMonth(now)),
    );
    if (selected == null || !mounted) return;
    setState(
      () => _month =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-01',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = _dates.from;
    final end = _dates.to;
    return AlertDialog(
      title: Text(l10n.ledger_filters),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: _pickRange,
            child: Text(
              start != null && end != null
                  ? '${ledgerDate(context, _calendarDay(start))} – ${ledgerDate(context, _calendarDay(end.subtract(const Duration(days: 1))))}'
                  : l10n.ledger_date_range,
            ),
          ),
          if (_rangeInvalid) Text(l10n.ledger_date_limit),
          AppSpacing.gapH8,
          if (widget.debts)
            DropdownButtonFormField<LedgerDebtType>(
              initialValue: _debtType,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.ledger_debts),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.com_all)),
                DropdownMenuItem(
                  value: LedgerDebtType.sessionFee,
                  child: Text(l10n.ledger_session_fee),
                ),
                DropdownMenuItem(
                  value: LedgerDebtType.monthlyFund,
                  child: Text(l10n.ledger_monthly_fee),
                ),
              ],
              onChanged: (value) => setState(() {
                _debtType = value;
                if (value == LedgerDebtType.sessionFee) _month = null;
              }),
            )
          else ...[
            DropdownButtonFormField<LedgerDirection>(
              initialValue: _direction,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.ledger_history),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.com_all)),
                DropdownMenuItem(
                  value: LedgerDirection.inflow,
                  child: Text(l10n.ledger_in),
                ),
                DropdownMenuItem(
                  value: LedgerDirection.outflow,
                  child: Text(l10n.ledger_out),
                ),
              ],
              onChanged: (value) => setState(() => _direction = value),
            ),
            AppSpacing.gapH8,
            DropdownButtonFormField<LedgerCategory>(
              initialValue: _category,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.ledger_category),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.com_all)),
                for (final category in LedgerCategory.values.where(
                  (item) => item != LedgerCategory.unknown,
                ))
                  DropdownMenuItem(
                    value: category,
                    child: Text(ledgerCategoryLabel(context, category)),
                  ),
              ],
              onChanged: (value) => setState(() => _category = value),
            ),
          ],
          if (!widget.debts || _debtType != LedgerDebtType.sessionFee) ...[
            AppSpacing.gapH8,
            OutlinedButton(
              onPressed: _pickMonth,
              child: Text(
                _month == null
                    ? l10n.ledger_select_month
                    : ledgerMonth(context, _month!),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.com_cancel),
        ),
        FilledButton(
          onPressed: _rangeInvalid
              ? null
              : () => Navigator.of(context).pop(
                  LedgerFilter(
                    dates: _dates,
                    onlyMine: widget.initial.onlyMine,
                    direction: _direction,
                    debtType: _debtType,
                    category: _category,
                    month: _month,
                  ),
                ),
          child: Text(l10n.com_confirm),
        ),
      ],
    );
  }
}
