import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/consts/permissions.dart';
import '../../../../../app/provider.dart';
import '../../../../../app/provider/localization_provider.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../domain/entities/ledger/ledger.dart';
import '../../../../../domain/entities/session/session.dart';
import '../club_ledger_vm.dart';
import 'ledger_ui.dart';

Future<void> showLedgerContributions(
  BuildContext context,
  LedgerContext scope,
) => _showSheet(context, _LedgerContributions(scope: scope));

Future<void> showLedgerExpense(BuildContext context, LedgerContext scope) =>
    _showSheet(context, _LedgerExpense(scope: scope));

Future<void> _showSheet(BuildContext context, Widget child) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: FractionallySizedBox(heightFactor: .88, child: child),
        ),
      ),
    );

bool _hasScope(WidgetRef ref, LedgerContext scope) {
  final active = ref.watch(activeClubContextProvider);
  final token = ref.watch(authTokenProvider);
  final actor = token?.userId ?? ref.watch(currentUserProfileProvider)?.id;
  return token != null &&
      actor == scope.userId &&
      active?.clubId == scope.clubId &&
      active!.hasPermission(ClubPermissions.ledgerView) &&
      active.hasPermission(ClubPermissions.ledgerManage);
}

class _LedgerContributions extends ConsumerStatefulWidget {
  final LedgerContext scope;
  const _LedgerContributions({required this.scope});

  @override
  ConsumerState<_LedgerContributions> createState() =>
      _LedgerContributionsState();
}

class _LedgerContributionsState extends ConsumerState<_LedgerContributions> {
  final _search = TextEditingController();

