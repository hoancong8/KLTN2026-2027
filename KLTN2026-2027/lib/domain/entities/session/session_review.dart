// lib/domain/entities/session/session_review.dart

class SessionReview {
  final String id;
  final String sessionId;
  final String reviewerId;
  final String reviewerName;
  final String? targetMemberId;
  final String? targetMemberName;
  final double rating; // 1.0 -> 5.0
  final String comment;
  final List<String> tags; // 'Đúng giờ', 'Đánh nhiệt tình', 'Vui vẻ', 'Fair-play'
  final DateTime createdAt;

  const SessionReview({
    required this.id,
    required this.sessionId,
    required this.reviewerId,
    required this.reviewerName,
    this.targetMemberId,
    this.targetMemberName,
    required this.rating,
    required this.comment,
    this.tags = const [],
    required this.createdAt,
  });
}
