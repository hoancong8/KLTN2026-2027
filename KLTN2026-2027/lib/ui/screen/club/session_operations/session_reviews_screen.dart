part of '../../reputation/reputation_screens.dart';

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({super.key, required this.invitation});
  final ReviewInvitation invitation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final review = invitation.review;
    final isSubmitted = review != null;
    final isPending = review == null && invitation.hasTime;

    return Container(
      decoration: BoxDecoration(
        color: isPending
            ? colors.primary.withValues(alpha: 0.06)
            : colors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(
            isPending ? Icons.rate_review_rounded : Icons.rate_review_outlined,
            color: isPending ? colors.primary : colors.textSecondary,
          ),
          title: Text(
            invitation.sessionTitle ?? l10n.reputation_session,
            style: isPending
                ? AppTypography.bodyLarge.bold.colored(colors.textPrimary)
                : AppTypography.bodyLarge.colored(colors.textSecondary),
          ),
          subtitle: Text(
            [
              invitation.groupName,
              if (invitation.sessionStartAt != null)
                _date(invitation.sessionStartAt),
              '${l10n.reputation_expires} · ${_date(invitation.expiresAt)}',
              isSubmitted
                  ? l10n.reputation_submitted
                  : invitation.hasTime
                      ? l10n.reputation_eligible
                      : l10n.reputation_expired,
            ].nonNulls.join('\n'),
            style: isPending
                ? AppTypography.bodySmall.medium.colored(colors.textPrimary)
                : AppTypography.bodySmall.colored(colors.textMuted),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isPending ? colors.primary : colors.textMuted,
          ),
          onTap: isSubmitted || invitation.hasTime
              ? () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _ReviewDialog(invitation: invitation),
                  );
                }
              : null,
        ),
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
    final colors = context.colors;
    final saved = _saved;
    final showForm = saved == null && !_unavailable && widget.invitation.hasTime;

    return PopScope(
      canPop: !_sending,
      child: AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Row(
          children: [
            Icon(
              saved != null
                  ? Icons.check_circle_rounded
                  : Icons.rate_review_rounded,
              color: saved != null ? colors.success : colors.primary,
              size: 24,
            ),
            AppSpacing.gapW8,
            Expanded(
              child: Text(
                saved != null ? 'Đã gửi đánh giá' : l10n.reputation_review,
                style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (saved != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: colors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.success.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var star = 1; star <= 5; star++)
                              Icon(
                                star <= saved.rating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: star <= saved.rating
                                    ? colors.accent
                                    : colors.textMuted,
                                size: 28,
                              ),
                          ],
                        ),
                        AppSpacing.gapH8,
                        Text(
                          '${saved.rating}.0 / 5 sao',
                          style: AppTypography.titleSmall.bold.colored(
                            colors.textPrimary,
                          ),
                        ),
                        if (saved.comment != null &&
                            saved.comment!.trim().isNotEmpty) ...[
                          AppSpacing.gapH12,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colors.cardBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                AppSpacing.gapW8,
                                Expanded(
                                  child: Text(
                                    saved.comment!,
                                    style: AppTypography.bodySmall.colored(
                                      colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (!showForm) ...[
                  Text(
                    l10n.reputation_unavailable,
                    style: AppTypography.bodyMedium.colored(colors.textSecondary),
                  ),
                ],
                if (showForm) ...[
                  Text(
                    widget.invitation.sessionTitle ?? l10n.reputation_session,
                    style: AppTypography.titleSmall.bold.colored(colors.textPrimary),
                  ),
                  if (widget.invitation.groupName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.invitation.groupName!,
                      style: AppTypography.bodySmall.colored(colors.textSecondary),
                    ),
                  ],
                  AppSpacing.gapH12,
                  Center(
                    child: Wrap(
                      spacing: 4,
                      children: [
                        for (var star = 1; star <= 5; star++)
                          IconButton(
                            tooltip: '${l10n.reputation_stars} $star/5',
                            isSelected: star <= _stars,
                            selectedIcon: Icon(
                              Icons.star_rounded,
                              color: colors.accent,
                              size: 32,
                            ),
                            icon: Icon(
                              Icons.star_border_rounded,
                              color: colors.textMuted,
                              size: 32,
                            ),
                            onPressed: _sending
                                ? null
                                : () => setState(() => _stars = star),
                          ),
                      ],
                    ),
                  ),
                  AppSpacing.gapH12,
                  TextField(
                    controller: _comment,
                    style: AppTypography.bodyMedium.colored(colors.textPrimary),
                    enabled: !_sending,
                    maxLength: 2000,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.reputation_comment,
                      hintText: 'Nhập nhận xét của bạn về buổi chơi (tùy chọn)...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
                if (_sending) ...[
                  AppSpacing.gapH12,
                  const Center(child: CircularProgressIndicator()),
                ],
                if (_failureReason != null) ...[
                  AppSpacing.gapH8,
                  Text(
                    _error(context, _failureReason!),
                    style: AppTypography.bodySmall.colored(colors.error),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          if (showForm) ...[
            TextButton(
              onPressed: _sending ? null : () => Navigator.of(context).pop(),
              child: Text(
                l10n.reputation_later,
                style: TextStyle(color: colors.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              onPressed: _sending || _stars == 0 ? null : _submit,
              child: Text(l10n.reputation_submit),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(l10n.com_close),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}
