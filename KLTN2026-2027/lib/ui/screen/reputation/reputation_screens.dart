import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/consts/app_config.dart';
import '../../../app/provider.dart';
import '../../../app/provider/reputation_provider.dart';
import '../../../app/provider/localization_provider.dart';
import '../../../app/utils/exception_ext.dart';
import '../../../app/theme/theme.dart';
import '../../../domain/entities/reputation/reputation.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../widget/responsive_layout.dart';

part '../club/session_operations/session_reviews_screen.dart';

String _date(DateTime? value) => value == null ? '—' : DateFormat.yMMMd().add_jm().format(value.toLocal());
String _number(num? value) => value == null ? '—' : NumberFormat.decimalPattern().format(value);
String _score(num? value, int max) => value == null ? '—' : '${_number(value)}/$max';

String _error(BuildContext context, Object error) =>
    error is AppException ? error.getDisplayMessage(context.l10n) : context.l10n.reputation_retry;

class ReputationScreenLayout extends StatelessWidget {
  const ReputationScreenLayout({super.key, required this.title, required this.items, required this.refresh});

  final String title;
  final List<Widget> items;
  final Future<void> Function() refresh;

  Widget _body(BuildContext context, double width) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: RefreshIndicator(
        onRefresh: refresh,
        child: Theme(
          data: Theme.of(context).copyWith(
            listTileTheme: ListTileThemeData(
              titleTextStyle: AppTypography.bodyLarge.colored(context.colors.textPrimary),
              subtitleTextStyle: AppTypography.bodyLarge.colored(context.colors.textSecondary),
              minVerticalPadding: 12,
            ),
            expansionTileTheme: ExpansionTileThemeData(
              textColor: context.colors.textPrimary,
              collapsedTextColor: context.colors.textPrimary,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyMedium: AppTypography.bodyLarge.colored(context.colors.textPrimary),
              bodySmall: AppTypography.bodyLarge.colored(context.colors.textSecondary),
              titleMedium: AppTypography.titleMedium.colored(context.colors.textPrimary),
            ),
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: items,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ResponsiveLayout(mobile: _body(context, double.infinity), tablet: _body(context, 850)),
  );
}

Widget _failure(BuildContext context, Object error, VoidCallback retry) => ListTile(
  title: Text(_error(context, error)),
  trailing: TextButton(onPressed: retry, child: Text(context.l10n.reputation_retry)),
);

const _loading = LinearProgressIndicator();

class _Pagination extends StatelessWidget {
  const _Pagination(this.page, this.more, this.change);

  final int page;
  final bool more;
  final ValueChanged<int> change;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      IconButton(
        tooltip: context.l10n.reputation_previous,
        onPressed: page > 1 ? () => change(page - 1) : null,
        icon: const Icon(Icons.chevron_left),
      ),
      Text(_number(page)),
      IconButton(
        tooltip: context.l10n.reputation_next,
        onPressed: more ? () => change(page + 1) : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

class ReviewInvitationsScreen extends ConsumerStatefulWidget {
  const ReviewInvitationsScreen({super.key, this.sessionId});
  final String? sessionId;

  @override
  ConsumerState<ReviewInvitationsScreen> createState() => _ReviewInvitationsScreenState();
}

class _ReviewInvitationsScreenState extends ConsumerState<ReviewInvitationsScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = reputationInvitationsProvider((page: _page, sessionId: widget.sessionId));
    final data = ref.watch(provider);
    return ReputationScreenLayout(
      title: widget.sessionId == null ? l10n.reputation_invitations : l10n.reputation_title,
      refresh: () => ref.refresh(provider.future),
      items: [
        ListTile(
          leading: const Icon(Icons.timeline),
          title: Text(l10n.reputation_history),
          onTap: () => context.push('/reputation/history'),
        ),
        if (widget.sessionId != null)
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: Text(l10n.reputation_invitations),
            onTap: () => context.push(AppConfig.reviewsRoute()),
          ),
        ...data.when(
          skipLoadingOnRefresh: false,
          loading: () => [_loading],
          error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
          data: (page) => [
            if (page.items.isEmpty)
              ListTile(title: Text(widget.sessionId == null
                  ? l10n.reputation_no_invitation : l10n.reputation_unavailable)),
            for (final invitation in page.items)
              _InvitationTile(key: ValueKey(invitation.sessionId), invitation: invitation),
            if (widget.sessionId == null)
              _Pagination(page.page, page.hasMore, (index) => setState(() => _page = index)),
          ],
        ),
      ],
    );
  }
}

class PlayerReputationScreen extends ConsumerWidget {
  const PlayerReputationScreen({super.key, this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = userId ?? ref.watch(currentUserProfileProvider)?.id;
    final provider = id == null || id.isEmpty ? null : playerReputationProvider(id);
    return ReputationScreenLayout(
      title: userId == null ? l10n.reputation_title : l10n.reputation_player,
      refresh: () => provider == null ? Future<void>.value() : ref.refresh(provider.future),
      items: [
        if (provider == null) ListTile(title: Text(l10n.reputation_empty))
        else ...ref.watch(provider).when(
          skipLoadingOnRefresh: false,
          loading: () => [_loading],
          error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
          data: (player) => [
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text(_score(player.score, 100)),
              subtitle: player.riskLabel == null ? null : Text(player.riskLabel!),
            ),
            if (player.computedAt == null) ListTile(title: Text(l10n.reputation_no_result)),
            if (userId == null) ...[
              _metric(l10n.reputation_sample_count, _number(player.sampleCount)),
              _metric(l10n.reputation_updated, _date(player.computedAt)),
            ],
          ],
        ),
        if (userId == null) ...[
          ListTile(title: Text(l10n.reputation_invitations), trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppConfig.reviewsRoute())),
          ListTile(title: Text(l10n.reputation_history), trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/reputation/history')),
        ],
      ],
    );
  }
}

Widget _metric(String label, String value) => ListTile(
  title: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 16),
      Flexible(child: Text(value, textAlign: TextAlign.end)),
    ],
  ),
);

