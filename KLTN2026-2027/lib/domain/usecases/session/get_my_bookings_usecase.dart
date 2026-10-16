// lib/domain/usecases/session/get_my_bookings_usecase.dart

import '../../entities/session/my_booking_item.dart';
import '../../repositories/session_repository.dart';

class GetMyBookingsUseCase {
  final SessionRepository repository;
  GetMyBookingsUseCase(this.repository);

  Future<List<MyBookingItem>> execute() => repository.getMyBookings();
}
