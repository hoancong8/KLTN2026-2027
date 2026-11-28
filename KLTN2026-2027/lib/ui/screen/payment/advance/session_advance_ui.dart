import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../app/provider/localization_provider.dart';
import '../../../../app/provider/session_advance_provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/payment/session_advance.dart';
import '../../../../domain/entities/session/session_settlement.dart';
import '../../../../domain/exceptions/app_exception.dart';

String advanceMoney(BuildContext context, num value) =>
    '${NumberFormat('#,##0.##', Localizations.localeOf(context).toLanguageTag()).format(value)} đ';

String advanceStatus(BuildContext context, String status) {
  final l10n = context.l10n;
  return switch (status) {
    'AVAILABLE' => l10n.advance_pay,
    'OPEN' => l10n.advance_open,
    'REVIEW' => l10n.advance_review,
    'RECEIVED' => l10n.advance_received,
    'APPLIED' => l10n.advance_applied,
    'REFUND_PENDING' => l10n.advance_pending,
    'REFUNDED' => l10n.advance_refunded,
    _ => l10n.advance_closed,
  };
}

Future<bool> showAdvanceSettlementPreview(
  BuildContext context,
  List<SettlementAdvanceLine> rows,
) async {
  final l10n = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.advance_finance),
          content: SizedBox(
            width: 560,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return ListTile(
                  title: Text(row.name),
                  subtitle: Text(
                    [
                      '${l10n.advance_gross} · ${advanceMoney(context, row.gross)}',
                      '${l10n.advance_applied} · ${advanceMoney(context, row.applied)}',
                      '${l10n.advance_due} · ${advanceMoney(context, row.due)}',
                      if (row.refund > 0)
                        '${l10n.advance_pending} · ${advanceMoney(context, row.refund)}',
                      if (row.pending) l10n.advance_review,
                    ].join('\n'),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.com_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.settlement_publish_summary),
            ),
          ],
        ),
      ) ??
      false;
}

class SessionAdvanceCard extends ConsumerWidget {
  const SessionAdvanceCard({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionAdvanceQuoteProvider(sessionId));
    final advance = state.value;
    if (advance == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.advance_title, style: AppTypography.titleSmall),
            if (advance.canPrepare) ...[
              Text(context.l10n.advance_optional),
              AppSpacing.gapH8,
            ],
            FilledButton.tonalIcon(
              onPressed: () async {
                await showAdvanceDetail(context, sessionId);
                if (context.mounted) {
                  ref.invalidate(sessionAdvanceQuoteProvider(sessionId));
                }
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: Text(
                '${advanceStatus(context, advance.status)} · ${advanceMoney(context, advance.amount)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAdvanceDetail(BuildContext context, String sessionId) =>
    showDialog<void>(
      context: context,
      builder: (_) => _AdvanceDetail(sessionId: sessionId),
    );

Future<void> showAdvanceList(BuildContext context, {String? groupId}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _AdvanceList(groupId: groupId),
    );

class _AdvanceList extends ConsumerWidget {
  const _AdvanceList({this.groupId});
  final String? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final club = groupId;
    final provider = club == null
        ? mySessionAdvancesProvider
        : clubSessionAdvancesProvider(club);
    final result = ref.watch(provider);
    return AlertDialog(
      title: Text(
        club == null
            ? context.l10n.advance_my_advances
            : context.l10n.advance_finance,
      ),
      content: SizedBox(
        width: 520,
        child: result.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => TextButton(
            onPressed: () => ref.invalidate(provider),
            child: Text(context.l10n.com_retry),
          ),
          data: (rows) => rows.isEmpty
              ? Text(context.l10n.advance_empty)
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final amount = row.refundDue > 0
                        ? row.refundDue
                        : row.received > 0
                        ? row.received
                        : row.amount;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(row.title),
                      subtitle: Text(
                        [
                          row.payerName,
                          advanceStatus(context, row.status),
                        ].whereType<String>().join(' · '),
                      ),
                      trailing: Text(advanceMoney(context, amount)),
                      onTap: () async {
                        if (club == null) {
                          await showAdvanceDetail(context, row.sessionId);
                        } else {
                          await showDialog<void>(
                            context: context,
                            builder: (_) =>
                                _ClubAdvanceDetail(group: club, advance: row),
                          );
                        }
                        if (context.mounted) ref.invalidate(provider);
                      },
                    );
                  },
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.com_back),
        ),
      ],
    );
  }
}

