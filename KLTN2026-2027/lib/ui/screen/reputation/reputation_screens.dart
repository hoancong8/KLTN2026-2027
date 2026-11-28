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

String _date(DateTime? value) => value == null
    ? '—'
    : DateFormat('HH:mm, dd/MM/yyyy').format(value.toUtc().add(const Duration(hours: 7)));
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
              shape: const Border(),
              collapsedShape: const Border(),
            ),
            cardTheme: CardThemeData(
              color: context.colors.cardBackground,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: context.colors.cardBorder),
              ),
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
            children: [
              for (final item in items)
                if (item is Card || item is Container || item is _HistoryEntryTile ||
                    item is _QualityHeaderCard || item is _QualityOverviewCard ||
                    item is _QualityMetricsCard || item is _QualityCoverageCard ||
                    item is _Pagination || item is LinearProgressIndicator)
                  item
                else
                  Card(clipBehavior: Clip.antiAlias, child: item),
            ],
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
          skipLoadingOnRefresh: true,
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
    final colors = context.colors;
    final id = userId ?? ref.watch(currentUserProfileProvider)?.id;
    final provider = id == null || id.isEmpty ? null : playerReputationProvider(id);

    final invitationsAsync = userId == null
        ? ref.watch(reputationInvitationsProvider((page: 1, sessionId: null)))
        : null;
    final pendingCount = invitationsAsync?.when(
          data: (page) =>
              page.items.where((inv) => inv.review == null && inv.hasTime).length,
          loading: () => 0,
          error: (_, _) => 0,
        ) ??
        0;

    return ReputationScreenLayout(
      title: userId == null ? l10n.reputation_title : l10n.reputation_player,
      refresh: () => provider == null ? Future<void>.value() : ref.refresh(provider.future),
      items: [
        if (provider == null) ListTile(title: Text(l10n.reputation_empty))
        else ...ref.watch(provider).when(
          skipLoadingOnRefresh: true,
          loading: () => [_loading],
          error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
          data: (player) => [
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: AppRadius.card,
                border: Border.all(color: colors.cardBorder),
                boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: colors.accent,
                      size: 32,
                    ),
                  ),
                  AppSpacing.gapW16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reputation_title,
                          style: AppTypography.bodySmall.colored(
                            colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: _number(player.score),
                                style: AppTypography.headlineMedium.bold.colored(colors.textPrimary),
                                children: [TextSpan(text: '/100',
                                  style: AppTypography.titleMedium.bold.colored(colors.textMuted))],
                              ),
                            ),
                            if (player.riskLabel != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.error.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.chip,
                                  border: Border.all(
                                    color: colors.error.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  player.riskLabel!,
                                  style: AppTypography.labelSmall.bold.colored(
                                    colors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (player.computedAt == null) ListTile(title: Text(l10n.reputation_no_result)),
            if (userId == null) ...[
              _metric(l10n.reputation_sample_count, _number(player.sampleCount)),
            ],
          ],
        ),
        if (userId == null) ...[
          ListTile(
            leading: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text(
                '$pendingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: colors.error,
              child: const Icon(Icons.rate_review_outlined),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.reputation_invitations,
                    style: pendingCount > 0
                        ? AppTypography.bodyLarge.bold.colored(colors.textPrimary)
                        : AppTypography.bodyLarge.colored(colors.textPrimary),
                  ),
                ),
                if (pendingCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pendingCount chưa đánh giá',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppConfig.reviewsRoute()),
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(l10n.reputation_history),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/reputation/history'),
          ),
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
  final colors = context.colors;
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
  final rows = <Widget>[
    if (attendance != null) _metric(l.reputation_attendance, attendance),
    if (payment != null) _metric(l.reputation_payment, payment),
    if (evidence.checkinAt != null) _metric(l.reputation_checkin, _date(evidence.checkinAt)),
    if (evidence.publishedAt != null) _metric(l.reputation_published, _date(evidence.publishedAt)),
    if (evidence.receivedAt != null) _metric(l.reputation_received, _date(evidence.receivedAt)),
    if (evidence.cancelledAt != null) _metric(l.reputation_cancelled, _date(evidence.cancelledAt)),
  ];
  return [
    Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(children: rows),
    ),
  ];
}

String _delta(double? value) => value != null && value > 0 ? '+${_number(value)}' : _number(value);

List<Widget> _reasons(BuildContext context, List<ReputationReason>? reasons) {
  final l = context.l10n;
  if (reasons == null) return [ListTile(title: Text(l.reputation_reason_unavailable))];
  return [
    for (final reason in reasons)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (reason.code) {
          'CHECKED_IN_ON_TIME' => l.reputation_reason_on_time,
          'CHECKED_IN_LATE' => l.reputation_reason_late,
          'NO_SHOW' => l.reputation_reason_no_show,
          'LATE_CANCELLATION' => l.reputation_reason_cancel,
          'ATTENDANCE_NEUTRAL' => l.reputation_reason_attendance_neutral,
          'ADVANCE_PAID' => l.reputation_reason_advance,
          'PAID_ON_TIME' => l.reputation_reason_paid,
          'PAID_LATE' => l.reputation_reason_paid_late,
          'PAYMENT_EXEMPT' => l.reputation_reason_exempt,
          'PAYMENT_NEUTRAL' => l.reputation_reason_payment_neutral,
          _ => l.reputation_reason_unavailable,
                }, style: AppTypography.bodyMedium.colored(context.colors.textPrimary)),
                if (reason.suppressed) ...[
                  const SizedBox(height: 4),
                  Text(l.reputation_reason_suppressed,
                      style: AppTypography.bodySmall.colored(context.colors.textSecondary)),
                ],
              ],
            )),
            const SizedBox(width: 12),
            Text('${_delta(reason.points)} ${l.reputation_score_units}',
                style: AppTypography.labelMedium.bold.colored(
                  reason.points == null ? context.colors.textMuted :
                  reason.points! > 0 ? context.colors.success :
                  reason.points! < 0 ? context.colors.error : context.colors.textSecondary,
                )),
          ],
        ),
      ),
  ];
}