  ClubLedgerViewModel get _vm =>
      ref.read(clubLedgerViewModelProvider(widget.scope).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.searchCandidates('');
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _action(
    LedgerCandidate candidate, {
    required bool collect,
  }) async {
    final l10n = context.l10n;
    if (collect) {
      final amount = candidate.amount;
      if (amount == null) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.ledger_collect),
          content: Text(
            l10n.ledger_confirm_collection(
              ledgerAmount(context, amount),
              candidate.name ?? l10n.ledger_member,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.com_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.com_confirm),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
    }
    final failure = collect
        ? await _vm.collect(candidate)
        : await _vm.issue(candidate);
    if (!mounted) return;
    showLedgerFeedback(
      context,
      failure == null
          ? (collect ? l10n.ledger_saved : l10n.ledger_issued)
          : ledgerError(context, failure),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasScope(ref, widget.scope)) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    final state = ref.watch(clubLedgerViewModelProvider(widget.scope));
    if (state.accessRevoked || state.overview?.canManage == false) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    final l10n = context.l10n;
    final canWrite =
        state.overview?.canWrite == true &&
        !state.writing &&
        !state.canRetryWrite;
    return ListView(
      padding: AppSpacing.allBase,
      children: [
        Text(l10n.ledger_contributions, style: AppTypography.titleLarge.bold),
        AppSpacing.gapH4,
        Text(ledgerMonth(context, ledgerVietnameseMonth(DateTime.now()))),
        AppSpacing.gapH12,
        TextField(
          controller: _search,
          maxLength: 100,
          textInputAction: TextInputAction.search,
          onSubmitted: _vm.searchCandidates,
          decoration: InputDecoration(
            labelText: l10n.com_search,
            suffixIcon: IconButton(
              tooltip: l10n.com_search,
              onPressed: () => _vm.searchCandidates(_search.text),
              icon: const Icon(Icons.search),
            ),
          ),
        ),
        if (state.canRetryWrite)
          LedgerNotice(
            message: l10n.ledger_retry_pending,
            busy: state.writing,
            action: state.overview?.canWrite == true
                ? () async {
                    final error = await _vm.retryWrite();
                    if (context.mounted) {
                      showLedgerFeedback(
                        context,
                        error == null
                            ? l10n.ledger_saved
                            : ledgerError(context, error),
                      );
                    }
                  }
                : null,
          ),
        if (state.writing) const LinearProgressIndicator(),
        LedgerRows<LedgerCandidate>(
          data: state.candidates,
          reload: ({bool append = false}) => append
              ? _vm.loadMoreCandidates()
              : _vm.searchCandidates(_search.text),
          row: (item) {
            final status = switch (item.status) {
              LedgerContributionStatus.notIssued => l10n.ledger_not_issued,
              LedgerContributionStatus.unpaid => l10n.ledger_unpaid,
              LedgerContributionStatus.paid => l10n.ledger_paid,
              LedgerContributionStatus.unknown => l10n.ledger_unknown_status,
            };
            final issue =
                canWrite &&
                item.canIssue &&
                item.status == LedgerContributionStatus.notIssued;
            final collect =
                canWrite &&
                item.canCollect &&
                item.status == LedgerContributionStatus.unpaid;
            return Card(
              margin: AppSpacing.verticalXs,
              child: Padding(
                padding: AppSpacing.allMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? l10n.ledger_member,
                      style: AppTypography.titleMedium.bold,
                    ),
                    Text(status),
                    if (item.amount != null)
                      Text(
                        ledgerAmount(context, item.amount!),
                        style: AppTypography.bodyLarge.bold,
                      ),
                    if (item.expiry != null)
                      Text(
                        l10n.ledger_expiry(ledgerDate(context, item.expiry!)),
                      ),
                    if (item.reason != null) Text(item.reason!),
                    if (issue || collect)
                      FilledButton.tonal(
                        onPressed: () => _action(item, collect: collect),
                        child: Text(
                          collect ? l10n.ledger_collect : l10n.ledger_issue,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LedgerExpense extends ConsumerStatefulWidget {
  final LedgerContext scope;
  const _LedgerExpense({required this.scope});

  @override
  ConsumerState<_LedgerExpense> createState() => _LedgerExpenseState();
}

class _LedgerExpenseState extends ConsumerState<_LedgerExpense> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  LedgerCategory _category = LedgerCategory.courtRent;
  LedgerInvoice? _invoice;
  Session? _session;
  bool _picking = false;
  String? _error;

  ClubLedgerViewModel get _vm =>
      ref.read(clubLedgerViewModelProvider(widget.scope).notifier);
  LedgerMoney? get _enteredAmount =>
      LedgerMoney.tryParse(_amount.text.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickInvoice() async {
    setState(() => _picking = true);
    final l10n = context.l10n;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withReadStream: true,
      );
      if (result == null || !mounted) return;
      final file = result.files.single;
      const limit = 5 * 1024 * 1024;
      if (file.size > limit) {
        setState(() => _error = l10n.ledger_invoice_limit);
        return;
      }
      final mime = switch (file.extension?.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'pdf' => 'application/pdf',
        _ => null,
      };
      final stream = file.readStream;
      if (mime == null || stream == null) {
        setState(() => _error = l10n.ledger_invoice_type);
        return;
      }
      final bytes = BytesBuilder();
      await for (final chunk in stream) {
        if (!mounted) return;
        if (bytes.length + chunk.length > limit) {
          setState(() => _error = l10n.ledger_invoice_limit);
          return;
        }
        bytes.add(chunk);
      }
      if (!mounted) return;
      setState(() {
        _invoice = (name: file.name, mimeType: mime, bytes: bytes.takeBytes());
        _error = null;
      });
    } catch (_) {
      if (mounted) setState(() => _error = l10n.ledger_file_failed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pickSession() async {
    final l10n = context.l10n;
    final future = ref
        .read(getClubSessionsUseCaseProvider)
        .execute(widget.scope.clubId);
    final selected = await showDialog<Session>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ledger_pick_session),
        content: SizedBox(
          width: AppSpacing.x5l * 5,
          child: FutureBuilder<List<Session>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(l10n.ledger_load_failed);
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final sessions = snapshot.data!;
              if (sessions.isEmpty) return Text(l10n.ledger_empty);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: sessions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(sessions[index].title),
                  onTap: () => Navigator.pop(context, sessions[index]),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.com_cancel),
          ),
        ],
      ),
    );
    if (selected != null && mounted) setState(() => _session = selected);
  }

  Future<void> _submit({bool retry = false}) async {
    if (!retry && !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final error = retry
        ? await _vm.retryWrite()
        : await _vm.expense(
            amount: _enteredAmount!,
            category: _category,
            description: _description.text.trim(),
            invoice: _invoice,
            sessionId: _session?.id,
          );
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = ledgerError(context, error));
      return;
    }
    showLedgerFeedback(context, context.l10n.ledger_saved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasScope(ref, widget.scope)) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    final state = ref.watch(clubLedgerViewModelProvider(widget.scope));
    if (state.accessRevoked || state.overview?.canManage == false) {
      return LedgerNotice(message: context.l10n.auth_forbidden);
    }
    final l10n = context.l10n;
    final locked = state.writing || state.canRetryWrite || _picking;
    final canSelectSession = ref.hasClubPermission(ClubPermissions.sessionView);
    final optionalButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, AppSpacing.x4l),
    );
    return Form(
      key: _form,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: AppSpacing.allLg,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text(
                  l10n.ledger_create_expense,
                  style: AppTypography.titleLarge.bold,
                ),
                AppSpacing.gapH24,
                TextFormField(
                  enabled: !locked,
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.ledger_amount,
                    suffixText: '₫',
                  ),
                  validator: (_) => _enteredAmount?.isValidExpense == true
                      ? null
                      : l10n.ledger_invalid_amount,
                ),
                AppSpacing.gapH20,
                DropdownButtonFormField<LedgerCategory>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.ledger_category),
                  items: [
                    for (final category in [
                      LedgerCategory.courtRent,
                      LedgerCategory.shuttleExpense,
                      LedgerCategory.other,
                    ])
                      DropdownMenuItem(
                        value: category,
                        child: Text(ledgerCategoryLabel(context, category)),
                      ),
                  ],
                  onChanged: locked
                      ? null
                      : (value) => setState(() => _category = value!),
                ),
                AppSpacing.gapH20,
                TextFormField(
                  enabled: !locked,
                  controller: _description,
                  maxLength: 1000,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.ledger_expense_reason,
                  ),
                  validator: (value) => value?.trim().isNotEmpty == true
                      ? null
                      : l10n.ledger_invalid,
                ),
                AppSpacing.gapH20,
                if (canSelectSession) ...[
                  OutlinedButton.icon(
                    style: optionalButtonStyle,
                    onPressed: locked ? null : _pickSession,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      _session?.title ?? l10n.ledger_pick_session,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_session != null)
                    TextButton(
                      onPressed: locked
                          ? null
                          : () => setState(() => _session = null),
                      child: Text(l10n.ledger_remove_session),
                    ),
                  AppSpacing.gapH12,
                ],
                OutlinedButton.icon(
                  style: optionalButtonStyle,
                  onPressed: locked ? null : _pickInvoice,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _invoice?.name ?? l10n.ledger_attach_invoice,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_invoice != null)
                  TextButton(
                    onPressed: locked
                        ? null
                        : () => setState(() => _invoice = null),
                    child: Text(l10n.ledger_remove_invoice),
                  ),
                if (_error != null) ...[
                  AppSpacing.gapH12,
                  Text(_error!, style: TextStyle(color: context.colors.error)),
                ],
                if (state.canRetryWrite) ...[
                  AppSpacing.gapH12,
                  Text(l10n.ledger_retry_pending),
                ],
              ],
            ),
          ),
          if (state.writing)
            const LinearProgressIndicator()
          else
            const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.base,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSpacing.x4l),
                ),
                onPressed:
                    state.writing ||
                        _picking ||
                        state.overview?.canWrite != true
                    ? null
                    : () => _submit(retry: state.canRetryWrite),
                child: Text(
                  state.canRetryWrite ? l10n.com_retry : l10n.com_save,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
