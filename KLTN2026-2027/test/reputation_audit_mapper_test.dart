import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/reputation/reputation_dto.dart';
import 'package:kltn2026_2027/data/mapper/reputation_mapper.dart';

void main() {
  test('audit preserves names, zero amounts, advance evidence and snapshot counts', () {
    final audit = ReputationMapper.audit(ReputationDto.fromJson({
      'status': 'Finalized',
      'snapshot': {
        'quality': {'playerCount': 2, 'courtCount': 0, 'invoiceCount': 0, 'expenseCount': 0},
        'financialEvidence': [
          {'userId': 'user-1', 'status': 'EXEMPT', 'amount': 0},
          {'userId': 'user-2', 'status': 'PAID', 'amount': 20000,
            'advance': {'amount': 50000}},
        ],
      },
      'bookings': {
        'page': 1, 'pageSize': 20, 'total': 2,
        'items': [
          {'bookingId': 'booking-1', 'userId': 'user-1', 'fullName': 'Nguyễn An', 'rawDelta': 0},
          {'bookingId': 'booking-2', 'userId': 'user-2', 'fullName': 'Trần Bình', 'rawDelta': 1,
            'review': {'sessionId': 'session-1', 'rating': 4}},
        ],
      },
    }));
    expect(audit.status, 'Finalized');
    expect(audit.playerCount, 2);
    expect(audit.courtCount, 0);
    expect(audit.bookings.items.first.fullName, 'Nguyễn An');
    expect(audit.bookings.items.first.rawDelta, 0);
    expect(audit.bookings.items.last.review?.rating, 4);
    expect(audit.financialSources.first.status, 'EXEMPT');
    expect(audit.financialSources.first.amount, 0);
    expect(audit.financialSources.last.amount, 20000);
    expect(audit.financialSources.last.advanceAmount, 50000);
  });
}
