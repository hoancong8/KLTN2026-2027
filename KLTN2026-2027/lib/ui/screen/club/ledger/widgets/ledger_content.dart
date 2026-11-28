import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../payment/advance/session_advance_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/consts/permissions.dart';
import '../../../../../app/provider.dart';
import '../../../../../app/provider/localization_provider.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../domain/entities/ledger/ledger.dart';
import '../../../../../domain/exceptions/app_exception.dart';
import '../../../../../widget/responsive_layout.dart';
import '../club_ledger_vm.dart';
import 'ledger_filters.dart';
import 'ledger_forms.dart';
import 'ledger_ui.dart';

class LedgerContent extends ConsumerStatefulWidget {
  final LedgerContext scope;
  const LedgerContent({super.key, required this.scope});

  @override
  ConsumerState<LedgerContent> createState() => _LedgerContentState();
}

class _LedgerContentState extends ConsumerState<LedgerContent> {
  late final AppLifecycleListener _lifecycle;
  bool _showDebts = false;
  String? _loadingInvoice;
  String? _processingDebtId;

  ClubLedgerViewModel get _vm =>
      ref.read(clubLedgerViewModelProvider(widget.scope).notifier);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => _vm.refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _invoice(String id) async {
    if (_loadingInvoice != null) return;
    setState(() => _loadingInvoice = id);
    try {
      final invoice = await _vm.invoice(id);
      if (invoice == null || !mounted) return;
      await FilePicker.saveFile(fileName: invoice.name, bytes: invoice.bytes);
    } on AppException catch (error) {
      if (mounted) showLedgerFeedback(context, ledgerError(context, error));
    } catch (_) {
      if (mounted) showLedgerFeedback(context, context.l10n.ledger_file_failed);
    } finally {
      if (mounted) setState(() => _loadingInvoice = null);
    }
  }

