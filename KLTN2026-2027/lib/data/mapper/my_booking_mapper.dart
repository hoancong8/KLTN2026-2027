// lib/data/mapper/my_booking_mapper.dart

import '../../domain/entities/session/my_booking_item.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/session/my_booking_item_dto.dart';

class MyBookingMapper {
  static DateTime _parseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.now();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return DateTime.now();
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static MyBookingItem toEntity(MyBookingItemDto dto) {
    return MyBookingItem(
      bookingId: dto.bookingId,
      sessionId: dto.sessionId,
      sessionTitle: dto.sessionTitle,
      clubId: dto.clubId,
      clubName: dto.clubName,
      clubAvatarUrl: dto.clubAvatarUrl,
      startTime: _parseDateTime(dto.startTime),
      endTime: _parseDateTime(dto.endTime),
      courtLocation: dto.courtLocation,
      sessionStatus: SessionStatus.fromString(dto.sessionStatus),
      bookingStatus: BookingStatus.fromString(dto.bookingStatus),
      queueOrder: dto.queueOrder,
      feePerMember: dto.feePerMember,
      bookedAt: _parseDateTime(dto.bookedAt),
      checkinAt: dto.checkinAt != null ? _parseDateTime(dto.checkinAt) : null,
    );
  }
}