class _HistoryEntryTile extends StatefulWidget {
  const _HistoryEntryTile({super.key, required this.row});
  final ReputationEntry row;

  @override
  State<_HistoryEntryTile> createState() => _HistoryEntryTileState();
}

class _HistoryEntryTileState extends State<_HistoryEntryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l = context.l10n;
    final row = widget.row;
    final delta = row.rawDelta ?? 0;
    final isPositive = delta > 0;
    final isNegative = delta < 0;

    final deltaColor = isPositive
        ? colors.success
        : isNegative
            ? colors.error
            : colors.textSecondary;

    final deltaBg = isPositive
        ? colors.success.withValues(alpha: 0.12)
        : isNegative
            ? colors.error.withValues(alpha: 0.12)
            : colors.inputFill;

    final deltaIcon = isPositive
        ? Icons.trending_up_rounded
        : isNegative
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        key: ValueKey(row.bookingId),
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: deltaBg,
            shape: BoxShape.circle,
          ),
          child: Icon(deltaIcon, color: deltaColor, size: 22),
        ),
        title: Text(
          row.sessionTitle ?? l.reputation_session,
          style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (row.groupName != null)
                Text(
                  row.groupName!,
                  style: AppTypography.bodySmall.colored(colors.textSecondary),
                ),
              if (row.computedAt != null)
                Text(
                  '· ${_date(row.computedAt)}',
                  style: AppTypography.bodySmall.colored(colors.textMuted),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: deltaBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: deltaColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                _delta(row.rawDelta),
                style: AppTypography.labelMedium.bold.colored(deltaColor),
              ),
            ),
            AppSpacing.gapW8,
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.textSecondary,
                size: 22,
              ),
            ),
          ],
        ),
        children: [
          Divider(height: 1, color: colors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.reputation_reason_details,
                style: AppTypography.labelMedium.bold.colored(colors.textSecondary),
              ),
            ),
          ),
          ..._reasons(context, row.reasons),
          if (row.evidence != null)
            ExpansionTile(
              title: Text(
                l.reputation_evidence_details,
                style: AppTypography.bodySmall.colored(colors.textSecondary),
              ),
              children: _evidence(context, row.evidence),
            ),
        ],
      ),
    );
  }
}

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
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: context.colors.cardBorder),
                  boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.colors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.accent.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: context.colors.accent,
                        size: 28,
                      ),
                    ),
                    AppSpacing.gapW16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.reputation_player,
                            style: AppTypography.bodySmall.colored(
                              context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _number(player.score),
                                style: AppTypography.titleLarge.bold.colored(
                                  context.colors.textPrimary,
                                ),
                              ),
                              Text(
                                '/100',
                                style: AppTypography.bodyMedium.bold.colored(
                                  context.colors.textMuted,
                                ),
                              ),
                              if (player.riskLabel != null) ...[
                                AppSpacing.gapW8,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.success.withValues(alpha: 0.15),
                                    borderRadius: AppRadius.chip,
                                    border: Border.all(
                                      color: context.colors.success.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    player.riskLabel!,
                                    style: AppTypography.labelSmall.bold.colored(
                                      context.colors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (player.computedAt == null) ListTile(title: Text(l.reputation_no_result)),
              _metric(l.reputation_sample_count, _number(player.sampleCount)),
            ],
          ),
        ...ref.watch(provider).when(
          skipLoadingOnRefresh: true,
          loading: () => [_loading],
          error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
          data: (rows) => [
            if (rows.items.isEmpty) ListTile(title: Text(l.reputation_empty)),
            for (final row in rows.items)
              _HistoryEntryTile(key: ValueKey(row.bookingId), row: row),
            _Pagination(rows.page, rows.hasMore, (page) => setState(() => _page = page)),
          ],
        ),
      ],
    );
  }
}

