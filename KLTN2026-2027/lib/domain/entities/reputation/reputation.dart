import '../session/session_review.dart';

export '../session/session_review.dart';

class ReputationPage<T> {
  const ReputationPage(this.items, this.page, this.pageSize, this.total);

  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  bool get hasMore => page * pageSize < total;
}

class ReviewInvitation {
  const ReviewInvitation({
    required this.sessionId,
    required this.groupId,
    required this.sessionTitle,
    required this.groupName,
    required this.sessionStartAt,
    required this.expiresAt,
    required this.review,
  });

  final String sessionId;
  final String groupId;
  final String? sessionTitle;
  final String? groupName;
  final DateTime? sessionStartAt;
  final DateTime? expiresAt;
  final SessionRating? review;

  bool get hasTime => expiresAt?.isAfter(DateTime.now().toUtc()) ?? false;
}

class PlayerReputation {
  const PlayerReputation(this.score, this.riskLabel, this.computedAt, this.sampleCount);

  final double? score;
  final String? riskLabel;
  final DateTime? computedAt;
  final int? sampleCount;
}

class ReputationEvidence {
  const ReputationEvidence({
    required this.attendance,
    required this.payment,
    required this.checkinAt,
    required this.publishedAt,
    required this.receivedAt,
    required this.cancelledAt,
  });

  final String? attendance;
  final String? payment;
  final DateTime? checkinAt;
  final DateTime? publishedAt;
  final DateTime? receivedAt;
  final DateTime? cancelledAt;
}

class ReputationEntry {
  const ReputationEntry({
    required this.bookingId,
    required this.sessionId,
    required this.sessionTitle,
    required this.groupName,
    required this.rawDelta,
    required this.computedAt,
    required this.policyVersion,
    required this.evidence,
    this.reasons,
  });

  final String bookingId;
  final String sessionId;
  final String? sessionTitle;
  final String? groupName;
  final double? rawDelta;
  final DateTime? computedAt;
  final String? policyVersion;
  final ReputationEvidence? evidence;
  final List<ReputationReason>? reasons;
}

class ReputationReason {
  const ReputationReason(this.code, this.points, this.suppressed);

  final String code;
  final double? points;
  final bool suppressed;
}

class GroupQuality {
  const GroupQuality({
    required this.score,
    required this.computedAt,
    required this.reviews,
    required this.transparency,
    required this.density,
    required this.reviewCount,
    required this.sessionCount,
    required this.coverage,
    required this.hasResult,
  });

  final double? score;
  final DateTime? computedAt;
  final double? reviews;
  final double? transparency;
  final double? density;
  final int? reviewCount;
  final int? sessionCount;
  final double? coverage;
  final bool hasResult;
}

class ReputationAuditBooking {
  const ReputationAuditBooking(this.bookingId, this.userId, this.rawDelta, this.evidence, this.review, {this.fullName});

  final String? fullName;

  final String bookingId;
  final String userId;
  final double? rawDelta;
  final ReputationEvidence? evidence;
  final SessionRating? review;
}

class ReputationFinancialSource {
  const ReputationFinancialSource(this.userId, this.status, this.amount, this.advanceAmount);

  final String userId;
  final String? status;
  final double? amount;
  final double? advanceAmount;
}

class SessionReputationAudit {
  const SessionReputationAudit({
    required this.status,
    required this.pendingReason,
    required this.bookings,
    required this.financialSources,
    required this.playerCount,
    required this.courtCount,
    required this.invoiceCount,
    required this.expenseCount,
  });

  final String? status;
  final String? pendingReason;
  final ReputationPage<ReputationAuditBooking> bookings;
  final List<ReputationFinancialSource> financialSources;
  final int? playerCount;
  final int? courtCount;
  final int? invoiceCount;
  final int? expenseCount;
}
