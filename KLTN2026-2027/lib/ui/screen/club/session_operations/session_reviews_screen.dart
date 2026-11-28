part of '../../reputation/reputation_screens.dart';

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({super.key, required this.invitation});
  final ReviewInvitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final review = invitation.review;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.rate_review_outlined),
        title: Text(invitation.sessionTitle ?? l10n.reputation_session),
        subtitle: Text([
          invitation.groupName,
          if (invitation.sessionStartAt != null) _date(invitation.sessionStartAt),
          '${l10n.reputation_expires} · ${_date(invitation.expiresAt)}',
          review != null ? l10n.reputation_submitted :
            invitation.hasTime ? l10n.reputation_eligible : l10n.reputation_expired,
        ].nonNulls.join('\n')),
        trailing: const Icon(Icons.chevron_right),
        onTap: review != null || invitation.hasTime ? () {
          showDialog<void>(
            context: context,
            builder: (_) => _ReviewDialog(invitation: invitation),
          );
        } : null,
      ),
    );
  }
}
class _ReviewDialog extends ConsumerStatefulWidget {
  const _ReviewDialog({required this.invitation});
  final ReviewInvitation invitation;

  @override
  ConsumerState<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<_ReviewDialog> {
  final _comment = TextEditingController();
  int _stars = 0;
  bool _sending = false;
  bool _unavailable = false;
  Object? _failureReason;
  SessionRating? _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.invitation.review;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending || _stars == 0 || !widget.invitation.hasTime) return;
    final userId = ref.read(authTokenProvider)?.userId;
    if (userId == null) return;
    final id = widget.invitation.sessionId;
    final repository = ref.read(reputationRepositoryProvider);
    bool locallyCurrent() => mounted && userId == ref.read(authTokenProvider)?.userId;
    setState(() { _sending = true; _failureReason = null; });
    try {
      final review = await ref.read(submitSessionReviewProvider)(id, _stars, _comment.text);
      if (!locallyCurrent()) return;
      setState(() => _saved = review);
      ref.read(reputationRevisionProvider.notifier).state++;
    } on ReviewConflictException catch (error) {
      try {
        final page = await repository.invitations(1, sessionId: id);
        if (!locallyCurrent()) return;
        setState(() {
          final current = page.items.firstOrNull;
          _saved = current?.review;
          _unavailable = current?.hasTime != true && _saved == null;
          if (_saved == null && !_unavailable) _failureReason = error;
        });
        if (_saved != null || _unavailable) {
          ref.read(reputationRevisionProvider.notifier).state++;
        }
      } catch (reloadError) {
        if (locallyCurrent()) setState(() => _failureReason = reloadError);
      }
    } catch (error) {
      if (locallyCurrent()) {
        setState(() {
          _unavailable = error is ForbiddenException || error is NotFoundException;
          _failureReason = error;
        });
      }
    } finally {
      if (locallyCurrent()) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authTokenProvider, (before, after) {
      if (before?.userId != after?.userId && mounted) Navigator.of(context).pop();
    });
    final l10n = context.l10n;
    final saved = _saved;
    final showForm = saved == null && !_unavailable && widget.invitation.hasTime;
    return PopScope(
      canPop: !_sending,
      child: AlertDialog(
        title: Text(l10n.reputation_review),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (saved != null) ...[
                  Text('${l10n.reputation_submitted} · ${_score(saved.rating, 5)}',
                      style: AppTypography.bodyLarge.colored(context.colors.textPrimary)),
                  if (saved.comment != null) Text(saved.comment!,
                      style: AppTypography.bodyLarge.colored(context.colors.textPrimary)),
                ] else if (!showForm)
                  Text(l10n.reputation_unavailable),
                if (showForm) ...[
                  Wrap(children: [
                    for (var star = 1; star <= 5; star++)
                      IconButton(
                        tooltip: '${l10n.reputation_stars} $star/5',
                        isSelected: star <= _stars,
                        selectedIcon: const Icon(Icons.star),
                        icon: const Icon(Icons.star_border),
                        onPressed: _sending ? null : () => setState(() => _stars = star),
                      ),
                  ]),
                  TextField(
                    controller: _comment,
                    style: AppTypography.bodyLarge.colored(context.colors.textPrimary),
                    enabled: !_sending,
                    maxLength: 2000,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: l10n.reputation_comment),
                  ),
                ],
                if (_sending) _loading,
                if (_failureReason != null) Text(_error(context, _failureReason!)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : () => Navigator.of(context).pop(),
            child: Text(showForm ? l10n.reputation_later : l10n.com_close),
          ),
          if (showForm)
            FilledButton(
              onPressed: _sending || _stars == 0 ? null : _submit,
              child: Text(l10n.reputation_submit),
            ),
        ],
      ),
    );
  }
}