class _AdvanceDetail extends ConsumerStatefulWidget {
  const _AdvanceDetail({required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<_AdvanceDetail> createState() => _AdvanceDetailState();
}

class _AdvanceDetailState extends ConsumerState<_AdvanceDetail> {
  bool busy = false;
  String? error;

  Future<void> run(Future<SessionAdvance> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
      if (!mounted) return;
      ref.invalidate(sessionAdvanceQuoteProvider(widget.sessionId));
      ref.invalidate(mySessionAdvancesProvider);
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is AppException ? e.message : context.l10n.com_retry,
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = sessionAdvanceQuoteProvider(widget.sessionId);
    final repo = ref.read(sessionAdvanceRepositoryProvider);
    final row = ref.watch(provider);
    return AlertDialog(
      title: Text(l10n.advance_title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: row.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => TextButton(
              onPressed: () => ref.invalidate(provider),
              child: Text(l10n.com_retry),
            ),
            data: (advance) {
              if (advance == null) return Text(l10n.advance_empty);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(advance.title, style: AppTypography.titleSmall),
                  Text(advanceStatus(context, advance.status)),
                  Text(
                    advanceMoney(
                      context,
                      advance.refundDue > 0
                          ? advance.refundDue
                          : advance.amount,
                    ),
                    style: AppTypography.titleMedium,
                  ),
                  if (advance.reason case final reason?) Text(reason),
                  if (advance.qrPayload case final payload?) ...[
                    Center(
                      child: QrImageView(
                        data: payload,
                        size: 192,
                        backgroundColor: AppColors.white,
                      ),
                    ),
                    if (advance.code case final code?)
                      TextButton.icon(
                        onPressed: () =>
                            Clipboard.setData(ClipboardData(text: code)),
                        icon: const Icon(Icons.copy_outlined),
                        label: Text(code),
                      ),
                    if (advance.status == 'OPEN')
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => run(() => repo.report(widget.sessionId)),
                        child: Text(l10n.advance_report),
                      ),
                  ] else if (advance.canPrepare && advance.id == null)
                    FilledButton(
                      onPressed: busy
                          ? null
                          : () => run(() => repo.prepare(widget.sessionId)),
                      child: Text(l10n.advance_pay),
                    ),
                  if (advance.status == 'REFUND_PENDING' &&
                      !advance.refundClaimed)
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final data = await _readFields(
                                context,
                                l10n.advance_save_account,
                                [
                                  l10n.advance_bank,
                                  l10n.advance_account,
                                  l10n.advance_holder,
                                ],
                                [advance.bank, advance.account, advance.holder],
                              );
                              if (mounted && data != null) {
                                await run(
                                  () => repo.saveAccount(
                                    widget.sessionId,
                                    data[0],
                                    data[1],
                                    data[2],
                                  ),
                                );
                              }
                            },
                      child: Text(l10n.advance_save_account),
                    ),
                  if (advance.reference case final reference?)
                    SelectableText(reference),
                  if (error case final message?)
                    Text(
                      message,
                      style: TextStyle(color: context.colors.error),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => ref.invalidate(provider),
          child: Text(l10n.com_refresh),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.com_back),
        ),
      ],
    );
  }
}

class _ClubAdvanceDetail extends ConsumerStatefulWidget {
  const _ClubAdvanceDetail({required this.group, required this.advance});
  final String group;
  final SessionAdvance advance;

