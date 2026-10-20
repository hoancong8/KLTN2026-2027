import 'package:flutter_test/flutter_test.dart';
import 'package:kltn2026_2027/data/dto/session/session_dto.dart';
import 'package:kltn2026_2027/data/dto/session/session_booking_dto.dart';
import 'package:kltn2026_2027/data/dto/session/guest_recruitment_dto.dart';
import 'package:kltn2026_2027/data/mapper/session_mapper.dart';
import 'package:kltn2026_2027/domain/enums/session_enums.dart';

void main() {
  group('Session & Booking API Mapper Verification', () {
    test('SessionDto parses ABP json correctly and maps to Session entity with local timezone conversion', () {
      final json = {
        'id': '7f1e9b2c-0000-0000-0000-000000000001',
        'groupId': 'club-456',
        'clubName': 'Legends Team',
        'title': 'Buổi sinh hoạt Thứ 3 (18:00 - 21:00)',
        'startTime': '2026-10-21T11:00:00Z',
        'endTime': '2026-10-21T14:00:00Z',
        'courtLocation': 'Sân Cầu Lông Viettel, 158 Hoàng Hoa Thám, P.12, Tân Bình, TP.HCM',
        'courtCount': 1,
        'targetPlayerPerCourt': 6,
        'maxPlayers': 6,
        'deadlineBooking': '2026-10-21T09:00:00Z',
        'courtRentalCost': 0.00,
        'status': 'OPEN',
        'confirmedCount': 0,
        'waitingCount': 0,
        'isBookedByCurrentUser': false,
        'currentUserBookingStatus': null,
        'currentUserQueueOrder': 0,
      };

      final dto = SessionDto.fromJson(json);
      expect(dto.id, '7f1e9b2c-0000-0000-0000-000000000001');
      expect(dto.maxPlayers, 6);
      expect(dto.confirmedCount, 0);
      expect(dto.waitingCount, 0);

      final entity = SessionMapper.toEntity(dto);
      expect(entity.id, '7f1e9b2c-0000-0000-0000-000000000001');
      expect(entity.status, SessionStatus.open);
      expect(entity.isFull, false);
      expect(entity.slotsRemaining, 6);

      // Verify UTC to Local conversion
      expect(entity.startTime.isUtc, isFalse);
      expect(entity.endTime.isUtc, isFalse);
      expect(entity.deadlineBooking.isUtc, isFalse);
      expect(entity.startTime.toUtc(), DateTime.parse('2026-10-21T11:00:00Z'));
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
      expect(b1.bookedAt.isUtc, isFalse);

      expect(b2.status, BookingStatus.waiting);
      expect(b2.queueOrder, 1);
      expect(b2.bookedAt.isUtc, isFalse);
    });

    test('GuestRecruitmentDto maps recruitment and explore payload safely', () {
      final json = {
        'id': 'rec-001',
        'sessionId': 'sess-123',
        'clubName': 'Legends Badminton Team',
        'courtLocation': 'Sân Kỳ Hòa Quận 10',
        'startTime': '2026-10-18T11:00:00Z',
        'endTime': '2026-10-18T13:00:00Z',
        'slotsNeeded': 2,
        'slotsRemaining': 2,
        'minSkillLevel': 'TB',
        'sharedCost': 80000.0,
        'scanRadiusKm': 5.0,
        'status': 'ACTIVE',
        'broadcastAt': '2026-10-18T03:00:00Z',
        'distanceKm': 2.4,
      };

      final entity = SessionMapper.toRecruitmentEntity(GuestRecruitmentDto.fromJson(json));
      expect(entity.id, 'rec-001');
      expect(entity.slotsNeeded, 2);
      expect(entity.minSkillLevel, SkillLevel.tb);
      expect(entity.distanceKm, 2.4);
      expect(entity.startTime.isUtc, isFalse);
    });
  });
}
