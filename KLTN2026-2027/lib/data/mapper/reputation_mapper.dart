import '../../domain/entities/reputation/reputation.dart';
import '../dto/reputation/reputation_dto.dart';

class ReputationMapper {
  static ReputationPage<T> page<T>(ReputationDto dto, T Function(ReputationDto) map) =>
      ReputationPage(List.unmodifiable(dto.list('items').map(map)), dto.integer('page') ?? 1,
          dto.integer('pageSize') ?? 20, dto.integer('total') ?? 0);

  static SessionRating review(ReputationDto dto) => SessionRating(
      dto.string('sessionId') ?? '', dto.integer('rating') ?? 0,
      dto.string('comment'), dto.date('createdAt'));

  static SessionRating? _review(ReputationDto? dto) => dto == null ? null : review(dto);

  static ReviewInvitation invitation(ReputationDto dto) => ReviewInvitation(
      sessionId: dto.string('sessionId') ?? '', groupId: dto.string('groupId') ?? '',
      sessionTitle: dto.string('sessionTitle'), groupName: dto.string('groupName'),
      sessionStartAt: dto.date('sessionStartAt'), expiresAt: dto.date('expiresAt'),
      review: _review(dto.object('review')));

  static PlayerReputation player(ReputationDto dto) => PlayerReputation(
      dto.number('score'), dto.string('riskLabel'), dto.date('computedAt'),
      dto.integer('sampleCount'));

  static ReputationEvidence? _evidence(ReputationDto? dto) => dto == null ? null : ReputationEvidence(
      attendance: dto.string('attendance') ?? dto.integer('attendance')?.toString(),
      payment: dto.string('payment') ?? dto.integer('payment')?.toString(),
      checkinAt: dto.date('checkinAt'), publishedAt: dto.date('publishedAt'),
      receivedAt: dto.date('receivedAt'), cancelledAt: dto.object('cancellation')?.date('cancelledAt'));

  static ReputationEntry entry(ReputationDto dto) => ReputationEntry(
      bookingId: dto.string('bookingId') ?? '', sessionId: dto.string('sessionId') ?? '',
      sessionTitle: dto.string('sessionTitle'), groupName: dto.string('groupName'),
      rawDelta: dto.number('rawDelta'), computedAt: dto.date('computedAt'),
      policyVersion: dto.string('policyVersion'), evidence: _evidence(dto.object('evidence')));

  static GroupQuality quality(ReputationDto dto) {
    final summary = dto.object('summary');
    return GroupQuality(
        score: dto.number('score'), computedAt: dto.date('computedAt'),
        reviews: summary?.number('reviews'), transparency: summary?.number('transparency'),
        density: summary?.number('density'), reviewCount: summary?.integer('reviewCount'),
        sessionCount: summary?.integer('sessionCount'), coverage: summary?.number('coverage'),
        hasResult: dto.date('computedAt') != null && summary?.number('score') != null);
  }

  static SessionReputationAudit audit(ReputationDto dto) {
    final snapshot = dto.object('snapshot');
    final quality = snapshot?.object('quality');
    final bookings = dto.object('bookings');
    return SessionReputationAudit(
        status: dto.string('status'), pendingReason: dto.string('pendingReason'),
        bookings: bookings == null ? const ReputationPage([], 1, 20, 0) : page(bookings, (row) =>
          ReputationAuditBooking(row.string('bookingId') ?? '', row.string('userId') ?? '',
              row.number('rawDelta'), _evidence(row.object('evidence')), _review(row.object('review')),
              fullName: row.string('fullName'))),
        financialSources: List.unmodifiable(snapshot?.list('financialEvidence').map((row) {
          return ReputationFinancialSource(row.string('userId') ?? '', row.string('status'),
              row.number('amount'), row.object('advance')?.number('amount'));
        }) ?? const <ReputationFinancialSource>[]),
        playerCount: quality?.integer('playerCount'), courtCount: quality?.integer('courtCount'),
        invoiceCount: quality?.integer('invoiceCount'), expenseCount: quality?.integer('expenseCount'));
  }
}