class _QualityMetricRow extends StatelessWidget {
  const _QualityMetricRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueText,
    this.progress,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String valueText;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasProgress = progress != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.medium.colored(colors.textPrimary),
                ),
              ),
              AppSpacing.gapW8,
              Text(
                valueText,
                style: AppTypography.labelLarge.bold.colored(
                  hasProgress ? colors.textPrimary : colors.textMuted,
                ),
              ),
            ],
          ),
          if (hasProgress) ...[
            AppSpacing.gapH8,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: iconColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QualityHeaderCard extends StatelessWidget {
  const _QualityHeaderCard({required this.quality});
  final GroupQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l = context.l10n;
    final score = quality.score;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: colors.warning,
                  size: 34,
                ),
              ),
              AppSpacing.gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.reputation_quality_total,
                      style: AppTypography.bodySmall.colored(colors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: score == null ? '—' : _number(score),
                            style: AppTypography.headlineMedium.bold.colored(colors.textPrimary),
                            children: [
                              TextSpan(
                                text: '/5',
                                style: AppTypography.titleMedium.bold.colored(colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (!quality.hasResult)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.12),
                              borderRadius: AppRadius.chip,
                              border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              l.reputation_no_result,
                              style: AppTypography.labelSmall.bold.colored(colors.warning),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Text(
            l.reputation_quality_formula,
            style: AppTypography.bodySmall.colored(colors.textSecondary),
          ),
          if (quality.computedAt != null) ...[
            AppSpacing.gapH12,
            Divider(height: 1, color: colors.divider),
            AppSpacing.gapH8,
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: colors.textMuted),
                AppSpacing.gapW4,
                Expanded(
                  child: Text(
                    '${l.reputation_updated}: ${_date(quality.computedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.colored(colors.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QualityOverviewCard extends StatelessWidget {
  const _QualityOverviewCard({required this.quality});
  final GroupQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _overviewItem(
              context: context,
              icon: Icons.rate_review_rounded,
              iconColor: colors.primary,
              value: _number(quality.reviewCount),
              label: l.reputation_review_count,
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: colors.divider,
          ),
          Expanded(
            child: _overviewItem(
              context: context,
              icon: Icons.event_available_rounded,
              iconColor: colors.info,
              value: _number(quality.sessionCount),
              label: l.reputation_session_count,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final colors = context.colors;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            AppSpacing.gapW4,
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleLarge.bold.colored(colors.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.colored(colors.textSecondary),
        ),
      ],
    );
  }
}

class _QualityMetricsCard extends StatelessWidget {
  const _QualityMetricsCard({required this.quality});
  final GroupQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
        boxShadow: context.isDark ? AppShadows.none : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.xs),
            child: Text(
              l.reputation_reason_details,
              style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
            ),
          ),
          _QualityMetricRow(
            icon: Icons.star_rounded,
            iconColor: colors.warning,
            label: l.reputation_player_rating,
            valueText: quality.reviews == null ? l.reputation_insufficient : '${_number(quality.reviews)}/5',
            progress: quality.reviews != null ? (quality.reviews! / 5) : null,
          ),
          Divider(height: 1, color: colors.divider),
          _QualityMetricRow(
            icon: Icons.verified_user_rounded,
            iconColor: colors.success,
            label: l.reputation_transparency,
            valueText: quality.transparency == null ? l.reputation_insufficient : '${_number(quality.transparency)}/5',
            progress: quality.transparency != null ? (quality.transparency! / 5) : null,
          ),
          Divider(height: 1, color: colors.divider),
          _QualityMetricRow(
            icon: Icons.groups_rounded,
            iconColor: colors.info,
            label: l.reputation_density,
            valueText: quality.density == null ? l.reputation_insufficient : '${_number(quality.density)}/5',
            progress: quality.density != null ? (quality.density! / 5) : null,
          ),
        ],
      ),
    );
  }
}

class _QualityCoverageCard extends StatelessWidget {
  const _QualityCoverageCard({required this.quality});
  final GroupQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l = context.l10n;
    final coverage = quality.coverage;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.pie_chart_rounded, color: colors.primary, size: 20),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.reputation_coverage,
                      style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                    ),
                    Text(
                      l.reputation_coverage_hint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.colored(colors.textSecondary),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.chip,
                  border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  coverage == null ? '—' : NumberFormat.percentPattern().format(coverage),
                  style: AppTypography.labelLarge.bold.colored(colors.primary),
                ),
              ),
            ],
          ),
          if (coverage != null) ...[
            AppSpacing.gapH12,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: coverage.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          ],
        ],
      ),
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
        skipLoadingOnRefresh: true,
        loading: () => [_loading],
        error: (error, _) => [_failure(context, error, () => ref.invalidate(provider))],
        data: (quality) => [
          _QualityHeaderCard(quality: quality),
          _QualityOverviewCard(quality: quality),
          _QualityMetricsCard(quality: quality),
          _QualityCoverageCard(quality: quality),
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
          skipLoadingOnRefresh: true,
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
              children: ListTile.divideTiles(context: context, color: context.colors.divider, tiles: [
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
              ]).toList(),
            ),
            ExpansionTile(
              title: Text(l.reputation_member_results),
              children: [
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
          ],
        ),
    );
  }
}
