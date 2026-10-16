// lib/data/mapper/my_booking_mapper.dart

import '../../domain/entities/session/my_booking_item.dart';
import '../../domain/enums/session_enums.dart';
import '../dto/session/my_booking_item_dto.dart';

class MyBookingMapper {
  static MyBookingItem toEntity(MyBookingItemDto dto) {
    return MyBookingItem(
      bookingId: dto.bookingId,
      sessionId: dto.sessionId,
      sessionTitle: dto.sessionTitle,
      clubId: dto.clubId,
      clubName: dto.clubName,
      clubAvatarUrl: dto.clubAvatarUrl,
      startTime: DateTime.tryParse(dto.startTime) ?? DateTime.now(),
      endTime: DateTime.tryParse(dto.endTime) ?? DateTime.now(),
      courtLocation: dto.courtLocation,
      sessionStatus: SessionStatus.fromString(dto.sessionStatus),
      bookingStatus: BookingStatus.fromString(dto.bookingStatus),
      queueOrder: dto.queueOrder,
      feePerMember: dto.feePerMember,
      bookedAt: DateTime.tryParse(dto.bookedAt) ?? DateTime.now(),
      checkinAt: dto.checkinAt != null ? DateTime.tryParse(dto.checkinAt!) : null,
    );
  }
}
