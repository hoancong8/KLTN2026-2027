// lib/ui/screen/club/session_operations/session_reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/provider.dart';
import '../../../../app/theme/theme.dart';
import '../../../../domain/entities/session/session_review.dart';
import '../../../../widget/app_shimmer.dart';

final sessionReviewsNotifierProvider =
    StateNotifierProvider.autoDispose.family<SessionReviewsNotifier, AsyncValue<List<SessionReview>>, String>(
        (ref, sessionId) {
  final repo = ref.watch(sessionOperationsRepositoryProvider);
  return SessionReviewsNotifier(repo, sessionId);
});

class SessionReviewsNotifier extends StateNotifier<AsyncValue<List<SessionReview>>> {
  final dynamic _repo;
  final String sessionId;

  SessionReviewsNotifier(this._repo, this.sessionId) : super(const AsyncValue.loading()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      state = const AsyncValue.loading();
      final data = await _repo.getSessionReviews(sessionId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReview({
    required String reviewerName,
    required double rating,
    required String comment,
    required List<String> tags,
  }) async {
    try {
      final newRev = SessionReview(
        id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        reviewerId: 'me',
        reviewerName: reviewerName,
        rating: rating,
        comment: comment,
        tags: tags,
        createdAt: DateTime.now(),
      );
      await _repo.submitReview(newRev);
      await loadReviews();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class SessionReviewsScreen extends ConsumerWidget {
  final String sessionId;

  const SessionReviewsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncState = ref.watch(sessionReviewsNotifierProvider(sessionId));
    final vm = ref.read(sessionReviewsNotifierProvider(sessionId).notifier);
    final currentProfile = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đánh Giá & Tín Nhiệm', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
            Text('Đánh giá chất lượng buổi chơi & uy tín tay vợt',
                style: AppTypography.labelSmall.colored(colors.textMuted)),
          ],
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context, vm, currentProfile?.userName ?? 'Thành viên'),
        backgroundColor: colors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Viết đánh giá'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: asyncState.when(
            loading: () => ListView(
              padding: AppSpacing.allBase,
              children: [
                AppShimmer.card(height: 100),
                AppSpacing.gapH16,
                AppShimmer.line(width: 180, height: 20),
                AppSpacing.gapH12,
                AppShimmer.card(height: 90),
                AppSpacing.gapH8,
                AppShimmer.card(height: 90),
              ],
            ),
            error: (err, _) => Padding(
              padding: AppSpacing.allXl,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                  AppSpacing.gapH12,
                  Text('Không thể tải đánh giá', style: AppTypography.titleMedium.bold.colored(colors.textPrimary)),
                  AppSpacing.gapH4,
                  Text('$err', style: AppTypography.bodySmall.colored(colors.textMuted), textAlign: TextAlign.center),
                  AppSpacing.gapH16,
                  ElevatedButton.icon(
                    onPressed: vm.loadReviews,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(120, 44),
                    ),
                  ),
                ],
              ),
            ),
            data: (reviews) {
              return RefreshIndicator(
                onRefresh: vm.loadReviews,
                color: colors.primary,
                child: ListView(
                  padding: AppSpacing.allBase,
                  children: [
                    // 1. Reputation Summary Card
                    Container(
                      padding: AppSpacing.allBase,
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: colors.cardBorder),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.star_rounded, size: 36, color: colors.warning),
                          ),
                          AppSpacing.gapW16,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '4.9 / 5.0 Điểm Tín Nhiệm',
                                  style: AppTypography.titleMedium.bold.colored(colors.textPrimary),
                                ),
                                AppSpacing.gapH4,
                                Text(
                                  'Đánh giá dựa trên tính minh bạch chi phí, xoay tua sân công bằng và văn hóa sinh hoạt.',
                                  style: AppTypography.bodySmall.colored(colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapH16,

                    // 2. Reviews List
                    Text('Nhận xét từ người tham gia (${reviews.length})',
                        style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                    AppSpacing.gapH8,

                    if (reviews.isEmpty)
                      Container(
                        padding: AppSpacing.allXl,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.rate_review_outlined, size: 48, color: colors.textMuted),
                            AppSpacing.gapH12,
                            Text(
                              'Chưa có đánh giá nào cho buổi sinh hoạt này. Hãy là người đầu tiên chia sẻ cảm nhận!',
                              style: AppTypography.bodyMedium.colored(colors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...reviews.map((rev) => _buildReviewCard(context, rev)),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, SessionReview rev) {
    final colors = context.colors;
    final dateStr = DateFormat('HH:mm - dd/MM/yyyy').format(rev.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.allBase,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.primary.withValues(alpha: 0.15),
                child: Text(
                  rev.reviewerName.isNotEmpty ? rev.reviewerName[0].toUpperCase() : '?',
                  style: AppTypography.labelMedium.bold.colored(colors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rev.reviewerName, style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                    Text(dateStr, style: AppTypography.labelSmall.colored(colors.textMuted)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 18, color: colors.warning),
                  AppSpacing.gapW4,
                  Text('${rev.rating}', style: AppTypography.titleSmall.bold.colored(colors.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(rev.comment, style: AppTypography.bodySmall.colored(colors.textPrimary)),
          if (rev.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: rev.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.tag,
                  ),
                  child: Text(tag, style: AppTypography.labelSmall.bold.colored(colors.primary)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, SessionReviewsNotifier vm, String defaultName) {
    final colors = context.colors;
    final commentCtrl = TextEditingController();
    var rating = 5.0;
    final selectedTags = <String>['Xoay sân công bằng', 'Vui vẻ'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Viết Đánh Giá Buổi Chơi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mức độ hài lòng:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [1, 2, 3, 4, 5].map((star) {
                    return IconButton(
                      icon: Icon(
                        star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: colors.warning,
                        size: 32,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setDialogState(() => rating = star.toDouble());
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Nhận xét của bạn *',
                    hintText: 'Nhập trải nghiệm về buổi chơi, công tác tổ chức...',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Đặc điểm nổi bật:'),
                Wrap(
                  spacing: 6,
                  children: [
                    'Xoay sân công bằng',
                    'Đúng giờ',
                    'Minh bạch tài chính',
                    'Vui vẻ nhiệt tình',
                    'Trình độ đồng đều',
                  ].map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        setDialogState(() {
                          if (val) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(0, 44),
              ),
              onPressed: () {
                if (commentCtrl.text.trim().isNotEmpty) {
                  HapticFeedback.mediumImpact();
                  vm.addReview(
                    reviewerName: defaultName,
                    rating: rating,
                    comment: commentCtrl.text.trim(),
                    tags: selectedTags,
                  );
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Vui lòng nhập nội dung nhận xét trước khi gửi!'),
                      backgroundColor: colors.warning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Gửi Đánh Giá'),
            ),
          ],
        ),
      ),
    );
  }
}