List<Widget> _evidence(BuildContext context, ReputationEvidence? evidence) {
  if (evidence == null) return const [];
  final l = context.l10n;
  final attendance = switch (evidence.attendance) {
    'CHECKED_IN' || '4' => l.reputation_checked_in,
    'NO_SHOW' || '5' => l.reputation_no_show,
    'WAITING' || '2' => l.reputation_waiting,
    'ABSENT' || '3' => l.reputation_absent,
    _ => evidence.attendance,
  };
  final payment = switch (evidence.payment) {
    'Bank' || '2' => l.reputation_bank,
    'Cash' || '3' => l.reputation_cash,
    'Exempt' || '1' => l.reputation_exempt,
    'Advance' || '4' => l.reputation_advance_source,
    _ => null,
  };
  return [
    if (attendance != null) _metric(l.reputation_attendance, attendance),
    if (payment != null) _metric(l.reputation_payment, payment),
    if (evidence.checkinAt != null) _metric(l.reputation_checkin, _date(evidence.checkinAt)),
    if (evidence.publishedAt != null) _metric(l.reputation_published, _date(evidence.publishedAt)),
    if (evidence.receivedAt != null) _metric(l.reputation_received, _date(evidence.receivedAt)),
    if (evidence.cancelledAt != null) _metric(l.reputation_cancelled, _date(evidence.cancelledAt)),
  ];
}

String _delta(double? value) => value != null && value > 0 ? '+${_number(value)}' : _number(value);

class ReputationHistoryScreen extends ConsumerStatefulWidget {
  const ReputationHistoryScreen({super.key});

  @override
  ConsumerState<ReputationHistoryScreen> createState() => _ReputationHistoryScreenState();
}

class _ReputationHistoryScreenState extends ConsumerState<ReputationHistoryScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = reputationEntriesProvider(_page);
    final profile = ref.watch(currentUserProfileProvider);
    final card = profile == null ? null : ref.watch(playerReputationProvider(profile.id));
    return ReputationScreenLayout(
      title: l.reputation_history,
      refresh: () async {
        if (profile != null) ref.invalidate(playerReputationProvider(profile.id));
        return ref.refresh(provider.future);
      },
      items: [
        if (card != null)
          ...card.when(
            loading: () => [_loading],
            error: (error, _) => [_failure(context, error, () => ref.invalidate(playerReputationProvider(profile!.id)))],
            data: (player) => [
              _metric(l.reputation_player, _score(player.score, 100)),
              if (player.computedAt == null) ListTile(title: Text(l.reputation_no_result)),
              if (player.riskLabel != null) ListTile(title: Text(player.riskLabel!)),
              _metric(l.reputation_sample_count, _number(player.sampleCount)),
              _metric(l.reputation_updated, _date(player.computedAt)),
            ],
          ),
        ...ref.watch(provider).when(
          skipLoadingOnRefresh: false,
          loading: () => [_loading],
          error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
          data: (rows) => [
            if (rows.items.isEmpty) ListTile(title: Text(l.reputation_empty)),
            for (final row in rows.items)
              Card(child: ExpansionTile(
                key: ValueKey(row.bookingId),
                title: Text(row.sessionTitle ?? l.reputation_session),
                subtitle: Text([row.groupName, _date(row.computedAt), row.policyVersion].nonNulls.join(' · ')),
                trailing: Text(_delta(row.rawDelta), style: AppTypography.bodyLarge.colored(context.colors.textPrimary)),
                children: _evidence(context, row.evidence),
              )),
            _Pagination(rows.page, rows.hasMore, (page) => setState(() => _page = page)),
          ],
        ),
      ],
    );
  }
}

