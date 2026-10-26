import 'package:kltn2026_2027/domain/entities/session/my_booking_item.dart';
import 'package:kltn2026_2027/domain/enums/session_enums.dart';

enum ReportFilter { all, confirmed, waiting, completed }

class ReportState {
  final bool isLoading;
  final String? error;
  final List<MyBookingItem> myBookings;
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ReportFilter filter;

  const ReportState({
    this.isLoading = false,
    this.error,
    this.myBookings = const [],
    required this.focusedMonth,
    this.selectedDate,
    this.filter = ReportFilter.all,
  });

  List<MyBookingItem> get bookingsInFocusedMonth {
    return myBookings.where((b) {
      return b.startTime.year == focusedMonth.year &&
          b.startTime.month == focusedMonth.month;
    }).toList();
  }

  List<MyBookingItem> get bookingsOnSelectedDate {
    final base = (selectedDate == null)
        ? bookingsInFocusedMonth
        : myBookings.where((b) {
            return b.startTime.year == selectedDate!.year &&
                b.startTime.month == selectedDate!.month &&
                b.startTime.day == selectedDate!.day;
          }).toList();

    switch (filter) {
      case ReportFilter.confirmed:
        return base.where((b) => b.isConfirmed && b.sessionStatus != SessionStatus.completed).toList();
      case ReportFilter.waiting:
        return base.where((b) => b.isWaiting).toList();
      case ReportFilter.completed:
        return base.where((b) => b.sessionStatus == SessionStatus.completed || b.isPast).toList();
      case ReportFilter.all:
      default:
        return base;
    }
  }

  ReportState copyWith({
    bool? isLoading,
    String? error,
    List<MyBookingItem>? myBookings,
    DateTime? focusedMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    ReportFilter? filter,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      myBookings: myBookings ?? this.myBookings,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      filter: filter ?? this.filter,
    );
  }
}