  @override
  ConsumerState<_ClubAdvanceDetail> createState() => _ClubAdvanceDetailState();
}

class _ClubAdvanceDetailState extends ConsumerState<_ClubAdvanceDetail> {
  late SessionAdvance advance = widget.advance;
  String? error;
  bool busy = false;

  Future<void> submit(Future<SessionAdvance> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final next = await action();
      if (!mounted) return;
      setState(() => advance = next);
      ref.invalidate(clubSessionAdvancesProvider(widget.group));
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is AppException ? e.message : context.l10n.com_retry,
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = ref.read(sessionAdvanceRepositoryProvider);
    final id = advance.id!;
    return AlertDialog(
      title: Text(advance.title),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                advanceStatus(context, advance.status),
                style: AppTypography.titleSmall,
              ),
              if (advance.payerName case final name?) Text(name),
              Text(
                advanceMoney(
                  context,
                  advance.refundDue > 0 ? advance.refundDue : advance.amount,
                ),
              ),
              if (advance.reason case final reason?) Text(reason),
              if (advance.code case final code?) SelectableText(code),
              if (advance.status == 'REVIEW' &&
                  advance.reviewAmount != null) ...[
                Text(
                  '${l10n.advance_paid_amount} · ${advanceMoney(context, advance.reviewAmount!)}',
                ),
                if (advance.reviewReference case final reference?)
                  SelectableText(reference),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () => submit(
                          () => repo.review(
                            widget.group,
                            id,
                            advance.reviewTransactionId,
                          ),
                        ),
                  child: Text(l10n.advance_approve),
                ),
              ],
              if (advance.status == 'REVIEW' &&
                  advance.reviewTransactionId == null)
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => submit(() => repo.review(widget.group, id, null)),
                  child: Text(l10n.advance_dismiss),
                ),
              if (advance.status == 'REFUND_PENDING') ...[
                if (advance.account == null) Text(l10n.advance_wait_account),
                if (advance.account != null && !advance.refundClaimed)
                  FilledButton.tonal(
                    onPressed: busy
                        ? null
                        : () => submit(() => repo.claim(widget.group, id)),
                    child: Text(l10n.advance_claim),
                  ),
                if (advance.refundClaimed && !advance.canHandle)
                  Text(l10n.advance_assigned),
                if (advance.canHandle) ...[
                  SelectableText(
                    [
                      advance.bank,
                      advance.account,
                      advance.holder,
                    ].whereType<String>().join(' · '),
                  ),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final data = await _readFields(
                              context,
                              l10n.advance_finish,
                              [l10n.advance_reference, l10n.advance_evidence],
                            );
                            if (mounted && data != null) {
                              await submit(
                                () => repo.refund(
                                  widget.group,
                                  id,
                                  advance.refundDue,
                                  data[0],
                                  data[1],
                                ),
                              );
                            }
                          },
                    child: Text(l10n.advance_finish),
                  ),
                ],
              ],
              if (advance.reference case final reference?)
                SelectableText(reference),
              if (error case final message?)
                Text(message, style: TextStyle(color: context.colors.error)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.com_back),
        ),
      ],
    );
  }
}

Future<List<String>?> _readFields(
  BuildContext context,
  String title,
  List<String> names, [
  List<String?>? initial,
]) {
  final values = List<String>.generate(
    names.length,
    (index) => initial?[index] ?? '',
  );
  final form = GlobalKey<FormState>();
  return showDialog<List<String>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < names.length; i++)
                  TextFormField(
                    initialValue: values[i],
                    decoration: InputDecoration(labelText: names[i]),
                    onChanged: (value) => values[i] = value.trim(),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? context.l10n.advance_select_required
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(context.l10n.com_cancel),
        ),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              Navigator.pop(dialogContext, values);
            }
          },
          child: Text(context.l10n.com_confirm),
        ),
      ],
    ),
  );
}