  Future<void> _retryWrite() async {
    final error = await _vm.retryWrite();
    if (!mounted) return;
    showLedgerFeedback(
      context,
      error == null ? context.l10n.ledger_saved : ledgerError(context, error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubLedgerViewModelProvider(widget.scope));
    final manage = ref.hasClubPermission(ClubPermissions.ledgerManage);
    if (state.accessRevoked) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    final overview = state.overview;
    if (overview == null) {
      return state.loading
          ? const Center(child: CircularProgressIndicator())
          : LedgerNotice(
              message: state.error == null
                  ? context.l10n.ledger_load_failed
                  : ledgerError(context, state.error!),
              action: _vm.refresh,
            );
    }
    final summary = _summary(overview, state, manage);
    final lists = _lists(state);
    Widget scroll(Widget content) => RefreshIndicator(
      onRefresh: _vm.refresh,
      child: ListView(
        key: PageStorageKey(widget.scope),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.base,
          AppSpacing.base,
          120,
        ),
        children: [content],
      ),
    );
    return ResponsiveLayout(
      mobile: scroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [summary, AppSpacing.gapH16, lists],
        ),
      ),
      tablet: scroll(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: summary),
            AppSpacing.gapW16,
            Expanded(flex: 7, child: lists),
          ],
        ),
      ),
    );
  }

  Widget _summary(LedgerOverview overview, ClubLedgerState state, bool manage) {
    final l10n = context.l10n;
    final colors = context.colors;
    final canManage = manage && overview.canManage;
    final canWrite =
        overview.canWrite && !state.writing && !state.canRetryWrite;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (overview.heldAdvance.minorUnits > BigInt.zero)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text('${l10n.advance_reserved} · ${ledgerAmount(context, overview.heldAdvance)}'),
          ),
        if (canManage)
          OutlinedButton.icon(
            onPressed: () async {
              await showAdvanceList(context, groupId: widget.scope.clubId);
              if (mounted) await _vm.refresh();
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: Text(l10n.advance_finance),
          ),
        Card(
          margin: EdgeInsets.zero,
          color: colors.primaryContainer,
          child: Padding(
            padding: AppSpacing.allBase,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: colors.primary,
                    ),
                    AppSpacing.gapW8,
                    Expanded(
                      child: Text(
                        l10n.ledger_balance,
                        style: AppTypography.labelLarge.colored(
                          colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: state.loading ? null : _vm.refresh,
                      tooltip: l10n.com_refresh,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                Text(
                  ledgerAmount(context, overview.balance),
                  style: AppTypography.headlineMedium.bold.colored(
                    colors.textPrimary,
                  ),
                ),
                AppSpacing.gapH8,
                Text(
                  l10n.ledger_updated_at(
                    ledgerDate(context, overview.asOf, time: true),
                  ),
                  style: AppTypography.bodySmall.colored(colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (state.loading) const LinearProgressIndicator(),
        if (state.error != null)
          LedgerNotice(
            message: ledgerError(context, state.error!),
            action: _vm.refresh,
          ),
        AppSpacing.gapH12,
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: AppSpacing.allBase,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _metric(l10n.ledger_period_in, overview.inflow),
                _metric(l10n.ledger_period_out, overview.outflow),
                const Divider(),
                _metric(l10n.ledger_current_debt, overview.debt),
                _metric(l10n.ledger_session_fee, overview.sessionDebt),
                _metric(l10n.ledger_monthly_fee, overview.monthlyDebt),
              ],
            ),
          ),
        ),
        if (canManage) ...[
          AppSpacing.gapH12,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: state.writing
                    ? null
                    : () => showLedgerContributions(context, widget.scope),
                icon: const Icon(Icons.groups_outlined),
                label: Text(l10n.ledger_contributions),
              ),
              FilledButton.icon(
                onPressed: canWrite
                    ? () => showLedgerExpense(context, widget.scope)
                    : null,
                icon: const Icon(Icons.add),
                label: Text(l10n.ledger_create_expense),
              ),
            ],
          ),
          if (!overview.canWrite)
            LedgerNotice(message: l10n.ledger_writes_disabled),
          if (state.canRetryWrite)
            LedgerNotice(
              message: l10n.ledger_retry_pending,
              busy: state.writing,
              action: overview.canWrite ? _retryWrite : null,
            ),
        ],
      ],
    );
  }

  Widget _metric(String label, LedgerMoney money) => Padding(
    padding: AppSpacing.verticalXs,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        AppSpacing.gapW8,
        Flexible(
          child: Text(
            ledgerAmount(context, money),
            textAlign: TextAlign.end,
            style: AppTypography.bodyMedium.bold,
          ),
        ),
      ],
    ),
  );

  Widget _lists(ClubLedgerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filterBar(state.filter),
        AppSpacing.gapH8,
        if (_showDebts)
          LedgerRows<LedgerDebt>(
            data: state.debts,
            row: _debtRow,
            reload: _vm.loadDebts,
          )
        else
          LedgerRows<LedgerTransaction>(
            data: state.transactions,
            row: _transactionRow,
            reload: _vm.loadTransactions,
          ),
      ],
    );
  }

  Widget _filterBar(LedgerFilter filter) {
    final l10n = context.l10n;
    final hasFilters =
        filter.dates.from != null ||
        filter.dates.to != null ||
        filter.month != null ||
        filter.category != null ||
        filter.direction != null ||
        filter.debtType != null;

    final String currentSegment;
    if (filter.onlyMine) {
      currentSegment = 'mine';
    } else if (_showDebts) {
      currentSegment = 'debts';
    } else {
      currentSegment = 'history';
    }

    return Row(
      children: [
        Expanded(
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            expandedInsets: EdgeInsets.zero,
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
              textStyle: WidgetStatePropertyAll(AppTypography.labelMedium),
            ),
            segments: [
              ButtonSegment<String>(
                value: 'history',
                label: Text(
                  l10n.ledger_history_short,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                tooltip: l10n.ledger_history,
              ),
              ButtonSegment<String>(
                value: 'debts',
                label: Text(
                  l10n.ledger_debts_short,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                tooltip: l10n.ledger_debts,
              ),
              ButtonSegment<String>(
                value: 'mine',
                label: Text(
                  'Của tôi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                tooltip: l10n.ledger_only_mine,
              ),
            ],
            selected: {currentSegment},
            onSelectionChanged: (values) {
              final val = values.single;
              if (val == 'mine') {
                setState(() => _showDebts = false);
                if (!filter.onlyMine) {
                  _vm.setFilter(
                    LedgerFilter(
                      dates: filter.dates,
                      direction: filter.direction,
                      debtType: filter.debtType,
                      category: filter.category,
                      month: filter.month,
                      onlyMine: true,
                    ),
                  );
                }
              } else if (val == 'debts') {
                setState(() => _showDebts = true);
                if (filter.onlyMine) {
                  _vm.setFilter(
                    LedgerFilter(
                      dates: filter.dates,
                      direction: filter.direction,
                      debtType: filter.debtType,
                      category: filter.category,
                      month: filter.month,
                      onlyMine: false,
                    ),
                  );
                }
              } else {
                setState(() => _showDebts = false);
                if (filter.onlyMine) {
                  _vm.setFilter(
                    LedgerFilter(
                      dates: filter.dates,
                      direction: filter.direction,
                      debtType: filter.debtType,
                      category: filter.category,
                      month: filter.month,
                      onlyMine: false,
                    ),
                  );
                }
              }
            },
          ),
        ),
        AppSpacing.gapW8,
        IconButton(
          tooltip: l10n.ledger_filters,
          icon: Badge(
            isLabelVisible: hasFilters,
            child: const Icon(Icons.tune),
          ),
          onPressed: () async {
            final next = await showLedgerFilters(
              context,
              filter,
              debts: _showDebts,
            );
            if (next != null && mounted) await _vm.setFilter(next);
          },
        ),
        if (hasFilters)
          IconButton(
            tooltip: l10n.ledger_clear_filters,
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: () =>
                _vm.setFilter(LedgerFilter(onlyMine: filter.onlyMine)),
          ),
      ],
    );
  }

  Widget _transactionRow(LedgerTransaction item) {
    final inflow = item.direction == LedgerDirection.inflow;
    final tint = inflow ? context.colors.primary : context.colors.textPrimary;
    return Card(
      margin: AppSpacing.verticalXs,
      child: ListTile(
        leading: Icon(
          inflow ? Icons.south_west : Icons.north_east,
          color: tint,
        ),
        title: Text(
          item.description.isEmpty
              ? ledgerCategoryLabel(context, item.category)
              : item.description,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ledgerCategoryLabel(context, item.category)} · ${ledgerDate(context, item.createdAt, time: true)}',
            ),
            Text(
              '${inflow ? '+' : '−'}${ledgerAmount(context, item.amount)}',
              style: AppTypography.bodyMedium.bold.colored(tint),
            ),
          ],
        ),
        trailing: item.hasInvoice
            ? IconButton(
                tooltip: context.l10n.ledger_download_invoice,
                onPressed: _loadingInvoice == null
                    ? () => _invoice(item.id)
                    : null,
                icon: _loadingInvoice == item.id
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.download_outlined),
              )
            : null,
      ),
    );
  }

  Widget _debtRow(LedgerDebt item) {
    final l10n = context.l10n;
    final isProcessing = _processingDebtId == item.sourceId;

    Widget? trailing;
    if (item.type == LedgerDebtType.sessionFee && item.sessionId != null) {
      trailing = Wrap(
        spacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (item.userId != null)
            IconButton(
              tooltip: l10n.settlement_confirm_cash,
              icon: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              onPressed: isProcessing
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.settlement_confirm_cash_title),
                          content: Text(
                            l10n.settlement_confirm_cash_message(
                              ledgerAmount(context, item.amount),
                              item.name ?? l10n.ledger_member,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.com_cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.com_confirm),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !mounted) return;
                      setState(() => _processingDebtId = item.sourceId);
                      try {
                        final repo = ref.read(sessionOperationsRepositoryProvider);
                        await repo.markMemberPaid(
                          sessionId: item.sessionId!,
                          userId: item.userId!,
                        );
                        if (mounted) {
                          showLedgerFeedback(context, l10n.ledger_saved);
                          await _vm.loadDebts();
                          await _vm.refresh();
                        }
                      } catch (e) {
                        if (mounted) {
                          final msg = e is AppException ? (e.message ?? e.toString()) : e.toString();
                          showLedgerFeedback(context, msg);
                        }
                      } finally {
                        if (mounted) setState(() => _processingDebtId = null);
                      }
                    },
            ),
          IconButton(
            tooltip: l10n.ledger_view_settlement,
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => context.push('/session/${item.sessionId}/settlement'),
          ),
        ],
      );
    }

    return Card(
      margin: AppSpacing.verticalXs,
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(item.name ?? l10n.ledger_member),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.type == LedgerDebtType.sessionFee
                  ? l10n.ledger_session_fee
                  : l10n.ledger_monthly_fee,
            ),
            if (item.month != null) Text(ledgerMonth(context, item.month!)),
            Text(
              '${l10n.ledger_unpaid} · ${ledgerAmount(context, item.amount)}',
              style: AppTypography.bodyMedium.bold,
            ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