class GroupQualityScreen extends ConsumerWidget {
  const GroupQualityScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final provider = groupQualityProvider(groupId);
    return ReputationScreenLayout(
      title: l.reputation_quality,
      refresh: () => ref.refresh(provider.future),
      items: ref.watch(provider).when(
        skipLoadingOnRefresh: false,
        loading: () => [_loading],
        error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
        data: (quality) => [
          ListTile(leading: const Icon(Icons.star_outline), title: Text(_score(quality.score, 5))),
          if (!quality.hasResult) ListTile(title: Text(l.reputation_no_result)),
          _metric(l.reputation_reviews_metric, quality.reviews == null ? l.reputation_insufficient : _score(quality.reviews, 5)),
          _metric(l.reputation_transparency, quality.transparency == null ? l.reputation_insufficient : _score(quality.transparency, 5)),
          _metric(l.reputation_density, quality.density == null ? l.reputation_insufficient : _score(quality.density, 5)),
          _metric(l.reputation_review_count, _number(quality.reviewCount)),
          _metric(l.reputation_session_count, _number(quality.sessionCount)),
          ListTile(title: Text(l.reputation_coverage), subtitle: Text(l.reputation_coverage_hint),
            trailing: Text(quality.coverage == null ? '—' : NumberFormat.percentPattern().format(quality.coverage),
              style: AppTypography.bodyLarge.colored(context.colors.textPrimary))),
          _metric(l.reputation_updated, _date(quality.computedAt)),
        ],
      ),
    );
  }
}

class SessionReputationAuditScreen extends ConsumerStatefulWidget {
  const SessionReputationAuditScreen({super.key, required this.clubId, required this.sessionId});
  final String clubId;
  final String sessionId;

  @override
  ConsumerState<SessionReputationAuditScreen> createState() => _SessionReputationAuditScreenState();
}

class _SessionReputationAuditScreenState extends ConsumerState<SessionReputationAuditScreen> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final allowed = ref.watch(authTokenProvider) != null &&
      ref.watch(activeClubContextProvider)?.clubId == widget.clubId &&
      ref.watch(hasClubPermissionProvider(reputationAuditPermission));
    final provider = reputationAuditProvider((clubId: widget.clubId, sessionId: widget.sessionId, page: _page));
    return ReputationScreenLayout(
      title: l.reputation_audit,
      refresh: () => allowed ? ref.refresh(provider.future) : Future<void>.value(),
      items: !allowed ? [ListTile(title: Text(l.reputation_permission))]
        : ref.watch(provider).when(
          skipLoadingOnRefresh: false,
          loading: () => [_loading],
          error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
          data: (audit) => [
            ListTile(
              title: Text(switch (audit.status) {
                'Finalized' => l.reputation_finalized,
                'DataInsufficient' => l.reputation_insufficient,
                'Pending' => l.reputation_pending,
                _ => l.reputation_empty,
              }),
              subtitle: Text([
                switch (audit.status) {
                  'Finalized' => l.reputation_finalized_detail,
                  'DataInsufficient' => l.reputation_insufficient_detail,
                  'Pending' => l.reputation_pending_detail,
                  _ => l.reputation_empty,
                },
                if (audit.pendingReason != null) audit.pendingReason!,
              ].join('\n')),
            ),
            _metric(l.reputation_players, _number(audit.playerCount)),
            _metric(l.reputation_courts, _number(audit.courtCount)),
            _metric(l.reputation_invoices, _number(audit.invoiceCount)),
            _metric(l.reputation_expenses, _number(audit.expenseCount)),
            if (audit.financialSources.isNotEmpty) ExpansionTile(
              title: Text(l.reputation_financial_sources),
              subtitle: Text(l.reputation_financial_detail),
              children: [
                for (final source in audit.financialSources)
                  Builder(builder: (context) {
                    final person = audit.bookings.items.where((row) => row.userId == source.userId).firstOrNull;
                    final label = switch (source.status) {
                      'EXEMPT' => l.reputation_exempt,
                      'PAID' => l.reputation_source_paid,
                      _ => l.reputation_unknown_source,
                    };
                    final description = switch (source.status) {
                      'EXEMPT' => l.reputation_source_exempt_detail,
                      'PAID' => l.reputation_source_paid_detail,
                      _ => l.reputation_insufficient,
                    };
                    return ListTile(
                      title: Text('${person?.fullName ?? l.reputation_unknown_member} · $label'),
                      subtitle: Text([
                        description,
                        if (source.status == 'PAID' && source.amount != null && source.amount! > 0)
                          '${l.reputation_source_remaining} · ${_number(source.amount)} ₫',
                        if (source.advanceAmount != null)
                          '${l.reputation_advance_source} · ${_number(source.advanceAmount)} ₫',
                      ].join('\n')),
                    );
                  }),
              ],
            ),
            for (final row in audit.bookings.items)
              Card(child: ExpansionTile(
                key: ValueKey(row.bookingId),
                title: Text(row.fullName ?? l.reputation_unknown_member),
                subtitle: row.review == null ? null : Text('${l.reputation_review_rating} · ${_score(row.review!.rating, 5)}'),
                trailing: Text('${_delta(row.rawDelta)} ${l.reputation_score_units}',
                    style: AppTypography.bodyLarge.colored(context.colors.textPrimary)),
                children: [
                  ..._evidence(context, row.evidence),
                  if (row.review?.comment != null) ListTile(title: Text(row.review!.comment!)),
                ],
              )),
            if (audit.bookings.items.isEmpty) ListTile(title: Text(l.reputation_empty)),
            _Pagination(audit.bookings.page, audit.bookings.hasMore, (page) => setState(() => _page = page)),
          ],
        ),
    );
  }
}
