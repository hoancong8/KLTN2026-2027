import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/session/session_dto.dart';
import 'package:kltn2026_2027/data/dto/session/session_booking_dto.dart';
import 'package:kltn2026_2027/data/dto/session/guest_recruitment_dto.dart';
import 'package:kltn2026_2027/data/mapper/session_mapper.dart';
import 'package:kltn2026_2027/domain/enums/session_enums.dart';

void main() {
  group('Session & Booking API Mapper Verification', () {
    test('SessionDto parses ABP json correctly and maps to Session entity', () {
      final json = {
        'id': 'sess-123',
        'groupId': 'club-456',
        'clubName': 'Legends Team',
        'title': 'Buổi đánh cầu thứ 7',
        'startTime': '2026-10-18T18:00:00Z',
        'endTime': '2026-10-18T20:00:00Z',
        'courtLocation': 'Sân Cầu Lông Kỳ Hòa',
        'courtCount': 2,
        'targetPlayerPerCourt': 6,
        'maxPlayers': 12,
        'deadlineBooking': '2026-10-18T12:00:00Z',
        'courtRentalCost': 150000.0,
        'status': 'OPEN',
        'confirmedCount': 10,
        'waitingCount': 2,
        'isBookedByCurrentUser': false,
        'currentUserBookingStatus': null,
        'currentUserQueueOrder': 0,
      };

      final dto = SessionDto.fromJson(json);
      expect(dto.id, 'sess-123');
      expect(dto.maxPlayers, 12);
      expect(dto.confirmedCount, 10);
      expect(dto.waitingCount, 2);

      final entity = SessionMapper.toEntity(dto);
      expect(entity.id, 'sess-123');
      expect(entity.status, SessionStatus.open);
      expect(entity.isFull, false);
      expect(entity.slotsRemaining, 2);
    });

    test('SessionBookingDto maps CONFIRMED and WAITING status with queueOrder', () {
      final jsonConfirmed = {
        'bookingId': 'book-1',
        'sessionId': 'sess-123',
        'userId': 'user-1',
        'fullName': 'Nguyễn Văn A',
        'status': 'CONFIRMED',
        'queueOrder': 0,
        'bookedAt': '2026-10-18T14:00:00Z',
      };

      final jsonWaiting = {
        'bookingId': 'book-2',
        'sessionId': 'sess-123',
        'userId': 'user-2',
        'fullName': 'Trần Văn B',
        'status': 'WAITING',
        'queueOrder': 1,
        'bookedAt': '2026-10-18T14:05:00Z',
      };

      final b1 = SessionMapper.toBookingEntity(SessionBookingDto.fromJson(jsonConfirmed));
      final b2 = SessionMapper.toBookingEntity(SessionBookingDto.fromJson(jsonWaiting));

      expect(b1.status, BookingStatus.confirmed);
      expect(b1.queueOrder, 0);

      expect(b2.status, BookingStatus.waiting);
      expect(b2.queueOrder, 1);
    });

    test('GuestRecruitmentDto maps recruitment and explore payload safely', () {
      final json = {
        'id': 'rec-001',
        'sessionId': 'sess-123',
        'clubName': 'Legends Badminton Team',
        'courtLocation': 'Sân Kỳ Hòa Quận 10',
        'startTime': '2026-10-18T18:00:00Z',
        'endTime': '2026-10-18T20:00:00Z',
        'slotsNeeded': 2,
        'slotsRemaining': 2,
        'minSkillLevel': 'TB',
        'sharedCost': 80000.0,
        'scanRadiusKm': 5.0,
        'status': 'ACTIVE',
        'broadcastAt': '2026-10-18T10:00:00Z',
        'distanceKm': 2.4,
      };

      final entity = SessionMapper.toRecruitmentEntity(GuestRecruitmentDto.fromJson(json));
      expect(entity.id, 'rec-001');
      expect(entity.slotsNeeded, 2);
      expect(entity.minSkillLevel, SkillLevel.tb);
      expect(entity.distanceKm, 2.4);
    });
  });
}
