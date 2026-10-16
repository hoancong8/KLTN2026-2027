// lib/ui/screen/my_bookings/my_bookings_vm/my_bookings_state.dart

import '../../../../domain/entities/session/my_booking_item.dart';
import '../../../../domain/exceptions/app_exception.dart';

enum MyBookingsFilter {
  all('Tất cả'),
  upcoming('Sắp tới'),
  confirmed('Chính thức'),
  waiting('Hàng đợi'),
  past('Đã kết thúc');

  final String label;
  const MyBookingsFilter(this.label);
}

class MyBookingsState {
  final List<MyBookingItem> bookings;
  final bool isLoading;
  final AppException? error;
  final MyBookingsFilter filter;

  const MyBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.filter = MyBookingsFilter.all,
  });

  List<MyBookingItem> get filteredBookings {
    switch (filter) {
      case MyBookingsFilter.all:
        return bookings;
      case MyBookingsFilter.upcoming:
        return bookings.where((b) => b.isUpcoming).toList();
      case MyBookingsFilter.confirmed:
        return bookings.where((b) => b.isConfirmed || b.isCheckedIn).toList();
      case MyBookingsFilter.waiting:
        return bookings.where((b) => b.isWaiting).toList();
      case MyBookingsFilter.past:
        return bookings.where((b) => b.isPast).toList();
    }
  }

  MyBookingsState copyWith({
    List<MyBookingItem>? bookings,
    bool? isLoading,
    AppException? error,
    bool clearError = false,
    MyBookingsFilter? filter,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
    );
  }
}
