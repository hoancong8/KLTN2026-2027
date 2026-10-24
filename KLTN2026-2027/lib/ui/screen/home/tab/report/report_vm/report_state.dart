import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';

class ReportState {
  final bool isLoading;
  final String? error;
  final List<MyBookingItem> myBookings;
  final DateTime focusedMonth;
  final DateTime? selectedDate;

  const ReportState({
    this.isLoading = false,
    this.error,
    this.myBookings = const [],
    required this.focusedMonth,
    this.selectedDate,
  });

  List<MyBookingItem> get bookingsInFocusedMonth {
    return myBookings.where((b) {
      return b.startTime.year == focusedMonth.year &&
          b.startTime.month == focusedMonth.month;
    }).toList();
  }

  List<MyBookingItem> get bookingsOnSelectedDate {
    if (selectedDate == null) {
      return bookingsInFocusedMonth;
    }
    return myBookings.where((b) {
      return b.startTime.year == selectedDate!.year &&
          b.startTime.month == selectedDate!.month &&
          b.startTime.day == selectedDate!.day;
    }).toList();
  }

  ReportState copyWith({
    bool? isLoading,
    String? error,
    List<MyBookingItem>? myBookings,
    DateTime? focusedMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      myBookings: myBookings ?? this.myBookings,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
    );
  }
}
